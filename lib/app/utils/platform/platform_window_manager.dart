import 'dart:io';

import 'platform.dart';

typedef CloseHandler = Future<void> Function();

abstract class PlatformWindowManager {
  static Future<PlatformWindowManager> create(
    List<String> args,
    String appName,
  ) => (Platform.isAndroid || Platform.isIOS)
      ? Future.value(PlatformWindowManagerMobile())
      : PlatformWindowManagerDesktop.create(args, appName);

  /// Sets the function to be called when the app is about to be closed.
  void onClose(CloseHandler handler);

  /// Sets the window title. Can be called only after localization has been initialized.
  Future<void> setTitle(String title);

  /// Initializes the system tray. Does nothing on platforms that don't have system tray. Can be
  /// called only after localization has been initialized.
  Future<void> initSystemTray();

  void dispose() {}
}
