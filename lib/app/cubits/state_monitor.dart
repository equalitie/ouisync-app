import 'package:ouisync_plugin/state_monitor.dart' as oui;
import 'package:flutter/material.dart';

class StateMonitor {
  oui.StateMonitor? _inner;

  StateMonitor(this._inner);

  StateMonitor child(String name) => StateMonitor(_inner?.child(name));

  StateMonitorIntValue intValue(String value_name) => StateMonitorIntValue(_inner, value_name);

  Widget builder(Widget Function(BuildContext, oui.StateMonitor?) buildFn) {
    return _Widget(_inner, buildFn);
  }
}

class StateMonitorIntValue {
  oui.StateMonitor? _inner;
  String _value_name;

  StateMonitorIntValue(this._inner, this._value_name);

  Widget builder(Widget Function(BuildContext, int? value) buildFn) {
    return _Widget(_inner, (BuildContext context, oui.StateMonitor? monitor) {
      return buildFn(context, monitor?.parseIntValue(_value_name));
    });
  }
}

class _Widget extends StatelessWidget {
  oui.StateMonitor? _monitor;
  Widget Function(BuildContext, oui.StateMonitor?) _buildFn;
  oui.Subscription? _subscription;

  _Widget(this._monitor, this._buildFn);

  @override
  void dispose() {
    _subscription?.close();
  }

  @override
  Widget build(BuildContext context) {
    final monitor = _monitor;
    if (monitor == null) return _buildFn(context, null);

    _subscription?.close();
    _subscription = monitor.subscribe();

    final subscription = _subscription;
    if (subscription == null) return _buildFn(context, null);

    return StreamBuilder<void>(
      stream: subscription.broadcastStream,
      builder: (BuildContext ctx, AsyncSnapshot<void> snapshot) {
        if (!monitor.refresh()) {
          return _buildFn(ctx, null);
        }

        return _buildFn(ctx, monitor);
      }
    );
  }
}
