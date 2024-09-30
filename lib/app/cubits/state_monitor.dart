import 'dart:async';

import 'package:ouisync/state_monitor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils.dart';

class StateMonitorCubit extends Cubit<StateMonitorNode?> with CubitActions {
  final StateMonitor _monitor;
  final Subscription _subscription;

  StateMonitorCubit(this._monitor)
      : _subscription = _monitor.subscribe(),
        super(null) {
    unawaited(_init());
  }

  Future<void> _init() async {
    await _load();

    await for (final _ in _subscription.stream) {
      await _load();
    }
  }

  Future<void> _load() async {
    final node = await _monitor.load();
    emitUnlessClosed(node);
  }

  @override
  Future<void> close() async {
    await _subscription.close();
    await super.close();
  }

  StateMonitorCubit child(MonitorId id) =>
      StateMonitorCubit(_monitor.child(id));
}

class StateMonitorIntCubit extends Cubit<int?> with CubitActions {
  final StateMonitor _monitor;
  final String _name;
  final Subscription _subscription;

  StateMonitorIntCubit(this._monitor, this._name)
      : _subscription = _monitor.subscribe(),
        super(null) {
    unawaited(_init());
  }

  Future<void> _init() async {
    await _load();

    await for (final _ in _subscription.stream) {
      await _load();
    }
  }

  Future<void> _load() async {
    final node = await _monitor.load();
    emitUnlessClosed(node?.parseIntValue(_name));
  }

  @override
  Future<void> close() async {
    await _subscription.close();
    await super.close();
  }
}
