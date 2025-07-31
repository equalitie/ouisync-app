import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
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
