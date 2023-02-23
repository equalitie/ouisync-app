import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';

import '../cubits/cubits.dart';
import '../../generated/l10n.dart';

class StateMonitorPage extends StatefulWidget {
  final oui.Session session;

  StateMonitorPage(this.session);

  @override
  State<StateMonitorPage> createState() => _StateMonitorState();
}

class _StateMonitorState extends State<StateMonitorPage> {
  late final StateMonitorCubit root;

  _StateMonitorState();

  @override
  void initState() {
    super.initState();
    root = StateMonitorCubit(widget.session.rootStateMonitor);
  }

  @override
  void dispose() {
    unawaited(root.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.current.titleStateMonitor)),
        body: _NodeWidget(root),
      );
}

class _NodeWidget extends StatelessWidget {
  final StateMonitorCubit cubit;

  _NodeWidget(this.cubit);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StateMonitorCubit, StateMonitorNode?>(
          bloc: cubit,
          builder: (context, node) {
            if (node == null) {
              return ListView(children: const []);
            }

            if (node.path.isEmpty) {
              return ListView(children: buildValuesAndChildren(node));
            }

            return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(children: buildValuesAndChildren(node)));
          });

  List<Widget> buildValuesAndChildren(StateMonitorNode node) =>
      node.values.entries
          .map((entry) => buildValue(entry.key, entry.value))
          .followedBy(node.children.entries
              .map((entry) => buildChild(entry.key, entry.value)))
          .toList();

  Widget buildValue(String key, String value) {
    return Card(child: ListTile(dense: true, title: Text("$key: $value")));
  }

  Widget buildChild(MonitorId childId, int version) =>
      _ChildWidget(cubit, childId, version);
}

class _ChildWidget extends StatefulWidget {
  final StateMonitorCubit parentCubit;
  final MonitorId id;
  final int version; // TODO: do we need the version?

  _ChildWidget(this.parentCubit, this.id, this.version)
      : super(key: Key(id.toString()));

  @override
  State<_ChildWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<_ChildWidget> {
  StateMonitorCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final cubit = this.cubit;

    if (cubit != null) {
      return Column(
        children: <Widget>[
          Card(
            child: ListTile(
              trailing: const Icon(Icons.remove),
              dense: true,
              title: Text(widget.id.name),
              onTap: collapse,
            ),
          ),
          _NodeWidget(cubit),
        ],
      );
    } else {
      return Card(
          child: ListTile(
              trailing: const Icon(Icons.add),
              dense: true,
              title: Text(widget.id.name),
              onTap: expand));
    }
  }

  @override
  void dispose() {
    unawaited(cubit?.close());
    cubit = null;

    super.dispose();
  }

  void expand() {
    final child = widget.parentCubit.child(widget.id);

    setState(() {
      cubit = child;
    });
  }

  Future<void> collapse() async {
    await cubit?.close();

    setState(() {
      cubit = null;
    });
  }
}
