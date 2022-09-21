import 'package:bloc/bloc.dart';

import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/settings.dart';

class UpgradeExistsCubit extends Cubit<bool> with OuiSyncAppLogger {
  final int _currentProtocolVersion;
  final Settings _settings;

  UpgradeExistsCubit(this._currentProtocolVersion, this._settings)
      : super(false) {
    Future.microtask(() async {
      final stored =
          _settings.getHighestSeenProtocolNumber() ?? _currentProtocolVersion;
      foundVersion(stored);
    });
  }

  Future<void> foundVersion(int found) async {
    if (_currentProtocolVersion >= found) {
      return;
    }

    loggy.app(
        "Detected peer with higher protocol version (our:$_currentProtocolVersion, their:$found)");

    await _settings.setHighestSeenProtocolNumber(found);

    emit(true);
  }
}
