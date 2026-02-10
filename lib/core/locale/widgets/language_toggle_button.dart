
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/settings_toggle_button.dart';
import '../providers/locale_provider.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final locale = ref.watch(localeProvider);
    // When no preference (null), follow system: use current resolved locale
    final resolvedLocale = locale ?? Localizations.localeOf(context);
    final isEnglish = resolvedLocale.languageCode == 'en';
    final l10n = AppLocalizations.of(context);
    return SettingsToggleButton(
      leadingIconData: CupertinoIcons.globe,
      leadingIconColor: Colors.blue,
      title: l10n!.language,
      value: isEnglish,
      onChanged: (isEnglish) {
        final newLocale = isEnglish ? const Locale('en') : const Locale('ar');
        ref.read(localeProvider.notifier).setLocale(newLocale);
      },
      trueIcon: Icons.abc_sharp,
      falseIcon: Icons.translate_outlined,
    );
  }
}
