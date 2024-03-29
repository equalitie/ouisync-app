import 'dart:async';
import 'dart:io' as io;

import '../log.dart';
import 'platform.dart';

class MediaReceiverLinux with AppLogger implements MediaReceiver {
  @override
  StreamController controller = StreamController<io.File>();

  @override
  void dispose() {
    controller.close();
  }
}
