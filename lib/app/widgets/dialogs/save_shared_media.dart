import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../generated/l10n.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

typedef SaveFileCallback = Future<void> Function(String sourceFilePath);

class SaveSharedMedia extends StatefulWidget {
  const SaveSharedMedia(
      {required this.sharedMedia,
      required this.onUpdateBottomSheet,
      required this.onSaveFile,
      required this.validationFunction});

  final List<SharedMediaFile> sharedMedia;
  final BottomSheetCallback onUpdateBottomSheet;
  final SaveFileCallback onSaveFile;
  final Future<bool> Function() validationFunction;

  @override
  State<SaveSharedMedia> createState() => _SaveSharedMediaState();
}

class _SaveSharedMediaState extends State<SaveSharedMedia> {
  final Icon _collapsableIconUp = const Icon(Icons.keyboard_arrow_up_rounded);
  final Icon _collapsableIconDown =
      const Icon(Icons.keyboard_arrow_down_rounded);

  Icon _collapsableIcon = const Icon(Icons.keyboard_arrow_down_rounded);

  bool _minimize = false;

  @override
  Widget build(BuildContext context) {
    final mediaListMaxHeight = MediaQuery.of(context).size.height * 0.2;

    return Container(
      padding: Dimensions.paddingBottomSheet,
      decoration: Dimensions.decorationBottomSheetAlternative,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Fields.bottomSheetTitle(S.current.titleAddFile,
                    textAlign: TextAlign.start, padding: EdgeInsets.all(0.0)),
                Fields.actionIcon(_collapsableIcon,
                    onPressed: _collapsableAction,
                    padding: EdgeInsets.all(0.0),
                    alignment: Alignment.center,
                    size: Dimensions.sizeIconBig)
              ],
            ),
            Fields.autosizeText(
                '(${widget.sharedMedia.length} ${widget.sharedMedia.length == 1 ? S.current.messageFile : S.current.messageFiles})',
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700),
            Dimensions.spacingVertical,
            Visibility(
                visible: !_minimize,
                child: ConstrainedBox(
                    constraints: BoxConstraints.loose(
                        Size.fromHeight(mediaListMaxHeight)),
                    child: _buildMediaList(context, widget.sharedMedia))),
            Visibility(
                visible: !_minimize,
                child: Fields.dialogActions(context,
                    buttons: _actions(context),
                    padding: const EdgeInsets.only(top: 20.0),
                    mainAxisAlignment: MainAxisAlignment.end))
          ]),
    );
  }

  void _collapsableAction() {
    if (_collapsableIcon == _collapsableIconDown) {
      setState(() {
        _collapsableIcon = _collapsableIconUp;
        _minimize = true;
      });

      return;
    }

    setState(() {
      _collapsableIcon = _collapsableIconDown;
      _minimize = false;
    });
  }

  Widget _buildMediaList(BuildContext context, List<SharedMediaFile> media) =>
      ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Colors.black12),
          itemCount: media.length,
          itemBuilder: (context, index) {
            final mediaItem = media[index];
            final name = getBasename(mediaItem.path);

            return Container(
                padding: Dimensions.paddingListItem,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: const Icon(Icons.insert_drive_file_outlined,
                                size: Dimensions.sizeIconAverage)),
                        Expanded(
                            flex: 9,
                            child: Fields.autosizeText(name,
                                fontWeight: FontWeight.w800))
                      ],
                    ),
                    Fields.autosizeText(mediaItem.path)
                  ],
                ));
          });

  List<Widget> _actions(BuildContext context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => widget.onUpdateBottomSheet.call(null, ''),
            buttonsAspectRatio: Dimensions.aspectRatioBottomDialogButton),
        PositiveButton(
            text: S.current.actionSave,
            onPressed: () async {
              final canSaveMedia = await widget.validationFunction();
              if (!canSaveMedia) {
                return;
              }

              for (final media in widget.sharedMedia) {
                await widget.onSaveFile(media.path);
              }

              Navigator.of(context).pop();
            },
            buttonsAspectRatio: Dimensions.aspectRatioBottomDialogButton)
      ];
}
