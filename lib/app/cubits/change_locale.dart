import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/settings/v1.dart';
import 'utils.dart';

class ChangeLocaleCubit extends Cubit<Locale> {
  ChangeLocaleCubit({required defaultLocale, required Settings settings})
      : _settings = settings, super(defaultLocale);

  final Settings _settings;

  Future<void> changeLocale(Locale locale) async {
    await _settings.setLanguageLocale(locale.languageCode);
    emitUnlessClosed(locale);
  }
}
