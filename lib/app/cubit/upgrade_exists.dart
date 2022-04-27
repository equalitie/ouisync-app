import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import '../utils/loggers/ouisync_app_logger.dart';

class UpgradeExistsCubit extends Cubit<bool> with OuiSyncAppLogger {
  int currentProtocolVersion;

  UpgradeExistsCubit(this.currentProtocolVersion) : super(false);

  Future<void> foundNewerVersion(int highest) async {
    if (currentProtocolVersion >= highest) {
      // This shouldn't happen, but let's sanitize the case.
      return;
    }

    loggy.app("Detected peer with higher protocol version (our:$currentProtocolVersion, their:$highest)");

    emit(true);
  }
}
