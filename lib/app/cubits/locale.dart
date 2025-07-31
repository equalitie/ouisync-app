import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart' show S;
import '../utils/settings/settings.dart';
import '../utils/option.dart';
import 'utils.dart';

class LocaleState {
  // Both of these (if non null) must be in S.delegate.supportedLocales.
  final Locale currentLocale;
  final Option<Locale> deviceLocale;
  // This is true when `currentLocale == deviceLocale` *or* when `deviceLocale`
  // has changed through `_onSystemLocaleChanged` while the new value was not
  // in `S.delegate.supportedLocales`.
  final bool currentIsDefault;

  LocaleState({
    required this.currentLocale,
    required this.deviceLocale,
    required this.currentIsDefault,
  });

  LocaleState copyWith({
    Locale? currentLocale,
    Option<Locale>? deviceLocale,
    bool? currentIsDefault,
  }) => LocaleState(
    currentLocale: currentLocale ?? this.currentLocale,
    deviceLocale: deviceLocale ?? this.deviceLocale,
    currentIsDefault: currentIsDefault ?? this.currentIsDefault,
  );
}

class LocaleCubit extends Cubit<LocaleState> with CubitActions<LocaleState> {
  static final _defaultLocale = Locale('en');
  final Settings _settings;

  factory LocaleCubit(Settings settings) {
    assert(S.delegate.supportedLocales.contains(LocaleCubit._defaultLocale));

    final deviceLocale = _closestSupported(PlatformDispatcher.instance.locale);

    final settingsLocale = switch (settings.getLocale()) {
      null => null,
      SettingsDefaultLocale() => deviceLocale,
      final SettingsUserLocale locale => _closestSupported(locale),
    };

    final currentLocale =
        settingsLocale ?? deviceLocale ?? LocaleCubit._defaultLocale;

    return LocaleCubit._(settings, currentLocale, Option.from(deviceLocale));
  }

  LocaleCubit._(
    Settings settings,
    Locale currentLocale,
    Option<Locale> deviceLocale,
  ) : _settings = settings,
      super(
        LocaleState(
          currentLocale: currentLocale,
          deviceLocale: deviceLocale,
          currentIsDefault: currentLocale == deviceLocale.value,
        ),
      ) {
    // TODO: If someone/something creates another `LocaleCubit`, will that replace
    // the `this._onLocaleChanged` causing `this` to no longer receive the events?
    PlatformDispatcher.instance.onLocaleChanged = () =>
        _onSystemLocaleChanged();
  }

  Locale get currentLocale => state.currentLocale;
  Locale? get deviceLocale => state.deviceLocale.value;

  Future<void> changeLocale(Locale locale) async {
    final newIsDefault = locale == state.deviceLocale.value;

    await _settings.setLocale(newIsDefault ? null : locale);

    emitUnlessClosed(
      state.copyWith(currentLocale: locale, currentIsDefault: newIsDefault),
    );
  }

  void _onSystemLocaleChanged() {
    final newDeviceLocale = _closestSupported(
      PlatformDispatcher.instance.locale,
    );

    if (state.currentIsDefault) {
      final newCurrent =
          Option.andThen(newDeviceLocale, _closestSupported) ??
          LocaleCubit._defaultLocale;

      emitUnlessClosed(
        state.copyWith(
          currentLocale: newCurrent,
          deviceLocale: Option.from(newDeviceLocale),
        ),
      );
    } else {
      emitUnlessClosed(
        state.copyWith(deviceLocale: Option.from(newDeviceLocale)),
      );
    }
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

  final candidates = within
      .where((i) => i.languageCode == desired.languageCode)
      .toList();

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
    final scriptCompare = _comparator(
      desired.scriptCode,
      a.scriptCode,
      b.scriptCode,
    );

    if (scriptCompare != 0) {
      return scriptCompare;
    }

    final countryCompare = _comparator(
      desired.countryCode,
      a.countryCode,
      b.countryCode,
    );

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
  return switch ((
    _nullOrEmpty(target),
    _nullOrEmpty(left),
    _nullOrEmpty(right),
  )) {
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

bool _nullOrEmpty(String? s) => s == null ? true : s.isEmpty;
