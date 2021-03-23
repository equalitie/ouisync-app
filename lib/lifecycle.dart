
import 'package:flutter/material.dart';

import 'callbacks/nativecallbacks.dart';


class LifeCycle extends StatefulWidget {
  const LifeCycle({
    @required this.child,
  }): assert(child != null);

  final Widget child;

  @override
  _LifeCycleState createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> 
                      with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    NativeCallbacks.doSetup();

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
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}