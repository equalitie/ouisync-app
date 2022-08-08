import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart' as stray;
import 'package:window_manager/window_manager.dart';

import '../../../generated/l10n.dart';
import '../utils.dart';
import 'platform_window_manager.dart';

class PlatformWindowManagerDesktop with WindowListener implements PlatformWindowManager {
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
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  @override
  Future<void> initSystemTray() async {
    String path = Platform.isWindows ? Constants.windowsAppIcon : Constants.appIcon;

    List<stray.MenuItemBase> menu = [
      stray.MenuItem(
        label: S.current.actionExit,
        onClicked: () async {
          await windowManager.setPreventClose(false);
          await windowManager.close();
        }),
    ];

    await _systemTray.initSystemTray(
      title: S.current.titleAppTitle,
      iconPath: path,
      toolTip: S.current.messageOuiSyncDesktopTitle,
    );

    await _systemTray.setContextMenu(menu);

    _systemTray.registerSystemTrayEventHandler((eventName) async {
      switch (eventName) {
        case Constants.eventLeftMouseUp:
          await windowManager.isVisible()
          ? _appWindow.hide()
          : _appWindow.show();

          break;
        case Constants.eventRightMouseUp:
          _systemTray.popUpContextMenu();

          break;
        
        default:
      }
    });
  }

  @override
  Future<void> setTitle(String title) async {
    WindowOptions windowOptions = WindowOptions(
      title: title);
    return windowManager.waitUntilReadyToShow(windowOptions, () {});
  }

  @override
  Future<bool> get isVisible async { return false;/*windowManager.isVisible();*/ }

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
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      _appWindow.hide();
    }
  }
  
  @override
  Future<void> close() async {
    return windowManager.close();
  }

}