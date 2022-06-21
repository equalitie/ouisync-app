import 'dart:async';

import 'platform_window_manager.dart';

class PlatformWindowManagerMobile implements PlatformWindowManager {
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
}
