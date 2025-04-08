import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/utils.dart';
import 'utils.dart';

class UpgradeExistsCubit extends Cubit<bool> with CubitActions, AppLogger {
  final Session _session;
  final Settings _settings;
  StreamSubscription? _subscription;

  UpgradeExistsCubit(Session session, Settings settings)
      : _session = session,
        _settings = settings,
        super(false) {
    unawaited(
        _init().catchError((e, st) => loggy.error('During _init():', e, st)));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;

    await super.close();
  }

  Future<void> foundVersion(int current, int found) async {
    if (current >= found) {
      return;
    }

    loggy.warning(
        "Detected peer with higher protocol version (our:$current, their:$found)");

    await _settings.setHighestSeenProtocolNumber(found);

    emitUnlessClosed(true);
  }

  Future<void> _init() async {
    final current = await _session.getCurrentProtocolVersion();
    final stored = _settings.getHighestSeenProtocolNumber() ?? current;

    await foundVersion(current, stored);

    _subscription = _session.networkEvents.listen((event) async {
      switch (event) {
        case NetworkEvent.peerSetChange:
          break;
        case NetworkEvent.protocolVersionMismatch:
          {
            final highest = await _session.getHighestSeenProtocolVersion();
            await foundVersion(current, highest);
          }
          break;
      }
    });
  }
}
