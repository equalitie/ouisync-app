import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
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
    initialize();
  }

  final _systemTray = stray.SystemTray();
  final _appWindow = stray.AppWindow();

  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    windowManager.addListener(this);
    await windowManager.setPreventClose(true);

    const width = 700.0;
    const height = width * 1.3;

    doWhenWindowReady(() {
      const initialSize = Size(width, height);

      appWindow.maxSize = initialSize;
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;

      appWindow.alignment = Alignment.center;

      appWindow.show();
    });
  }

  @override
  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? Constants.windowsAppIcon : Constants.appIcon;

    await _systemTray.initSystemTray(
      title: S.current.titleAppTitle,
      iconPath: path,
      toolTip: S.current.messageOuiSyncDesktopTitle,
    );

    final menu = stray.Menu();
    await menu.buildFrom([
      stray.MenuItemLabel(
          label: S.current.actionExit,
          onClicked: (_) async {
            await windowManager.setPreventClose(false);
            await windowManager.close();
          }),
    ]);

    await _systemTray.setContextMenu(menu);

    _systemTray.registerSystemTrayEventHandler((eventName) async {
      debugPrint("eventName: $eventName");

      if (eventName == stray.kSystemTrayEventClick) {
        Platform.isWindows
            ? {
                await windowManager.isVisible()
                    ? await _appWindow.hide()
                    : await _appWindow.show()
              }
            : _systemTray.popUpContextMenu();
      } else if (eventName == stray.kSystemTrayEventRightClick) {
        Platform.isWindows
            ? _systemTray.popUpContextMenu()
            : {
                await windowManager.isVisible()
                    ? await _appWindow.hide()
                    : await _appWindow.show()
              };
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

    _systemTray.destroy();
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
