import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart' as stray;
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import '../../../generated/l10n.dart';
import '../utils.dart';
import 'platform_window_manager.dart';

class PlatformWindowManagerDesktop
    with WindowListener, AppLogger
    implements PlatformWindowManager {
  final _systemTray = stray.SystemTray();
  final String _appName;
  var _showWindow = true;
  var _state = _State.open;
  CloseHandler? _onClose;

  PlatformWindowManagerDesktop._(this._appName);

  static Future<PlatformWindowManagerDesktop> create(
    List<String> args,
    String appName,
  ) async {
    final manager = PlatformWindowManagerDesktop._(appName);
    await manager._init(args);
    return manager;
  }

  @override
  void onClose(CloseHandler handler) {
    _onClose = handler;
  }

  @override
  Future<void> setTitle(String title) async {
    WindowOptions windowOptions = WindowOptions(title: title);
    return windowManager.waitUntilReadyToShow(windowOptions, () {});
  }

  @override
  Future<void> initSystemTray() async {
    await windowManager.setPreventClose(true);

    String path =
        Platform.isWindows ? Constants.windowsAppIcon : Constants.appIcon;

    // On Windows, the system tray title is shown only when howering over the
    // icon, but on Linux it is always visible next to it. That's in my
    // experience is unlike how other apps behave. So turning it off on Linux.
    // edit: same goes for macOS; the title has its uses, but not in this case.
    final systemTrayTitle = Platform.isWindows ? S.current.titleAppTitle : null;

    await _systemTray.initSystemTray(
      title: systemTrayTitle,
      iconPath: path,
      toolTip: S.current.messageOuiSyncDesktopTitle,
    );

    final menu = stray.Menu();
    await menu.buildFrom([
      if (Platform.isLinux || Platform.isMacOS)
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
  void dispose() {
    windowManager.removeListener(this);
    _systemTray.destroy();
  }

  Future<void> _init(List<String> args) async {
    await _ensureWindowsSingleInstance(args, _appName);

    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    // Graceful termination on SIGINT (e.g. Ctrl+C)
    unawaited(_handleSignal(ProcessSignal.sigint.watch()));

    // Graceful termination on SIGTERM (e.g. 'killall ouisync-gui')
    if (Platform.isLinux || Platform.isMacOS) {
      unawaited(_handleSignal(ProcessSignal.sigterm.watch()));
    }

    if (args.isNotEmpty) {
      _showWindow = args[0] == Constants.launchAtStartupArg ? false : true;
    }

    /// For some reason, if we use a constant value for the title in the
    /// WindowsOptions, the app hangs. This is true for the localized strings,
    /// or a regular constant value in Constants.
    /// So we use a hardcoded string to start, then we use the localized string
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

    await windowManager.waitUntilReadyToShow(windowOptions);
    await _toggleVisible(_showWindow);
  }

  @override
  void onWindowClose() async {
    // By default (when state is `open`), closing the window only minimizes it to the tray. When
    // the user clicks "Exit" in the tray menu, state is switched to `closing` and the onClose
    // handler is called. Window close prevention is still enabled so the close handler can
    // complete. Afterwards the close prevention is disabled and the window is closed again, which
    // then actually closes the window and exits the app.
    switch (_state) {
      case _State.open:
        await _toggleVisible(false);
        break;
      case _State.closing:
        final onClose = _onClose;
        if (onClose != null) {
          await onClose();
        }

        _state = _State.closed;
        await windowManager.setPreventClose(false);
        await windowManager.close();
        break;
      case _State.closed:
        await windowManager.destroy();
    }
  }

  Future<void> _ensureWindowsSingleInstance(
      List<String> args, String pipeName) async {
    if (!Platform.isWindows) {
      return;
    }

    await WindowsSingleInstance.ensureSingleInstance(args, pipeName,
        onSecondWindow: (args) {
      loggy.debug(args);
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

Future<void> _toggleVisible([bool? visible]) async {
  visible ??= !await windowManager.isVisible();
  await windowManager.setSkipTaskbar(!visible);
  if (visible) {
    await windowManager.show();
    await windowManager.focus();
  } else {
    await windowManager.hide();
  }
}

enum _State {
  open,
  closing,
  closed,
}
