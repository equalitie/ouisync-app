import 'dart:async';
import 'dart:io' as io;

import '../loggers/ouisync_app_logger.dart';
import 'platform.dart';

class MediaReceiverLinux with OuiSyncAppLogger implements MediaReceiver {
  @override
  StreamController controller = StreamController<io.File>();

  @override
  void dispose() {
    controller.close();
  }
}
