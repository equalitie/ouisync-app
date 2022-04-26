import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../loggers/ouisync_app_logger.dart';
import 'media_receiver.dart';

class MediaReceiverMobile with OuiSyncAppLogger implements MediaReceiver {
  MediaReceiverMobile() {
    _setupReceivingMediaIntents();
    _setupReceivingTextIntents();
  }

  @override
  StreamController controller = StreamController<dynamic>();

  MediaReceiver getMedia() => MediaReceiverMobile();

  StreamSubscription? _mediaIntentSubscription;
  StreamSubscription? _textIntentSubscription;

  // For receiving media intents.
  void _setupReceivingMediaIntents() {
    loggy.app('ReceiveMediaMobile._setupReceivingMediaIntents');

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

  // For receiving share tokens intents.
  void _setupReceivingTextIntents() {
    loggy.app('ReceiveMediaMobile._setupReceivingTextIntents');

    // For sharing intents coming from outside the app while the app is in the memory.
    _textIntentSubscription =
        ReceiveSharingIntent.getTextStream().listen((String text) {
      controller.add(text);
    }, onError: (err) {
      loggy.app("Error: $err (intent_listener)");
    });

    // For sharing intents coming from outside the app while the app is closed.
    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text == null) {
        return;
      }

      controller.add(text);
    });
  }

  @override
  void dispose() {
    controller.close();

    _mediaIntentSubscription?.cancel();
    _textIntentSubscription?.cancel();
  }
}
