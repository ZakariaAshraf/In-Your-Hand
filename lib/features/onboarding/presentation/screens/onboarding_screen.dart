import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:in_your_hand/core/cache/cache_helper.dart';
import 'package:in_your_hand/features/settings/presentation/Cubit/user_cubit.dart';
import 'package:in_your_hand/l10n/app_localizations.dart';
import 'package:in_your_hand/main_screen.dart';

/// Product onboarding: offline + AI + printing, then optional business pre-fill.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static Widget _slideBody(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required List<Color> gradientColors,
      }) {
    final theme = Theme.of(context).textTheme;
    final h = MediaQuery.sizeOf(context).height;

    return Container(
      alignment: Alignment.topCenter,
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: h * 0.1), // مسافة من أعلى الشاشة

          // البوكس الملون أصبح الآن جزءاً من الـ Body لضمان ظهوره
          Container(
            alignment: Alignment.center,
            height: h * 0.4, // تم تغيير الارتفاع ليكون متجاوباً مع الشاشة
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 120, color: Colors.white.withValues(alpha: 0.92)),
          ),

          const SizedBox(height: 32),

          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.bodyLarge?.copyWith(
              height: 1.35,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  void _openQuickSetup(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _OnboardingQuickSetupForm(
            parentContext: context,
            l10n: l10n,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final headerColor = scheme.surface;
    final primary = Colors.green;

    return OnBoardingSlider(
      onFinish: () => _openQuickSetup(context),
      finishButtonText: l10n.continuee,
      finishButtonStyle: FinishButtonStyle(backgroundColor: primary),
      finishButtonTextStyle: const TextStyle(
        fontSize: 17,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      skipTextButton: Text(
        l10n.skip,
        style: TextStyle(
          fontSize: 16,
          color: primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      controllerColor: primary,
      totalPage: 3,
      headerBackgroundColor: headerColor,
      pageBackgroundColor: scheme.surface,
      speed: 1.8,
      background: const [
        SizedBox.shrink(),
        SizedBox.shrink(),
        SizedBox.shrink(),
      ],
      pageBodies: [
        _slideBody(
          context,
          title: l10n.onboardingSlide1Title,
          subtitle: l10n.onboardingSlide1Subtitle,
          icon: Icons.cloud_off_rounded,
          gradientColors: [primary.withValues(alpha: 0.85), primary.withValues(alpha: 0.45)],
        ),
        _slideBody(
          context,
          title: l10n.onboardingSlide2Title,
          subtitle: l10n.onboardingSlide2Subtitle,
          icon: Icons.mic_rounded,
          gradientColors: [
            const Color(0xFF1565C0).withValues(alpha: 0.9),
            const Color(0xFF42A5F5).withValues(alpha: 0.55),
          ],
        ),
        _slideBody(
          context,
          title: l10n.onboardingSlide3Title,
          subtitle: l10n.onboardingSlide3Subtitle,
          icon: Icons.print_rounded,
          gradientColors: [
            Colors.deepPurple.withValues(alpha: 0.85),
            Colors.purple.withValues(alpha: 0.5),
          ],
        ),
      ],
    );
  }
}

class _OnboardingQuickSetupForm extends StatefulWidget {
  const _OnboardingQuickSetupForm({
    required this.parentContext,
    required this.l10n,
  });

  final BuildContext parentContext;
  final AppLocalizations l10n;

  @override
  State<_OnboardingQuickSetupForm> createState() =>
      _OnboardingQuickSetupFormState();
}

class _OnboardingQuickSetupFormState extends State<_OnboardingQuickSetupForm> {
  late final TextEditingController _businessNameController;
  late final TextEditingController _phoneController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final cubit = widget.parentContext.read<UserCubit>();
      final rawPhone = _phoneController.text.trim();
      await cubit.updateBusinessProfile(
        businessName: _businessNameController.text.trim(),
        phone: rawPhone.isEmpty ? null : rawPhone,
      );
      if (!widget.parentContext.mounted) return;

      final st = cubit.state;
      if (st is UserError) {
        if (widget.parentContext.mounted) {
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            SnackBar(content: Text(st.message)),
          );
        }
        return;
      }

      await CacheHelper.setOnboardingSeen(true);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (!widget.parentContext.mounted) return;
      Navigator.of(widget.parentContext, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final padding = MediaQuery.paddingOf(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingQuickSetupTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _businessNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.onboardingBusinessNameLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.onboardingPhoneLabel,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => unawaited(_submit()),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.onboardingStartCta),
          ),
        ],
      ),
    );
  }
}
