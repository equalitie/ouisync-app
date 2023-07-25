import 'dart:async';

import '../log.dart';
import 'platform_window_manager.dart';

class PlatformWindowManagerMobile
    with AppLogger
    implements PlatformWindowManager {
  PlatformWindowManagerMobile(_);

  @override
  void dispose() {}

  @override
  Future<void> setTitle(String title) async {}

  @override
  Future<void> setPreventClose(bool isPreventClose) async {}

  @override
  Future<void> initSystemTray() async {}

  @override
  Future<bool> get isVisible async => false;

  @override
  void onWindowClose() {}

  @override
  Future<void> close() async {}

  @override
  Future<bool> launchAtStartup(bool enable) async {
    loggy.app('This function is not avaliable on mobile');
    return false;
  }
}
