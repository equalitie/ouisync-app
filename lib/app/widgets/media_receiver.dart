import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Widget for receiving media files via drag-and-drop (on desktop) or share intents (on mobile).
class MediaReceiver extends StatefulWidget {
  MediaReceiver({required this.child, required this.controller, super.key});

  final Widget child;
  final StreamController<List<SharedMediaFile>> controller;

  @override
  State<MediaReceiver> createState() => _MediaReceiverState();
}

class _MediaReceiverState extends State<MediaReceiver> {
  // Must match the channel name in ios/Runner/AppDelegate.swift and macos/Runner/AppDelegate.swift.
  static const _universalLinkChannel = MethodChannel(
    'org.equalitie.ouisync/universal_links',
  );

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
        onMediaReceived,
      );

      // For sharing media coming from outside the app while the app is closed
      unawaited(
        ReceiveSharingIntent.instance.getInitialMedia().then(onMediaReceived),
      );
    }

    if (Platform.isIOS || Platform.isMacOS) {
      _universalLinkChannel.setMethodCallHandler(onUniversalLinkCall);
      unawaited(getInitialUniversalLink());
    }
  }

  @override
  void dispose() {
    subscription?.cancel();

    if (Platform.isIOS || Platform.isMacOS) {
      _universalLinkChannel.setMethodCallHandler(null);
    }

    super.dispose();
  }

  // Called by the native side when a https://ouisync.net/r# link is opened while the app is running.
  Future<void> onUniversalLinkCall(MethodCall call) async {
    if (call.method == 'onLink') {
      await getInitialUniversalLink();
    }
  }

  // Fetches (and clears) a pending link. Used both at startup and when a link arrives at runtime.
  Future<void> getInitialUniversalLink() async {
    final link = await _universalLinkChannel.invokeMethod<String>(
      'getInitialLink',
    );

    if (link != null) {
      onMediaReceived([SharedMediaFile(path: link, type: SharedMediaType.url)]);
    }
  }

  @override
  Widget build(BuildContext context) => DropTarget(
    onDragDone: (detail) => onMediaReceived(
      detail.files
          .map(
            (file) => SharedMediaFile(
              path: file.path,
              type: SharedMediaType.file,
              mimeType: file.mimeType,
            ),
          )
          .toList(),
    ),
    child: widget.child,
  );

  void onMediaReceived(List<SharedMediaFile> media) {
    if (media.isEmpty) {
      return;
    }

    widget.controller.add(media);
  }
}
