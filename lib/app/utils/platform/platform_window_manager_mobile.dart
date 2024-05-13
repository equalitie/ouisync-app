import 'dart:async';

import '../log.dart';
import 'platform_window_manager.dart';

class PlatformWindowManagerMobile
    with AppLogger
    implements PlatformWindowManager {
  @override
  void onClose(CloseHandler handler) {}

  @override
  Future<void> setTitle(String title) async {}

  @override
  Future<void> initSystemTray() async {}

  @override
  void dispose() {}
}
