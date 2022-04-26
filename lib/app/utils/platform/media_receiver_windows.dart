import 'dart:async';
import 'dart:io' as io;

import '../loggers/ouisync_app_logger.dart';
import 'media_receiver.dart';

class MediaReceiverWindows with OuiSyncAppLogger implements MediaReceiver {
  @override
  StreamController controller = StreamController<io.File>();

  MediaReceiver getMedia() => MediaReceiverWindows();

  @override
  void dispose() {
    controller.close();
  }
}
