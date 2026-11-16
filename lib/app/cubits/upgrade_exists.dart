import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../utils/utils.dart';
import 'utils.dart';

class UpgradeExistsCubit extends Cubit<bool> with CubitActions, AppLogger {
  final SessionProxy _session;
  final Settings _settings;
  StreamSubscription? _subscription;
  int _currentProtocolVersion = 0;

  UpgradeExistsCubit(SessionProxy session, Settings settings)
    : _session = session,
      _settings = settings,
      super(false) {
    _session.started.addListener(_onSessionStarted);
    unawaited(
      _init().catchError((e, st) => loggy.error('During _init():', e, st)),
    );
  }

  Future<void> _onSessionStarted() async {
    if (_session.started.value == 0) {
      return;
    }
    await _listenNetworkEvents();
  }

  @override
  Future<void> close() async {
    _session.started.removeListener(_onSessionStarted);
    await _subscription?.cancel();
    _subscription = null;

    await super.close();
  }

  Future<void> foundVersion(int current, int found) async {
    if (current >= found) {
      return;
    }

    loggy.warning(
      "Detected peer with higher protocol version (our:$current, their:$found)",
    );

    await _settings.setHighestSeenProtocolNumber(found);

    emitUnlessClosed(true);
  }

  Future<void> _init() async {
    _currentProtocolVersion = await _session.getCurrentProtocolVersion();
    final stored =
        _settings.getHighestSeenProtocolNumber() ?? _currentProtocolVersion;

    await foundVersion(_currentProtocolVersion, stored);

    unawaited(_onSessionStarted());
  }

  // Called on init, and again after the session has been recreated (see `SessionHandle`).
  Future<void> _listenNetworkEvents() async {
    unawaited(_subscription?.cancel());

    final events = await _session.networkEvents();
    _subscription = events.listen((event) async {
      switch (event) {
        case NetworkEvent.peerSetChange:
          break;
        case NetworkEvent.protocolVersionMismatch:
          {
            final highest = await _session.getHighestSeenProtocolVersion();
            await foundVersion(_currentProtocolVersion, highest);
          }
          break;
      }
    });
  }
}
