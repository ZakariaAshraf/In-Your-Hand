import 'package:flutter/material.dart';
import 'package:in_your_hand/core/config/widgets/app_status_blocking_layout.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen force-update gate (Arabic). Back navigation is disabled.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key, required this.storeUrl});

  final String storeUrl;

  Future<void> _openStore(BuildContext context) async {
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return;
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح متجر التطبيقات. يرجى المحاولة لاحقاً.',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStatusBlockingLayout(
      icon: Icons.system_update_alt_rounded,
      gradientColors: const [
        AppColors.primary,
        Color(0xFF1B5E20),
      ],
      title: 'يتوفر تحديث جديد للمنصة',
      subtitle:
          'يرجى تحديث التطبيق إلى النسخة الأخيرة للاستمرار في استخدام ميزات \'بين إيديك\' بأمان.',
      action: AppStatusPrimaryButton(
        label: 'تحديث الآن',
        onPressed: () => _openStore(context),
      ),
    );
  }
}
