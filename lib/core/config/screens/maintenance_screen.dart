import 'package:flutter/material.dart';
import 'package:in_your_hand/core/config/widgets/app_status_blocking_layout.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';

/// Full-screen maintenance gate (Arabic). Back navigation is disabled.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppStatusBlockingLayout(
      icon: Icons.engineering_rounded,
      gradientColors: [
        Color(0xFF2C3930),
        AppColors.primary,
      ],
      title: 'التطبيق قيد الصيانة حالياً',
      subtitle:
          'نعمل على تحسين الخدمات لتوفير تجربة أفضل، سنعود للعمل قريباً جداً.',
    );
  }
}
