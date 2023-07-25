import 'dart:io';

import 'platform.dart';

abstract class PlatformWindowManager {
  factory PlatformWindowManager(bool showWindow) {
    if (Platform.isAndroid || Platform.isIOS) {
      return PlatformWindowManagerMobile(showWindow);
    }
    return PlatformWindowManagerDesktop(showWindow);
  }

  Future<void> setTitle(String title);

  Future<void> initSystemTray();

  Future<bool> get isVisible;

  void dispose() {}

  Future<void> setPreventClose(bool isPreventClose);

  void onWindowClose() {}

  Future<void> close();

  Future<bool> launchAtStartup(bool enable);
}
