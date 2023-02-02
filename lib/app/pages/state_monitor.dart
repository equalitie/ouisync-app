import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';

import '../../generated/l10n.dart';

class StateMonitorPage extends StatefulWidget {
  const StateMonitorPage(this.session);

  final oui.Session session;

  @override
  State<StatefulWidget> createState() => _State(session);
}

class _State extends State<StateMonitorPage> {
  final oui.Session session;
  final Future<StateMonitor> root;
  Subscription? subscription;

  _State(this.session) : root = session.getRootStateMonitor();

  @override
  void dispose() {
    if (subscription != null) {
      unawaited(subscription!.close());
      subscription = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.current.titleStateMonitor)),
        body: FutureBuilder(
            future: root,
            builder: (context, snapshot) {
              final root = snapshot.data;
              if (root == null) {
                return Container();
              }

              subscription ??= root.subscribe();

              return StreamBuilder<void>(
                  stream: subscription!.stream.asBroadcastStream(),
                  builder: (BuildContext ctx, AsyncSnapshot<void> snapshot) {
                    root.refresh();
                    return Container(child: _NodeWidget(root));
                  });
            }),
      );
}

class _NodeWidget extends StatelessWidget {
  final StateMonitor monitor;

  _NodeWidget(this.monitor);

  @override
  Widget build(BuildContext context) {
    if (monitor.path.isEmpty) {
      return ListView(children: buildValuesAndChildren());
    } else {
      return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Column(children: buildValuesAndChildren()));
    }
  }

  List<Widget> buildValuesAndChildren() => monitor.values.entries
      .map((entry) => buildValue(entry.key, entry.value))
      .followedBy(monitor.children.entries
          .map((entry) => buildChild(entry.key, entry.value)))
      .toList();

  Widget buildValue(String key, String value) {
    return Card(child: ListTile(dense: true, title: Text("$key: $value")));
  }

  Widget buildChild(MonitorId childId, int version) =>
      _ChildWidget(monitor, childId, version);
}

class _ChildWidget extends StatefulWidget {
  final StateMonitor parent;
  final MonitorId id;
  final int version;

  _ChildWidget(this.parent, this.id, this.version)
      : super(key: Key(id.toString()));

  @override
  State<_ChildWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<_ChildWidget> {
  StateMonitor? monitor;

  @override
  Widget build(BuildContext context) {
    final monitor = this.monitor;

    if (monitor != null) {
      if (monitor.version < widget.version) {
        monitor.refresh();
      }

      return Column(children: <Widget>[
        Card(
            child: ListTile(
                trailing: const Icon(Icons.remove),
                dense: true,
                title: Text(widget.id.name),
                onTap: collapse)),
        _NodeWidget(monitor),
      ]);
    } else {
      return Card(
          child: ListTile(
              trailing: const Icon(Icons.add),
              dense: true,
              title: Text(widget.id.name),
              onTap: expand));
    }
  }

  void expand() async {
    final child = await widget.parent.child(widget.id);

    setState(() {
      monitor = child;
    });
  }

  void collapse() {
    setState(() {
      monitor = null;
    });
  }
}
