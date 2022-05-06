import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:flutter/material.dart';

class StateMonitorPage extends StatelessWidget {
  final oui.Session session;
  final StateMonitor root;

  StateMonitorPage(this.session)
      : root = session.getRootStateMonitor()!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("State Monitor")),
      body: Container(child: _MonitorNode(root))
    );
  }
}

class _MonitorNode extends StatelessWidget {
  final StateMonitor monitor;
  final Map<String, StateMonitor> expandedChildren = Map();

  _MonitorNode(this.monitor);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: monitor.children.keys.map((key) {
        final child = expandedChildren[key];

        if (child == null) {
          return ListTile(title: Text(key));
        } else {
          return Container(
            child: ListView(
              children: <Widget>[
                ListTile(title: Text(key)),
                _MonitorNode(child)
              ]
            )
          );
        }
      }).toList(),
    );
  }
}
