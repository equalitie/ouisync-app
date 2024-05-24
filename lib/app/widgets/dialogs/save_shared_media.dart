import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../pages/pages.dart';
import '../../utils/path.dart';
import '../../utils/utils.dart';
import '../widgets.dart';
import '../../cubits/repos.dart';

typedef SaveFileCallback = Future<void> Function(String sourceFilePath);

class SaveSharedMedia extends StatefulWidget {
  const SaveSharedMedia(
    this._repos, {
    required this.sharedMediaPaths,
    required this.onUpdateBottomSheet,
    required this.onSaveFile,
    required this.validationFunction,
  });

  final ReposCubit _repos;
  final List<String> sharedMediaPaths;
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
    return widget._repos.builder((_) {
      final mediaListMaxHeight = MediaQuery.of(context).size.height * 0.2;

      final sheetTitleStyle = Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(fontWeight: FontWeight.w400);

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
                      textAlign: TextAlign.start,
                      padding: EdgeInsets.all(0.0),
                      style: sheetTitleStyle),
                  Fields.actionIcon(_collapsableIcon,
                      onPressed: _collapsableAction,
                      padding: EdgeInsets.all(0.0),
                      alignment: Alignment.center,
                      size: Dimensions.sizeIconBig,
                      color: Colors.black)
                ],
              ),
              Fields.autosizeText(
                '(${widget.sharedMediaPaths.length} ${widget.sharedMediaPaths.length == 1 ? S.current.messageFile : S.current.messageFiles})',
                textAlign: TextAlign.center,
              ),
              Dimensions.spacingVertical,
              Visibility(
                  visible: !_minimize,
                  child: ConstrainedBox(
                      constraints: BoxConstraints.loose(
                          Size.fromHeight(mediaListMaxHeight)),
                      child:
                          _buildMediaList(context, widget.sharedMediaPaths))),
              Visibility(
                  visible: !_minimize,
                  child: Fields.dialogActions(context,
                      buttons: _actions(context),
                      padding: const EdgeInsets.only(top: 20.0),
                      mainAxisAlignment: MainAxisAlignment.end))
            ]),
      );
    });
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

  Widget _buildMediaList(BuildContext context, List<String> mediaPaths) =>
      ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Colors.black12),
          itemCount: mediaPaths.length,
          itemBuilder: (context, index) {
            final mediaPath = mediaPaths[index];
            final name = basename(mediaPath);

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
                        Expanded(flex: 9, child: Fields.autosizeText(name))
                      ],
                    ),
                    Fields.autosizeText(mediaPath)
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
            onPressed: widget._repos.showList
                ? null
                : () async {
                    final canSaveMedia = await widget.validationFunction();
                    if (!canSaveMedia) {
                      return;
                    }

                    for (final path in widget.sharedMediaPaths) {
                      await widget.onSaveFile(path);
                    }

                    widget.onUpdateBottomSheet.call(null, '');
                  },
            buttonsAspectRatio: Dimensions.aspectRatioBottomDialogButton)
      ];
}
