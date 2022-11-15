import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../generated/l10n.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

typedef SaveFileCallback = Future<void> Function(String sourceFilePath);

class SaveSharedMedia extends StatelessWidget {
  const SaveSharedMedia({
    required this.sharedMedia,
    required this.onBottomSheetOpen,
    required this.onSaveFile,
    required this.validationFunction,
  });

  final List<SharedMediaFile> sharedMedia;
  final BottomSheetControllerCallback onBottomSheetOpen;
  final SaveFileCallback onSaveFile;
  final Future<bool> Function() validationFunction;

  @override
  Widget build(BuildContext context) {
    final nediaListMaxHeight = MediaQuery.of(context).size.height * 0.2;

    return Container(
      padding: Dimensions.paddingBottomSheet,
      decoration: Dimensions.decorationBottomSheetAlternative,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.bottomSheetTitle(S.current.titleAddFile,
                textAlign: TextAlign.start),
            ConstrainedBox(
                constraints:
                    BoxConstraints.loose(Size.fromHeight(nediaListMaxHeight)),
                child: _buildMediaList(context, sharedMedia)),
            Fields.dialogActions(context,
                buttons: _actions(context),
                padding: const EdgeInsets.only(top: 20.0),
                mainAxisAlignment: MainAxisAlignment.end)
          ]),
    );
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
            onPressed: () => _cancelSaveFile(context),
            buttonsAspectRatio: Dimensions.aspectRatioBottomDialogButton),
        PositiveButton(
            text: S.current.actionSave,
            onPressed: () async {
              final canSaveMedia = await validationFunction();
              if (!canSaveMedia) {
                return;
              }

              for (final media in sharedMedia) {
                await onSaveFile(media.path);
              }

              Navigator.of(context).pop();
            },
            buttonsAspectRatio: Dimensions.aspectRatioBottomDialogButton)
      ];

  void _cancelSaveFile(context) {
    onBottomSheetOpen.call(null, '');
    Navigator.of(context).pop('');
  }
}
