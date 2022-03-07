import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'app/utils/globals.dart';

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
    switch (state) {
      case AppLifecycleState.inactive:
        print('[Lifecycle: inactive] repositories: ${repositoriesService.repositories}');
        break;
      case AppLifecycleState.paused:
        print('[Lifecycle: paused] repositories: ${repositoriesService.repositories}');
        break;
      case AppLifecycleState.detached:
        print('[Lifecycle: detached] repositories: ${repositoriesService.repositories}');
        repositoriesService.close();
        break;
      case AppLifecycleState.resumed:
        print('[Lifecycle: resumed] repositories: ${repositoriesService.repositories}');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    widget.session.close();
    super.dispose();
  }
}