import 'dart:async';
import 'dart:io';

import 'platform.dart';

abstract class MediaReceiver {
  factory MediaReceiver() {
    if (Platform.isWindows) {
      return MediaReceiverWindows();
    }

    if (Platform.isLinux) {
      return MediaReceiverLinux();
    }

    return MediaReceiverMobile();
  }

  StreamController<dynamic> controller = StreamController<dynamic>();

  void dispose() {
    controller.close();
  }
}
