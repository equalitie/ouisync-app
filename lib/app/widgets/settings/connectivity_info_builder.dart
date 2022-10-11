import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../cubits/cubits.dart';

class ConnectivityInfoBuilder extends StatefulWidget {
  final Session session;
  final PowerControl powerControl;
  final Widget Function(BuildContext, ConnectivityInfoState) builder;

  ConnectivityInfoBuilder(
      {required this.session,
      required this.powerControl,
      required this.builder});

  @override
  State<ConnectivityInfoBuilder> createState() =>
      _ConnectivityInfoBuilderState();
}

class _ConnectivityInfoBuilderState extends State<ConnectivityInfoBuilder> {
  final ConnectivityInfo _connectivityInfo = ConnectivityInfo();

  _ConnectivityInfoBuilderState();

  @override
  void initState() {
    super.initState();
    unawaited(_connectivityInfo.update(widget.session));
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<PowerControl, PowerControlState>(
        bloc: widget.powerControl,
        listener: (context, state) {
          unawaited(_connectivityInfo.update(widget.session));
        },
        child: BlocBuilder<ConnectivityInfo, ConnectivityInfoState>(
          bloc: _connectivityInfo,
          builder: widget.builder,
        ),
      );
}
