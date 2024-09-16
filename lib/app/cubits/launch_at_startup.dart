import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/constants.dart';
import '../cubits/utils.dart';

/// Cubit that controls whether the app should be launched at device startup. The state is a
/// boolean indicating whether the launch at startup is enabled.
class LaunchAtStartupCubit extends Cubit<bool> {
  LaunchAtStartupCubit() : super(false) {
    unawaited(_init());
  }

  /// Enable/disable launch at startup.
  Future<void> setEnabled(bool value) async {
    if (!_isSupported) return;

    if (value) {
      await LaunchAtStartup.instance.enable();
    } else {
      await LaunchAtStartup.instance.disable();
    }

    await _update();
  }

  Future<void> _init() async {
    if (!_isSupported) return;

    final packageInfo = await PackageInfo.fromPlatform();

    LaunchAtStartup.instance.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      args: [Constants.launchAtStartupArg],
    );

    await _update();
  }

  Future<void> _update() async {
    emitUnlessClosed(await LaunchAtStartup.instance.isEnabled());
  }
}

bool get _isSupported =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;
