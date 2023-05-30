import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart' as stray;
import 'package:window_manager/window_manager.dart';

import '../../../generated/l10n.dart';
import '../utils.dart';
import 'platform_window_manager.dart';

class PlatformWindowManagerDesktop
    with WindowListener
    implements PlatformWindowManager {
  PlatformWindowManagerDesktop() {
    initialize().then((_) async {
      windowManager.addListener(this);
      await windowManager.setPreventClose(true);
    });
  }

  final _systemTray = stray.SystemTray();
  final _appWindow = stray.AppWindow();

  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    /// If the user is using Wayland instead of X Windows on Linux, the app crashes with the error:
    /// (ouisync_app:8441): Gdk-CRITICAL **: 01:05:51.655: gdk_monitor_get_geometry: assertion 'GDK_IS_MONITOR (monitor)' failed
    /// A "fix" is to switch to X Windows (https://stackoverflow.com/questions/62809877/gdk-critical-exceptions-on-a-flutter-desktop-app-linux)
    /// Since we still don't know the real reason nor a real fix, we are skipping this configuration on Linux for now.
    if (!Platform.isLinux) {
      /// For some reason, if we use a constant value for the title in the
      /// WindowsOptions, the app hangs. This is true for the localized strings,
      /// or a regular constant value in Constants.
      /// So we use a harcoded string to start, then we use the localized string
      /// in app.dart -for now.
      WindowOptions windowOptions = const WindowOptions(
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        title: 'OuiSync',
        titleBarStyle: TitleBarStyle.normal,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  @override
  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? Constants.windowsAppIcon : Constants.appIcon;

    List<stray.MenuItemBase> menus = [
      stray.MenuItemLabel(
          label: S.current.actionExit,
          onClicked: (_) async {
            await windowManager.setPreventClose(false);
            await windowManager.close();
          }),
    ];

    await _systemTray.initSystemTray(
      title: S.current.titleAppTitle,
      iconPath: path,
      toolTip: S.current.messageOuiSyncDesktopTitle,
    );

    final menu = stray.Menu();
    await menu.buildFrom(menus);
    await _systemTray.setContextMenu(menu);

    _systemTray.registerSystemTrayEventHandler((eventName) async {
      switch (eventName) {
        case Constants.eventLeftMouseUp:
          await windowManager.isVisible()
              ? await _appWindow.hide()
              : await _appWindow.show();

          break;
        case Constants.eventRightMouseUp:
          await _systemTray.popUpContextMenu();
          break;

        default:
      }
    });
  }

  @override
  Future<void> setTitle(String title) async {
    WindowOptions windowOptions = WindowOptions(title: title);
    return windowManager.waitUntilReadyToShow(windowOptions, () {});
  }

  @override
  Future<bool> get isVisible async {
    return false;
    /*windowManager.isVisible();*/
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
  }

  @override
  Future<void> setPreventClose(bool isPreventClose) async {
    return windowManager.setPreventClose(isPreventClose);
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await _appWindow.hide();
    }
  }

  @override
  Future<void> close() async {
    return windowManager.close();
  }
}
