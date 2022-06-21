import 'dart:io';

import 'platform_window_manager_desktop.dart';
import 'platform_window_manager_mobile.dart';

abstract class PlatformWindowManager {
  factory PlatformWindowManager() {
    if (Platform.isWindows) {
      return PlatformWindowManagerDesktop();
    }
    return PlatformWindowManagerMobile();
  }

  Future<void> setTitle(String title);

  Future<void> initSystemTray();

  Future<bool> get isVisible;

  void dispose() {}

  Future<void> setPreventClose(bool isPreventClose);

  void onWindowClose() {}

  Future<void> close();
}
