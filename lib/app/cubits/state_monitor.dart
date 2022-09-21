import 'package:ouisync_plugin/state_monitor.dart' as oui;
import 'package:flutter/material.dart';

class StateMonitor {
  final oui.StateMonitor? _inner;

  StateMonitor(this._inner);

  StateMonitor child(String name) => StateMonitor(_inner?.child(name));

  StateMonitorIntValue intValue(String valueName) =>
      StateMonitorIntValue(_inner, valueName);

  Widget builder(Widget Function(BuildContext, oui.StateMonitor?) buildFn) {
    return _Widget(_inner, buildFn);
  }
}

class StateMonitorIntValue {
  final oui.StateMonitor? _inner;
  final String _valueName;

  StateMonitorIntValue(this._inner, this._valueName);

  Widget builder(Widget Function(BuildContext, int? value) buildFn) {
    return _Widget(_inner, (BuildContext context, oui.StateMonitor? monitor) {
      return buildFn(context, monitor?.parseIntValue(_valueName));
    });
  }
}

class _Widget extends StatefulWidget {
  final oui.StateMonitor? _monitor;
  final Widget Function(BuildContext, oui.StateMonitor?) _buildFn;

  _Widget(this._monitor, this._buildFn);

  @override
  State<_Widget> createState() => _WidgetState();
}

class _WidgetState extends State<_Widget> {
  oui.Subscription? _subscription;

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monitor = widget._monitor;
    if (monitor == null) return widget._buildFn(context, null);

    _subscription?.close();
    _subscription = monitor.subscribe();

    final subscription = _subscription;
    if (subscription == null) return widget._buildFn(context, null);

    return StreamBuilder<void>(
        stream: subscription.broadcastStream,
        builder: (BuildContext ctx, AsyncSnapshot<void> snapshot) {
          if (!monitor.refresh()) {
            return widget._buildFn(ctx, null);
          }

          return widget._buildFn(ctx, monitor);
        });
  }
}
