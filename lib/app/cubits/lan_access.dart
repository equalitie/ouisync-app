import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionActions, PermissionStatus, openAppSettings;

enum LanAccessState { unknown, granted, denied, permanentlyDenied }

class LanAccessCubit extends Cubit<LanAccessState> with WidgetsBindingObserver {
  // Whether LAN access permissions are enforced. Currently they are enforced only on Android SDK 37 and higher.
  final bool _active = Platform.isAndroid;

  LanAccessCubit() : super(.unknown) {
    if (_active) {
      WidgetsBinding.instance.addObserver(this);
      unawaited(_refresh());
    } else {
      emit(.granted);
    }
  }

  Future<void> request() async {
    if (!_active) {
      return;
    }

    switch (state) {
      case .denied:
        await Permission.accessLocalNetwork.request();
        await _refresh();
      case .permanentlyDenied:
        await openAppSettings();
        await _refresh();
      default:
    }
  }

  @override
  Future<void> close() async {
    if (_active) {
      WidgetsBinding.instance.removeObserver(this);
    }

    await super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh on app resume. This handles the case when the user changes the permission in the system settings.
    if (state == .resumed) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    final status = await Permission.accessLocalNetwork.status;

    switch (status) {
      case PermissionStatus.denied:
        emit(.denied);
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        emit(.granted);
      case PermissionStatus.restricted:
        emit(.unknown);
      case PermissionStatus.permanentlyDenied:
        emit(.permanentlyDenied);
    }
  }
}
