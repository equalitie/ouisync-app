import 'dart:async';
import 'dart:io';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'platform.dart';

class MediaReceiver {
  factory MediaReceiver() {
    if (Platform.isAndroid || Platform.isIOS) {
      return MediaReceiverMobile();
    } else {
      return MediaReceiver._();
    }
  }

  MediaReceiver._();

  final controller = StreamController<List<SharedMediaFile>>();

  void dispose() {
    controller.close();
  }
}
