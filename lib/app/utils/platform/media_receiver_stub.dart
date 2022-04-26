import 'dart:io';

import 'media_receiver.dart';
import 'media_receiver_mobile.dart';
import 'media_receiver_windows.dart';

MediaReceiver getMedia() {
  if (Platform.isWindows) {
    return MediaReceiverWindows();
  }
  return MediaReceiverMobile();
}
