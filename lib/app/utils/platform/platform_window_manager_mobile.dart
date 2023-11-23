import 'dart:async';

import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../log.dart';
import 'platform_window_manager.dart';

class PlatformWindowManagerMobile
    with AppLogger
    implements PlatformWindowManager {
  @override
  set session(Session value) {}

  @override
  Future<bool> launchAtStartup(bool enable) async {
    loggy.app('This function is not avaliable on mobile');
    return false;
  }

  @override
  Future<void> setTitle(String title) async {}

  @override
  Future<void> initSystemTray() async {}

  @override
  void dispose() {}
}
