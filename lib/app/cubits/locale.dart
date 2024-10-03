import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../generated/l10n.dart' show S;
import '../utils/settings/settings.dart';
import '../utils/option.dart';
import 'utils.dart';

class LocaleState {
  // Both of these (if non null) must be in S.delegate.supportedLocales.
  final Locale currentLocale;
  final Option<Locale> deviceLocale;

  LocaleState({required this.currentLocale, required this.deviceLocale});

  LocaleState copyWith({Locale? currentLocale, Option<Locale>? deviceLocale}) =>
      LocaleState(
        currentLocale: currentLocale ?? this.currentLocale,
        deviceLocale: deviceLocale ?? this.deviceLocale,
      );
}

class LocaleCubit extends Cubit<LocaleState> with CubitActions {
  final Settings _settings;

  factory LocaleCubit(Settings settings) {
    final defaultLocale = Locale('en');
    assert(S.delegate.supportedLocales.contains(defaultLocale));

    final deviceLocale = _closestSupported(PlatformDispatcher.instance.locale);

    final settingsLocale =
        Option.andThen(settings.getLanguageLocale(), _closestSupported);

    final currentLocale = settingsLocale ?? deviceLocale ?? defaultLocale;

    return LocaleCubit._(settings, currentLocale, Option.from(deviceLocale));
  }

  LocaleCubit._(
      Settings settings, Locale currentLocale, Option<Locale> deviceLocale)
      : _settings = settings,
        super(LocaleState(
            currentLocale: currentLocale, deviceLocale: deviceLocale));

  Locale get currentLocale => state.currentLocale;
  Locale? get deviceLocale => state.deviceLocale.value;

  Future<void> changeLocale(Locale locale) async {
    // `deviceLocale` is represented as `null` in Settings.
    final l = locale == state.deviceLocale ? null : locale;
    await _settings.setLanguageLocale(l);
    emitUnlessClosed(state.copyWith(currentLocale: locale));
  }
}

// --- Support functions -------------------------------------------------------

Locale? _closestSupported(Locale locale) {
  return _closestWithin(locale, S.delegate.supportedLocales);
}

Locale? _closestWithin(Locale desired, List<Locale> within) {
  // If one matches exactly.
  if (within.contains(desired)) {
    return desired;
  }

  final candidates =
      within.where((i) => i.languageCode == desired.languageCode).toList();

  if (candidates.isEmpty) {
    return null;
  }

  if (candidates.length == 1) {
    return candidates.first;
  }

  candidates.sort((a, b) {
    // We already know `languageCode` is the one we need, so no need to compare
    // with it.
    //
    // TODO: Is it correct to first compare by `scriptCode` and then by
    // `countryCode`?  or should it be vice-versa?
    final scriptCompare =
        _comparator(desired.scriptCode, a.scriptCode, b.scriptCode);

    if (scriptCompare != 0) {
      return scriptCompare;
    }

    final countryCompare =
        _comparator(desired.countryCode, a.countryCode, b.countryCode);

    if (countryCompare != 0) {
      return countryCompare;
    }

    return a.toString().compareTo(b.toString()); // Sort alphabetically?
  });

  return candidates.first;
}

// Return -1 if `left` is smaller.
// Return  1 if `left` is bigger.
// Return  0 if it's a tie.
// https://api.flutter.dev/flutter/dart-core/Comparator.html
int _comparator(String? target, String? left, String? right) {
  final nullOrEmpty = (String? s) => s == null ? true : s.isEmpty;

  return switch ((nullOrEmpty(target), nullOrEmpty(left), nullOrEmpty(right))) {
    (true, true, true) => 0,
    (true, true, false) => -1,
    (true, false, true) => 1,
    (true, false, false) => 0,
    (false, true, true) => 0,
    (false, false, true) => target == left ? -1 : 1,
    (false, true, false) => target == right ? 1 : -1,
    (false, false, false) => target == left ? -1 : (target == right ? 1 : 0),
  };
}
