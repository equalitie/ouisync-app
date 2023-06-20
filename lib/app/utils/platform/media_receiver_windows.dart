import 'dart:async';
import 'dart:io' as io;

import '../log.dart';
import 'platform.dart';

class MediaReceiverWindows with OuiSyncAppLogger implements MediaReceiver {
  @override
  StreamController controller = StreamController<io.File>();

  @override
  void dispose() {
    controller.close();
  }
}
