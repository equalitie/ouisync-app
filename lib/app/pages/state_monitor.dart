import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';
import 'package:flutter/material.dart';

class StateMonitorPage extends StatefulWidget {
  const StateMonitorPage(this.session);

  final oui.Session session;

  @override
  State<StatefulWidget> createState() => _State(session);
}

class _State extends State<StateMonitorPage> {
  final oui.Session session;
  late final Subscription subscription;
  late final _Node root;

  _State(this.session) {
    root = _Node(session.getRootStateMonitor()!, this);
    subscription = root.monitor.subscribe()!;
  }

  @override
  void dispose() {
    subscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("State Monitor")),
      body: StreamBuilder<void>(
          stream: subscription.broadcastStream,
          builder: (BuildContext ctx, AsyncSnapshot<void> snapshot) {
            root.monitor.refresh();
            return Container(child: root.build());
          }
      )
    );
  }
}

class _Node {
  _Node(this.monitor, this.state);

  final StateMonitor monitor;
  final _State state;
  final Map<String, _Node> expandedChildren = {};

  Widget build() {
    if (monitor.path.isEmpty) {
      return ListView(children: buildValuesAndChildren());
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        child: Column(children: buildValuesAndChildren()));
    }
  }

  List<Widget> buildValuesAndChildren() =>
      monitor.values.entries.map((entry) => buildValue(entry.key, entry.value))
      .followedBy(monitor.children.entries.map((entry) => buildChild(entry.key, entry.value)))
      .toList();

  Widget buildValue(String key, String value) {
    return Card(child: ListTile(
      dense: true,
      title: Text("$key: $value")
    ));
  }

  Widget buildChild(String name, int version) {
    final expandedChild = expandedChildren[name];

    if (expandedChild == null) {
      return Card(child: ListTile(
        trailing: const Icon(Icons.add),
        dense: true,
        title: Text(name),
        onTap: () => expandChild(name)));
    }
    else {
      if (expandedChild.monitor.version < version) {
        expandedChild.monitor.refresh();
      }

      return Column(
        children: <Widget>[
          Card(child: ListTile(
            trailing: const Icon(Icons.remove),
            dense: true,
            title: Text(name),
            onTap: () => collapseChild(name))),
          expandedChild.build(),
        ]);
    }
  }

  void expandChild(String name) {
    final child = monitor.child(name);

    if (child == null) {
      return;
    }

    state.setState(() {
      expandedChildren[name] = _Node(child, state);
    });
  }

  void collapseChild(String name) {
    state.setState(() {
      expandedChildren.remove(name);
    });
  }
}
