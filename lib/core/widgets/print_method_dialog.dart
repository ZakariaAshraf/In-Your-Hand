import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PrintMethodDialog extends StatelessWidget {
  const PrintMethodDialog({
    super.key,
    required this.onThermalPrinter,
    required this.onStandardPrinter,
  });

  final VoidCallback onThermalPrinter;
  final VoidCallback onStandardPrinter;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onThermalPrinter,
    required VoidCallback onStandardPrinter,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => PrintMethodDialog(
        onThermalPrinter: onThermalPrinter,
        onStandardPrinter: onStandardPrinter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget actionButton({
      required String title,
      required IconData icon,
      required VoidCallback onTap,
      required bool primary,
    }) {
      final style = primary
          ? FilledButton.styleFrom(
        backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            )
          : OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            );

      final child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22,color: Colors.black,),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );

      return primary
          ? FilledButton(onPressed: onTap, style: style, child: child)
          : OutlinedButton(onPressed: onTap, style: style, child: child);
    }

    return AlertDialog(
      title: Text(l10n.printMethodTitle,style: theme.textTheme.titleLarge,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionButton(
            title: l10n.printThermalPrinter,
            icon: Icons.receipt_long_outlined,
            onTap: () {
              Navigator.of(context).pop();
              onThermalPrinter();
            },
            primary: true,
          ),
          const SizedBox(height: 12),
          actionButton(
            title: l10n.printStandardPrinter,
            icon: Icons.print_outlined,
            onTap: () {
              Navigator.of(context).pop();
              onStandardPrinter();
            },
            primary: false,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel,style: theme.textTheme.bodyMedium,),
        ),
      ],
    );
  }
}
