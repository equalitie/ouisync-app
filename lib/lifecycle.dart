import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

class LifeCycle extends StatefulWidget {
  const LifeCycle({
    required this.session,
    required this.child,
  });

  final Session session;
  final Widget child;

  @override
  _LifeCycleState createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> 
                      with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App Lyfecycle State: $state');
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    widget.session.close();
    super.dispose();
  }
}