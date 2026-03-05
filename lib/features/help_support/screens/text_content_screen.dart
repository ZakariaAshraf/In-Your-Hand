import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';

import '../../../core/config/app_info.dart';


/// A generic screen that shows a title, scrollable body text, and a bottom bar
/// with app name and version. Used for About Us, Privacy Policy, Terms and Conditions.
class TextContentScreen extends StatelessWidget {
  final String title;
  final String body;

  const TextContentScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w(context),
                vertical: 16,
              ),
              child: Text(
                body,
                style: theme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ),
          _BottomVersionBar(),
        ],
      ),
    );
  }
}

class _BottomVersionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppInfo.appName,
            style: theme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${AppInfo.version}',
            style: theme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
