part of 'voice_order_cubit.dart';

enum VoiceOrderStatus {
  initial,
  permissionDenied,
  ready,
  listening,
  processing,
  orderReadyToConfirm,
  success,
  error,
}

/// Preview data shown in the confirm dialog (client name + order details).
class VoiceOrderPreview {
  final String clientName;
  final String description;
  final double totalAmount;
  final double totalPaid;

  const VoiceOrderPreview({
    required this.clientName,
    required this.description,
    required this.totalAmount,
    required this.totalPaid,
  });
}

class VoiceOrderState {
  final VoiceOrderStatus status;
  final String? transcript;
  final String? errorMessage;
  final bool isSpeechAvailable;
  /// When status is orderReadyToConfirm, this holds the order to add on confirm.
  final OrderModel? pendingOrder;
  /// Human-readable preview for the confirm dialog.
  final VoiceOrderPreview? orderPreview;

  const VoiceOrderState({
    this.status = VoiceOrderStatus.initial,
    this.transcript,
    this.errorMessage,
    this.isSpeechAvailable = false,
    this.pendingOrder,
    this.orderPreview,
  });

  VoiceOrderState copyWith({
    VoiceOrderStatus? status,
    String? transcript,
    String? errorMessage,
    bool? isSpeechAvailable,
    OrderModel? pendingOrder,
    VoiceOrderPreview? orderPreview,
  }) {
    return VoiceOrderState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      errorMessage: errorMessage ?? this.errorMessage,
      isSpeechAvailable: isSpeechAvailable ?? this.isSpeechAvailable,
      pendingOrder: pendingOrder ?? this.pendingOrder,
      orderPreview: orderPreview ?? this.orderPreview,
    );
  }
}
