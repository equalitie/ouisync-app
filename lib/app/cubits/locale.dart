import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/settings/settings.dart';
import 'utils.dart';

class LocaleCubit extends Cubit<Locale> with CubitActions {
  final Settings _settings;

  LocaleCubit(Settings settings)
      : _settings = settings,
        super(_localeFromSettings(settings));

  Locale get currentLocale => state;

  static Locale get systemLocale => PlatformDispatcher.instance.locale;

  Future<void> changeLocale(Locale locale) async {
    // `systemLocale` is represented as `null` in Settings.
    final l = locale == LocaleCubit.systemLocale ? null : locale;
    await _settings.setLanguageLocale(l?.languageCode);
    emitUnlessClosed(locale);
  }
}

Locale _localeFromSettings(Settings settings) {
  final languageCode = settings.getLanguageLocale();
  if (languageCode != null) {
    return Locale(languageCode);
  }
  return LocaleCubit.systemLocale;
}
