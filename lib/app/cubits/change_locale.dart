import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/settings/settings.dart';
import 'utils.dart';

class ChangeLocaleCubit extends Cubit<Locale> with CubitActions {
  final Settings _settings;

  ChangeLocaleCubit({required defaultLocale, required Settings settings})
      : _settings = settings,
        super(defaultLocale);

  Locale get currentLocale => state;

  static Locale get systemLocale => PlatformDispatcher.instance.locale;

  Future<void> changeLocale(Locale locale) async {
    await _settings.setLanguageLocale(locale.languageCode);
    emitUnlessClosed(locale);
  }
}
