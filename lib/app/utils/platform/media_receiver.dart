import 'dart:async';

import 'media_receiver_stub.dart';

abstract class MediaReceiver {
  factory MediaReceiver() => getMedia();

  StreamController<dynamic> controller = StreamController<dynamic>();

  void dispose() {
    controller.close();
  }
}
