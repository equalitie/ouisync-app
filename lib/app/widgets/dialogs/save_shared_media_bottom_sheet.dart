import 'package:flutter/material.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../pages/pages.dart';
import '../../utils/utils.dart';

class SaveSharedMedia extends StatelessWidget {
  const SaveSharedMedia({
    required this.sharedMedia,
    required this.onBottomSheetOpen,
    required this.onSaveFile,
  });

  final List<SharedMediaFile> sharedMedia;
  final BottomSheetControllerCallback onBottomSheetOpen;
  final SaveFileCallback onSaveFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingBottomSheet,
      height: 180.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
          width: 1.0,
          style: BorderStyle.solid
        ),
        color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.iconLabel(
            icon: Icons.save_outlined,
            text: S.current.titleAddFile,
          ),
          Fields.constrainedText(
            getBasename(this.sharedMedia.first.path),
            softWrap: true,
            textOverflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w800
          ),
          Fields.dialogActions(context,
            buttons: _actions(context),
          )
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    List<Widget> actions = <Widget>[];

    actions.addAll([ElevatedButton(
      onPressed: () async => await onSaveFile.call(mobileSharedMediaFile: sharedMedia.first, usesModal: true),
      child: Text(S.current.actionSave)
    ),
    SizedBox(width: 20.0,),]);
    actions.add(OutlinedButton(
      onPressed: () {
        onBottomSheetOpen.call(null, '');
        Navigator.of(context).pop('');
      },
      child: Text(S.current.actionCancel)
    ));

    return actions;
  }
}
