import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_your_hand/core/config/voice_order_limits.dart';

class AppUserModel {
  final String name;
  final String phone;
  final DateTime createdAt;
  final String charUrl;
  final bool isPremium;
  final int voiceOrdersUsed;
  final DateTime? voiceOrdersResetDate;

  AppUserModel({
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.charUrl,
    this.isPremium = false,
    this.voiceOrdersUsed = 0,
    this.voiceOrdersResetDate,
  });

  bool get canUseVoiceOrder =>
      isPremium || voiceOrdersUsed < VoiceOrderLimits.freeVoiceOrdersPerPeriod;

  factory AppUserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUserModel(
      name: data['name'],
      phone: data['phone'],
      createdAt: data['createdAt'].toDate(),
      charUrl: data['character'],
      isPremium: data['isPremium'] ?? false,
      voiceOrdersUsed: data['voiceOrdersUsed'] ?? 0,
      voiceOrdersResetDate:
          (data['voiceOrdersResetDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'character': charUrl,
      'isPremium': isPremium,
      'voiceOrdersUsed': voiceOrdersUsed,
      'voiceOrdersResetDate': voiceOrdersResetDate != null
          ? Timestamp.fromDate(voiceOrdersResetDate!)
          : null,
    };
  }
}
