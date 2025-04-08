import 'dart:async';

import 'package:ouisync/state_monitor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils.dart';

class StateMonitorCubit extends Cubit<StateMonitorNode?> with CubitActions {
  final StateMonitor _monitor;

  StateMonitorCubit(this._monitor) : super(null) {
    unawaited(_init());
  }

  bool get isRoot => _monitor.isRoot;

  Future<void> _init() async {
    await _load();

    await for (final _ in _monitor.changes) {
      await _load();
    }
  }

  Future<void> _load() async {
    final node = await _monitor.load();
    emitUnlessClosed(node);
  }

  StateMonitorCubit child(MonitorId id) =>
      StateMonitorCubit(_monitor.child(id));
}

class StateMonitorIntCubit extends Cubit<int?> with CubitActions {
  final StateMonitor _monitor;
  final String _name;

  StateMonitorIntCubit(this._monitor, this._name) : super(null) {
    unawaited(_init());
  }

  Future<void> _init() async {
    await _load();

    await for (final _ in _monitor.changes) {
      await _load();
    }
  }

  Future<void> _load() async {
    final node = await _monitor.load();
    emitUnlessClosed(node?.parseIntValue(_name));
  }
}
