import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/settings/settings.dart';
import 'utils.dart';

class ChangeLocaleCubit extends Cubit<Locale> with CubitActions {
  ChangeLocaleCubit({required defaultLocale, required Settings settings})
      : _settings = settings,
        super(defaultLocale);

  final Settings _settings;

  Future<void> changeLocale(Locale locale) async {
    await _settings.setLanguageLocale(locale.languageCode);
    emitUnlessClosed(locale);
  }
}
