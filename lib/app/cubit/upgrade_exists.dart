import 'dart:io' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc/bloc.dart';

import '../utils/loggers/ouisync_app_logger.dart';

class UpgradeExistsCubit extends Cubit<bool> with OuiSyncAppLogger {
  final _prefKey = "storedHighestSeenProtocolVersion";
  final int _currentProtocolVersion;

  UpgradeExistsCubit(this._currentProtocolVersion) : super(false)
  {
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final highestStored = prefs.getInt(_prefKey) ?? _currentProtocolVersion;
      foundVersion(highestStored);
    });
  }

  Future<void> foundVersion(int found) async {
    if (_currentProtocolVersion >= found) {
      return;
    }

    loggy.app("Detected peer with higher protocol version (our:$_currentProtocolVersion, their:$found)");

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_prefKey, found);

    emit(true);
  }
}
