import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:in_your_hand/core/config/voice_order_limits.dart';
import 'package:in_your_hand/core/premium/ai_quota_service.dart';
import 'package:in_your_hand/core/premium/premium_service.dart';
import 'package:in_your_hand/core/services/gemeni_service.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/clients/domain/entities/client_entity.dart';
import 'package:in_your_hand/features/clients/domain/repositories/clients_repository.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import 'package:in_your_hand/features/orders/domain/entities/order_entity.dart';
import 'package:in_your_hand/features/orders/domain/repositories/orders_repository.dart';
import 'package:in_your_hand/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

part 'voice_order_state.dart';

class VoiceOrderCubit extends Cubit<VoiceOrderState> {
  VoiceOrderCubit({
    required this.geminiService,
    required SessionCubit sessionCubit,
    required OrdersRepository ordersRepository,
    required ClientsRepository clientsRepository,
    required PremiumService premiumService,
    required AiQuotaService aiQuotaService,
    required this.ordersCubit,
    required this.clientsCubit,
  })  : _sessionCubit = sessionCubit,
        _ordersRepository = ordersRepository,
        _clientsRepository = clientsRepository,
        _premiumService = premiumService,
        _aiQuotaService = aiQuotaService,
        super(const VoiceOrderState());

  final GeminiService geminiService;
  final SessionCubit _sessionCubit;
  final OrdersRepository _ordersRepository;
  final ClientsRepository _clientsRepository;
  final PremiumService _premiumService;
  final AiQuotaService _aiQuotaService;
  final OrdersCubit ordersCubit;
  final ClientsCubit clientsCubit;

  final SpeechToText _speech = SpeechToText();

  Future<bool> _isVoiceAiQuotaOk(String workspaceId) async {
    if (await _premiumService.isPremium()) return true;
    return _aiQuotaService.canUseVoiceAi(
      workspaceId,
      freeLimit: VoiceOrderLimits.freeVoiceOrdersPerPeriod,
    );
  }

  /// Returns `false` if mic / Gemini must stop (quota or Premium gate failed).
  Future<bool> _assertVoiceAiAllowedOrEmitBlocked() async {
    final wid = _sessionCubit.contextOrNull?.workspaceId;
    if (wid == null) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Session not ready',
      ));
      return false;
    }
    if (!await _isVoiceAiQuotaOk(wid)) {
      emit(state.copyWith(
        status: VoiceOrderStatus.localQuotaReached,
        errorMessage: null,
      ));
      return false;
    }
    return true;
  }

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
    if (!await _assertVoiceAiAllowedOrEmitBlocked()) return;

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
  /// [clients] is used to resolve clientName to clientId; unknown names create a local client.
  Future<void> submitAndAddOrder({
    required List<ClientModel> clients,
    String? transcriptOverride,
  }) async {
    if (!await _assertVoiceAiAllowedOrEmitBlocked()) return;

    final wid = _sessionCubit.contextOrNull!.workspaceId;

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

    if (clientName.isEmpty) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Missing client name',
      ));
      return;
    }

    final match = clients
        .where((c) => !c.isDeleted)
        .where((c) => c.name.trim().toLowerCase() == clientName.toLowerCase())
        .toList();

    late final String clientId;
    late final String resolvedClientName;

    try {
      if (match.isEmpty) {
        final newId = const Uuid().v4();
        final now = DateTime.now();
        await _clientsRepository.upsertClient(
          ClientEntity(
            id: newId,
            workspaceId: wid,
            name: clientName,
            phone: null,
            notes: null,
            isDeleted: false,
            createdAt: now,
            updatedAt: now,
            syncStatus: 1,
            remoteId: null,
          ),
        );
        await clientsCubit.getClients();
        clientId = newId;
        resolvedClientName = clientName;
      } else {
        final client = match.first;
        if (client.id == null || client.id!.isEmpty) {
          emit(state.copyWith(
            status: VoiceOrderStatus.error,
            errorMessage: 'Client not found: $clientName',
          ));
          return;
        }
        clientId = client.id!;
        resolvedClientName = client.name;
      }
    } catch (e) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: e.toString(),
      ));
      return;
    }

    final order = OrderModel(
      id: '',
      userId: wid,
      clientId: clientId,
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
      clientName: resolvedClientName,
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
  /// from the dialog; if null, uses state.pendingOrder. Persists via offline-first repository.
  Future<void> confirmAndAddOrder({OrderModel? order}) async {
    final orderToAdd = order ?? state.pendingOrder;
    if (orderToAdd == null) return;

    final wid = _sessionCubit.contextOrNull?.workspaceId;
    if (wid == null) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Session not ready',
      ));
      return;
    }

    if (!orderToAdd.isValidPayment) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: 'Invalid payment values',
      ));
      return;
    }

    try {
      final id =
          orderToAdd.id.isEmpty ? const Uuid().v4() : orderToAdd.id;
      final now = DateTime.now();
      final entity = OrderEntity(
        id: id,
        workspaceId: wid,
        clientId: orderToAdd.clientId,
        description: orderToAdd.description,
        totalAmount: orderToAdd.totalAmount,
        totalPaid: orderToAdd.totalPaid,
        notes: orderToAdd.notes,
        isDeleted: false,
        createdAt: orderToAdd.createdAt,
        updatedAt: now,
        syncStatus: 1,
        remoteId: null,
      );
      await _ordersRepository.upsertOrder(entity);
      await FirebaseAnalytics.instance.logEvent(
        name: 'order_created',
        parameters: <String, Object>{
          'creation_method': 'voice',
        },
      );
      await ordersCubit.getOrders();
      if (!(await _premiumService.isPremium())) {
        await _aiQuotaService.incrementVoiceAiUsage(wid);
      }
      emit(VoiceOrderState(
        status: VoiceOrderStatus.success,
        isSpeechAvailable: state.isSpeechAvailable,
        pendingOrder: null,
        orderPreview: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VoiceOrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
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

  void dismissLocalQuotaReached() {
    if (state.status == VoiceOrderStatus.localQuotaReached) {
      emit(state.copyWith(status: VoiceOrderStatus.ready));
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
}
