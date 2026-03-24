import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';

class HelpQuickGuideScreen extends StatelessWidget {
  const HelpQuickGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpAndSupport, style: theme.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.howToUseTheApp, style: theme.titleMedium),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_add_outlined),
                      title: Text(l10n.helpAddClient),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: Text(l10n.helpAddOrder),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(l10n.helpAddPayment),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.picture_as_pdf_outlined),
                      title: Text(l10n.helpGeneratePdf),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.mic_outlined),
                      title: Text(l10n.helpVoiceOrder),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact & Feedback', style: theme.titleMedium),
                    const SizedBox(height: 8),
                    Text(l10n.helpContactMessage, style: theme.bodyMedium),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: l10n.helpSendFeedback,
                      onTap: () async {
                        final uri = Uri.parse('https://forms.gle/G3V7PwjhPdm6MBtU6');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
