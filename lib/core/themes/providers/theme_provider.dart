import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cache/cache_helper.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final String? savedTheme = CacheHelper.getString(key: CacheKeys.theme);

    if (savedTheme == 'dark') {
      return ThemeMode.dark;
    }
    if (savedTheme == 'light') {
      return ThemeMode.light;
    }
    // First-time / no preference: follow system theme (device light/dark)
    return ThemeMode.system;
  }

  void toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;

    await CacheHelper.set(
      key: CacheKeys.theme,
      value: isDark ? 'dark' : 'light',
    );
  }
}
