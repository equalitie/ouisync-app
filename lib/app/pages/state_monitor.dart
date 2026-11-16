import 'package:ouisync_app/app/utils/session_handle.dart' show SessionProxy;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show StateMonitorCubit;
import '../widgets/widgets.dart' show DirectionalAppBar;

class StateMonitorPage extends StatefulWidget {
  final SessionProxy session;

  StateMonitorPage(this.session);

  @override
  State<StateMonitorPage> createState() => _StateMonitorState();
}

class _StateMonitorState extends State<StateMonitorPage> {
  StateMonitorCubit? root;

  @override
  void initState() {
    super.initState();
    widget.session.started.addListener(_onSessionStarted);
    _onSessionStarted();
  }

  // The session is replaced after a reset (e.g. on resume), which silently kills the monitor's
  // `changes` stream, so rebuild the root against the new session.
  void _onSessionStarted() {
    if (widget.session.started.value == 0) {
      return;
    }
    unawaited(_init());
  }

  Future<void> _init() async {
    if (!mounted) return;
    final old = root;
    unawaited(old?.close());
    final monitor = await widget.session.getRootStateMonitor();
    setState(() => root = StateMonitorCubit(monitor));
  }

  @override
  void dispose() {
    widget.session.started.removeListener(_onSessionStarted);
    unawaited(root?.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DirectionalAppBar(title: Text(S.current.titleStateMonitor)),
    body: Theme(
      data: ThemeData(
        cardTheme: CardThemeData(margin: EdgeInsetsDirectional.all(1.0)),
        listTileTheme: ListTileThemeData(dense: true),
      ),
      child: switch (root) {
        // Keyed by cubit so expanded children are discarded along with the old root.
        final root? => _NodeWidget(root, key: ValueKey(root)),
        null => const Center(child: CircularProgressIndicator()),
      },
    ),
  );
}

class _NodeWidget extends StatelessWidget {
  final StateMonitorCubit cubit;

  _NodeWidget(this.cubit, {super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<StateMonitorCubit, StateMonitorNode?>(
    bloc: cubit,
    builder: (context, node) {
      if (node == null) {
        // node not loaded yet
        return SizedBox.shrink();
      }

      if (cubit.isRoot) {
        // root node - use `ListView` to enable scrolling
        return ListView(children: buildValuesAndChildren(node));
      }

      // child node - use regular `Column` because we are already inside `ListView`.
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
        child: Column(children: buildValuesAndChildren(node)),
      );
    },
  );

  List<Widget> buildValuesAndChildren(StateMonitorNode node) => node
      .values
      .entries
      .map((entry) => buildValue(entry.key, entry.value))
      .followedBy(node.children.map((id) => buildChild(id)))
      .toList();

  Widget buildValue(String key, String value) {
    return Card(child: ListTile(title: Text("$key: $value")));
  }

  Widget buildChild(MonitorId childId) => _ChildWidget(cubit, childId);
}

class _ChildWidget extends StatefulWidget {
  final StateMonitorCubit parentCubit;
  final MonitorId id;

  _ChildWidget(this.parentCubit, this.id) : super(key: Key(id.toString()));

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
          title: Text(widget.id.name),
          onTap: expand,
        ),
      );
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

  void collapse() {
    final old = cubit;
    setState(() => cubit = null);
    unawaited(old?.close());
  }
}
