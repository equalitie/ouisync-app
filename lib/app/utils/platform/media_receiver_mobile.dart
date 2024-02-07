import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../log.dart';
import 'platform.dart';

class MediaReceiverMobile with AppLogger implements MediaReceiver {
  MediaReceiverMobile() {
    _setupReceivingMediaIntents();
  }

  @override
  StreamController controller = StreamController<SharedMediaFile>();

  StreamSubscription? _mediaIntentSubscription;
  StreamSubscription? _textIntentSubscription;

  // For receiving media intents.
  void _setupReceivingMediaIntents() {
    // For sharing images coming from outside the app while the app is in the memory
    _mediaIntentSubscription = ReceiveSharingIntent.getMediaStream().listen(
        (List<SharedMediaFile> listOfMedia) {
      if (listOfMedia.isEmpty) {
        loggy.app('No media present (intent_listener)');
        return;
      }

      loggy.app(
          'Media shared: ${(listOfMedia.map((f) => f.path).join(","))} (intent_listener)');
      controller.add(listOfMedia);
    }, onError: (err) {
      loggy.app("Error: $err (intent_listener)");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia()
        .then((List<SharedMediaFile> listOfMedia) {
      if (listOfMedia.isEmpty) {
        loggy.app('No media present (intent)');
        return;
      }

      loggy.app(
          'Media shared: ${(listOfMedia.map((f) => f.path).join(","))} (intent)');
      controller.add(listOfMedia);
    });
  }

  @override
  void dispose() {
    controller.close();

    _mediaIntentSubscription?.cancel();
    _textIntentSubscription?.cancel();
  }
}
