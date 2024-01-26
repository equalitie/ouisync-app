import 'dart:io';

import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'platform.dart';

abstract class PlatformWindowManager {
  static Future<PlatformWindowManager> create(
    List<String> args,
    String appName,
  ) =>
      (Platform.isAndroid || Platform.isIOS)
          ? Future.value(PlatformWindowManagerMobile())
          : PlatformWindowManagerDesktop.create(args, appName);

  set session(Session value);

  Future<bool> launchAtStartup(bool enable);

  /// Sets the window title. Can be called only after localization has been initialized.
  Future<void> setTitle(String title);

  /// Initializes the system tray. Does nothing on platforms that don't have system tray. Can be
  /// called only after localization has been initialized.
  Future<void> initSystemTray();

  void dispose() {}
}
