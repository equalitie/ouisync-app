import 'package:flutter/material.dart';
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
            text: Strings.titleAddShareFilePage,
          ),
          Fields.constrainedText(
            getPathFromFileName(this.sharedMedia.first.path),
            softWrap: true,
            textOverflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w800
          ),
          Fields.actionsSection(context,
            buttons: _actions(context),
            // padding: EdgeInsets.only(top: 0.0)
          )
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    List<Widget> actions = <Widget>[];

    actions.addAll([ElevatedButton(
      onPressed: () => onSaveFile.call(),
      child: Text(Strings.actionSave)
    ),
    SizedBox(width: 20.0,),]);
    actions.add(OutlinedButton(
      onPressed: () {
        onBottomSheetOpen.call(null, '');
        Navigator.of(context).pop('');
      },
      child: Text(Strings.actionCancel)
    ));

    return actions;
  }
}