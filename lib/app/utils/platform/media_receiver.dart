import 'dart:async';
import 'dart:io';

import 'platform.dart';

abstract class MediaReceiver {
  factory MediaReceiver(){
    if (Platform.isWindows) {
      return MediaReceiverWindows();
    }
    return MediaReceiverMobile();
  }

  StreamController<dynamic> controller = StreamController<dynamic>();

  void dispose() {
    controller.close();
  }
}
