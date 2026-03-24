import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../settings/presentation/components/settings_button.dart';
import 'screens/help_quick_guide_screen.dart';
import 'screens/text_content_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpAndSupport, style: theme.titleLarge),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsButton(
              title: l10n.howToUseTheApp,
              iconColor: Colors.teal,
              iconData: Icons.menu_book_outlined,
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpQuickGuideScreen(),
                  ),
                );
              },
            ),
            SettingsButton(
              title: l10n.aboutUs,
              iconColor: Colors.grey,
              iconData: Icons.info_outline_rounded,
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextContentScreen(
                      title: l10n.aboutUs,
                      body: l10n.aboutUsContent,
                    ),
                  ),
                );
              },
            ),
            SettingsButton(
              title: l10n.privacyPolicy,
              iconData: Icons.privacy_tip_outlined,
              iconColor: CupertinoColors.systemBlue,
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextContentScreen(
                      title: l10n.privacyPolicy,
                      body: l10n.privacyPolicyContent,
                    ),
                  ),
                );
              },
            ),
            SettingsButton(
              title: l10n.termsAndConditions,
              iconColor: Colors.red,
              iconData: Icons.description_outlined,
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextContentScreen(
                      title: l10n.termsAndConditions,
                      body: l10n.termsAndConditionsContent,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
