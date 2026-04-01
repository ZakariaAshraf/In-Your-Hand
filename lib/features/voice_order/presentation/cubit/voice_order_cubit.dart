import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_your_hand/core/config/voice_order_limits.dart';
import 'package:in_your_hand/core/services/gemeni_service.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import 'package:in_your_hand/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:speech_to_text/speech_to_text.dart';

part 'voice_order_state.dart';

class VoiceOrderCubit extends Cubit<VoiceOrderState> {
  VoiceOrderCubit({
    required this.geminiService,
    required this.ordersCubit,
  }) : super(const VoiceOrderState());

  final GeminiService geminiService;
  final OrdersCubit ordersCubit;

  final SpeechToText _speech = SpeechToText();

  /// Call once when the feature is opened. Initializes speech and requests permission.
  Future<void> init() async {
    emit(state.copyWith(status: VoiceOrderStatus.initial));
    final available = await _speech.initialize(
      onError: (e) {
        if (kDebugMode) print('Speech error: $e');
        emit(state.copyWith(
          status: VoiceOrderStatus.error,
          errorMessage: e.errorMsg,
        ));
      },
      onStatus: (status) {
        if (kDebugMode) print('Speech status: $status');
      },
    );
    if (!available) {
      emit(state.copyWith(
        status: VoiceOrderStatus.permissionDenied,
        isSpeechAvailable: false,
      ));
      return;
    }
    emit(state.copyWith(
      status: VoiceOrderStatus.ready,
      isSpeechAvailable: true,
    ));
  }

  /// Start listening. [localeId] should be "en_US" or "ar_EG" (etc.) for better recognition.
  /// Updates transcript on every result (partial + final) so the UI shows live text.
  Future<void> startListening({String? localeId}) async {
    if (!state.isSpeechAvailable) {
      emit(state.copyWith(status: VoiceOrderStatus.permissionDenied));
      return;
    }
    emit(state.copyWith(status: VoiceOrderStatus.listening, transcript: ''));
    await _speech.listen(
      onResult: (result) {
        // Update on every result so the user sees what they say while talking
        emit(state.copyWith(transcript: result.recognizedWords));
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 10),
      partialResults: true,
      localeId: localeId,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    if (state.status == VoiceOrderStatus.listening) {
      emit(state.copyWith(status: VoiceOrderStatus.ready));
    }
  }

  /// Takes current transcript (or [transcriptOverride]), sends to Gemini, then adds order.
  /// [clients] is used to resolve clientName to clientId.
  Future<void> submitAndAddOrder({
    required List<ClientModel> clients,
    String? transcriptOverride,
  }) async {
    // Read limit from Firestore directly — never trust stale constructor state
    final gateUid = FirebaseAuth.instance.currentUser?.uid;
    if (gateUid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(gateUid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final isPremium = data['isPremium'] ?? false;
        final voiceOrdersUsed = data['voiceOrdersUsed'] ?? 0;
        if (!isPremium &&
            voiceOrdersUsed >= VoiceOrderLimits.freeVoiceOrdersPerPeriod) {
          emit(state.copyWith(
            status: VoiceOrderStatus.error,
            errorMessage: 'voiceLimitReached',
          ));
          return;
        }
      }
    }

    final text = (transcriptOverride ?? state.transcript ?? '').trim();
    if (text.isEmpty) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'No speech text',
      ));
      return;
    }

    if (!GeminiService.isConfigured) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Gemini API key not configured',
      ));
      return;
    }

    emit(state.copyWith(status: VoiceOrderStatus.processing, errorMessage: null));

    Map<String, dynamic>? json;
    try {
      json = await geminiService.speechTextToOrderJson(text);
    } on GeminiQuotaException {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'geminiQuotaExceeded',
      ));
      return;
    }
    if (json == null) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Could not understand order from speech',
      ));
      return;
    }

    final clientName = (json['clientName'] as String?)?.toString().trim() ?? '';
    final description = (json['description'] as String?)?.toString().trim() ?? '';
    final totalAmount = _toDouble(json['totalAmount'], 0);
    final totalPaid = _toDouble(json['totalPaid'], 0);

    if (description.isEmpty || totalAmount <= 0) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Missing description or total amount',
      ));
      return;
    }

    final match = clients
        .where((c) => !c.isDeleted)
        .where((c) => c.name.trim().toLowerCase() == clientName.toLowerCase())
        .toList();
    final client = match.isEmpty ? null : match.first;
    if (client == null || client.id == null || client.id!.isEmpty) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Client not found: $clientName',
      ));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final order = OrderModel(
      id: '',
      userId: uid,
      clientId: client.id!,
      description: description,
      totalAmount: totalAmount,
      totalPaid: totalPaid,
      createdAt: DateTime.now(),
    );

    if (!order.isValidPayment) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Invalid amounts (paid cannot exceed total)',
      ));
      return;
    }

    final preview = VoiceOrderPreview(
      clientName: client.name,
      description: description,
      totalAmount: totalAmount,
      totalPaid: totalPaid,
    );
    emit(state.copyWith(
      status: VoiceOrderStatus.orderReadyToConfirm,
      pendingOrder: order,
      orderPreview: preview,
    ));
  }

  /// Called when the user confirms the order in the dialog. [order] can be the edited order
  /// from the dialog; if null, uses state.pendingOrder. Adds to Firestore and emits success.
  Future<void> confirmAndAddOrder({OrderModel? order}) async {
    final orderToAdd = order ?? state.pendingOrder;
    if (orderToAdd == null) return;
    await ordersCubit.addOrder(orderToAdd);
    await _incrementUsage();
    emit(VoiceOrderState(
      status: VoiceOrderStatus.success,
      isSpeechAvailable: state.isSpeechAvailable,
      pendingOrder: null,
      orderPreview: null,
    ));
  }

  /// Called when the user cancels the confirm dialog. Clears preview and returns to ready.
  void cancelConfirm() {
    emit(VoiceOrderState(
      status: VoiceOrderStatus.ready,
      transcript: state.transcript,
      isSpeechAvailable: state.isSpeechAvailable,
      pendingOrder: null,
      orderPreview: null,
    ));
  }

  double _toDouble(dynamic v, double def) {
    if (v == null) return def;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? def;
    return def;
  }

  void clearError() {
    if (state.status == VoiceOrderStatus.error) {
      emit(state.copyWith(status: VoiceOrderStatus.ready, errorMessage: null));
    }
  }

  void reset() {
    emit(const VoiceOrderState(
      status: VoiceOrderStatus.ready,
      isSpeechAvailable: true,
      pendingOrder: null,
      orderPreview: null,
    ));
  }

  Future<void> _incrementUsage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snap = await docRef.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    final now = DateTime.now();
    final resetDate = (data['voiceOrdersResetDate'] as Timestamp?)?.toDate();
    final shouldReset = resetDate == null || now.difference(resetDate).inDays >= 30;
    await docRef.update({
      'voiceOrdersUsed': shouldReset ? 1 : FieldValue.increment(1),
      if (shouldReset) 'voiceOrdersResetDate': FieldValue.serverTimestamp(),
    });
  }
}
