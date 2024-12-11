import 'dart:async';

import 'package:ouisync/state_monitor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'utils.dart';

class StateMonitorCubit extends Cubit<StateMonitorNode?> with CubitActions {
  final StateMonitor _monitor;
  StreamSubscription<void>? _subscription;

  StateMonitorCubit(this._monitor) : super(null) {
    _subscription =
        _monitor.changes.asyncMapSample((_) => _load()).listen(null);
    unawaited(_load());
  }

  Future<void> _load() async {
    final node = await _monitor.load();
    emitUnlessClosed(node);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }

  StateMonitorCubit child(MonitorId id) =>
      StateMonitorCubit(_monitor.child(id));
}

class StateMonitorIntCubit extends Cubit<int?> with CubitActions {
  final StateMonitor _monitor;
  final String _name;
  StreamSubscription<void>? _subscription;

  StateMonitorIntCubit(this._monitor, this._name) : super(null) {
    _subscription =
        _monitor.changes.asyncMapSample((_) => _load()).listen(null);
    unawaited(_load());
  }

  Future<void> _load() async {
    final node = await _monitor.load();
    emitUnlessClosed(node?.parseIntValue(_name));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
