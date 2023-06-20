import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/log.dart';
import '../utils/settings.dart';

class UpgradeExistsCubit extends Cubit<bool> with OuiSyncAppLogger {
  final Future<int> _currentProtocolVersion;
  final Settings _settings;

  UpgradeExistsCubit(this._currentProtocolVersion, this._settings)
      : super(false) {
    Future.microtask(() async {
      final current = await _currentProtocolVersion;
      final stored = _settings.getHighestSeenProtocolNumber() ?? current;

      await foundVersion(stored);
    });
  }

  Future<void> foundVersion(int found) async {
    final current = await _currentProtocolVersion;

    if (current >= found) {
      return;
    }

    loggy.app(
        "Detected peer with higher protocol version (our:$current, their:$found)");

    await _settings.setHighestSeenProtocolNumber(found);

    emit(true);
  }
}
