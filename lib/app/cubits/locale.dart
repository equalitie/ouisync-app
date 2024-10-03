import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../generated/l10n.dart' show S;
import '../utils/settings/settings.dart';
import 'utils.dart';

class LocaleState {
  final Locale currentLocale;
  final Locale defaultLocale;
  final Locale deviceLocale;

  LocaleState(
      {required this.currentLocale,
      required this.defaultLocale,
      required this.deviceLocale});

  LocaleState copyWith({
    Locale? currentLocale,
    Locale? defaultLocale,
    Locale? deviceLocale,
  }) =>
      LocaleState(
        currentLocale: currentLocale ?? this.currentLocale,
        defaultLocale: defaultLocale ?? this.defaultLocale,
        deviceLocale: deviceLocale ?? this.deviceLocale,
      );
}

class LocaleCubit extends Cubit<LocaleState> with CubitActions {
  final Settings _settings;

  factory LocaleCubit(Settings settings) {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final defaultLocale = _determineDefaultLocale();
    final currentLocale = _localeFromSettings(settings, defaultLocale);
    return LocaleCubit._(settings, defaultLocale, currentLocale, deviceLocale);
  }

  LocaleCubit._(Settings settings, Locale defaultLocale, Locale currentLocale,
      deviceLocale)
      : _settings = settings,
        super(LocaleState(
            currentLocale: currentLocale,
            defaultLocale: defaultLocale,
            deviceLocale: deviceLocale));

  Locale get currentLocale => state.currentLocale;
  Locale get defaultLocale => state.defaultLocale;
  Locale get deviceLocale => state.deviceLocale;

  static Locale get systemLocale => PlatformDispatcher.instance.locale;

  Future<void> changeLocale(Locale locale) async {
    // `defaultLocale` is represented as `null` in Settings.
    final l = locale == state.defaultLocale ? null : locale;
    await _settings.setLanguageLocale(l);
    emitUnlessClosed(state.copyWith(currentLocale: locale));
  }
}

// --- Support functions -------------------------------------------------------

Locale _localeFromSettings(Settings settings, Locale defaultLocale) {
  final settingsLocale = settings.getLanguageLocale();
  if (settingsLocale == null) {
    return defaultLocale;
  }
  return _closestSupportedLocale(settingsLocale) ?? defaultLocale;
}

Locale _determineDefaultLocale() {
  final supportedLocales = S.delegate.supportedLocales;
  final systemLocale = PlatformDispatcher.instance.locale;

  final locale = _closestSupportedLocale(systemLocale);

  if (locale != null) {
    return locale;
  }

  if (supportedLocales.isNotEmpty) {
    return supportedLocales.first;
  } else {
    assert(false,
        "This should never happen as there should be always at least one supported locale");
    return Locale('en');
  }
}

Locale? _closestSupportedLocale(Locale locale) {
  final supportedLocales = S.delegate.supportedLocales;

  // Check if this exact locale is supported and use it if so.
  if (supportedLocales.contains(locale)) {
    return locale;
  }

  // Check if the language is supported without the exact country code.
  return supportedLocales.firstWhereOrNull(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode);
}
