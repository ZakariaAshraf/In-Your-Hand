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

    if (savedLang != null) {
      return Locale(savedLang);
    }
    return const Locale('en');
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