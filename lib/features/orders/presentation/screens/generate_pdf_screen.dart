import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/pdf_manger.dart';

import '../../../../l10n/app_localizations.dart';

class GeneratePdfScreen extends StatelessWidget {
  const GeneratePdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // final pdf = await PdfManger.generatePdfReport();
          },
          child: Text(l10n.showReport),
        ),
      ),
    );
  }
}
