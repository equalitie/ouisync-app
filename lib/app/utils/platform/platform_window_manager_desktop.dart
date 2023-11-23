import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:system_tray/system_tray.dart' as stray;
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../utils.dart';
import 'platform_window_manager.dart';

class PlatformWindowManagerDesktop
    with WindowListener, AppLogger
    implements PlatformWindowManager {
  final Session _session;
  final _systemTray = stray.SystemTray();

  late final String _appName;
  bool _showWindow = true;
  var _state = _State.open;

  PlatformWindowManagerDesktop(List<String> args, this._session) {
    initialize(args).then((_) async {
      windowManager.addListener(this);
      await windowManager.setPreventClose(true);
    });
  }

  Future<void> initialize(List<String> args) async {
    await windowManager.ensureInitialized();

    // Graceful termination on SIGINT and SIGTERM.
    unawaited(_handleSignal(ProcessSignal.sigint.watch()));
    unawaited(_handleSignal(ProcessSignal.sigterm.watch()));

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;

    if (args.isNotEmpty) {
      _showWindow = args[0] == Constants.launchAtStartupArg ? false : true;
    }

    await _ensureWindowsSingleInstance(args, _appName);

    /// Neither these suations seems to be true any more [Tested on Ubuntu 22.04.3 LTS - 2023-09-22]
    /// TODO: Remove this comment after more testing
    /// If the user is using Wayland instead of X Windows on Linux, the app crashes with the error:
    /// (ouisync_app:8441): Gdk-CRITICAL **: 01:05:51.655: gdk_monitor_get_geometry: assertion 'GDK_IS_MONITOR (monitor)' failed
    /// A "fix" is to switch to X Windows (https://stackoverflow.com/questions/62809877/gdk-critical-exceptions-on-a-flutter-desktop-app-linux)
    /// Since we still don't know the real reason nor a real fix, we are skipping this configuration on Linux for now.
    /// *****************
    /// For some reason, if we use a constant value for the title in the
    /// WindowsOptions, the app hangs. This is true for the localized strings,
    /// or a regular constant value in Constants.
    /// So we use a harcoded string to start, then we use the localized string
    /// in app.dart -for now.

    // Make it usable on older HD displays.
    const initWidth = 650.0;
    const initHeight = 700.0;

    const initialSize = Size(initWidth, initHeight);

    const minWidth = 320.0;
    const minHeight = 200.0;

    const minSize = Size(minWidth, minHeight);

    WindowOptions windowOptions = const WindowOptions(
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'Ouisync',
        size: initialSize,
        minimumSize: minSize);

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (_showWindow) {
        await windowManager.show();
        await windowManager.focus();
      }
    });
  }

  @override
  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? Constants.windowsAppIcon : Constants.appIcon;

    // On Windows, the system tray title is shown only when howering over the
    // icon, but on Linux it is always visible next to it. That's in my
    // experience is unlike how other apps behave. So turning it off on Linux.
    final systemTrayTitle = Platform.isLinux ? null : S.current.titleAppTitle;

    await _systemTray.initSystemTray(
      title: systemTrayTitle,
      iconPath: path,
      toolTip: S.current.messageOuiSyncDesktopTitle,
    );

    final menu = stray.Menu();
    await menu.buildFrom([
      if (Platform.isLinux)
        stray.MenuItemLabel(
          label: '${S.current.actionHide} / ${S.current.actionShow}',
          onClicked: (_) => _toggleVisible(),
        ),
      stray.MenuItemLabel(
        label: S.current.actionExit,
        onClicked: (_) => _close(),
      ),
    ]);

    await _systemTray.setContextMenu(menu);

    _systemTray.registerSystemTrayEventHandler((eventName) async {
      loggy.debug("eventName: $eventName");

      if (eventName == stray.kSystemTrayEventClick) {
        Platform.isWindows
            ? await _toggleVisible()
            : await _systemTray.popUpContextMenu();
      } else if (eventName == stray.kSystemTrayEventRightClick) {
        Platform.isWindows
            ? await _systemTray.popUpContextMenu()
            : await _toggleVisible();
      }
    });
  }

  @override
  Future<void> setTitle(String title) async {
    WindowOptions windowOptions = WindowOptions(title: title);
    return windowManager.waitUntilReadyToShow(windowOptions, () {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);

    _systemTray.destroy();
  }

  @override
  void onWindowClose() async {
    // By default (when state is `open`), closing the window only minimizes it to the tray. When
    // the user clicks "Exit" in the tray menu, state is switched to `closing` and the session
    // close is initiated. Window close prevention is still enabled so the session closing can
    // complete. Afterwards the close prevention is disabled and the window is closed again, which
    // then actually closes the window and exits the app.
    switch (_state) {
      case _State.open:
        await windowManager.hide();
        break;
      case _State.closing:
        await _session.close();
        _state = _State.closed;
        await windowManager.setPreventClose(false);
        await windowManager.close();
        break;
      case _State.closed:
        break;
    }
  }

  @override
  Future<bool> launchAtStartup(bool enable) async {
    LaunchAtStartup.instance.setup(
        appName: _appName,
        appPath: Platform.resolvedExecutable,
        args: [Constants.launchAtStartupArg]);

    return enable
        ? await LaunchAtStartup.instance.enable()
        : await LaunchAtStartup.instance.disable();
  }

  Future<void> _ensureWindowsSingleInstance(
      List<String> args, String pipeName) async {
    if (!Platform.isWindows) {
      return;
    }

    await WindowsSingleInstance.ensureSingleInstance(args, pipeName,
        onSecondWindow: (args) {
      print(args);
    });
  }

  Future<void> _handleSignal(Stream<ProcessSignal> signals) async {
    await signals.first;
    await _close();
  }

  Future<void> _close() async {
    if (_state != _State.open) {
      return;
    }

    _state = _State.closing;
    await windowManager.close();
  }
}

Future<void> _toggleVisible() async {
  if (await windowManager.isVisible()) {
    await windowManager.hide();
  } else {
    await windowManager.show();
  }
}

enum _State {
  open,
  closing,
  closed,
}
