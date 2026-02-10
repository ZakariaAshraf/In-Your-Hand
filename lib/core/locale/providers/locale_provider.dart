import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cache/cache_helper.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final String? savedLang = CacheHelper.getString(key: CacheKeys.language);

    if (savedLang != null && savedLang.isNotEmpty) {
      return Locale(savedLang);
    }
    // First-time / no preference: follow system locale (null = use device language)
    return null;
  }

  void setLocale(Locale newLocale) async {
    if (state != newLocale) {
      state = newLocale;
      await CacheHelper.set(
          key: CacheKeys.language,
          value: newLocale.languageCode
      );
    }
  }
}