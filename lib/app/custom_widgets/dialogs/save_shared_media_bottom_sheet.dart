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
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      height: 180.0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0)
        ),
        border: Border.all(
          color: Colors.black26,
          width: 1.0,
          style: BorderStyle.solid
        ),
        color: Colors.white
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitle(),
          SizedBox(height: 10.0,),
          Fields.constrainedText(
            getPathFromFileName(this.sharedMedia.first.path),
            softWrap: true,
            textOverflow: TextOverflow.ellipsis,
            size: 20.0,
            fontWeight: FontWeight.w800
          ),
          Fields.actionsSection(context,
            buttons: _actions(context),
            padding: EdgeInsets.only(top: 0.0)
          )
        ],
      ),
    );
  }

  Row _buildTitle() =>
    Row(
      children: [
        const Icon(
          Icons.save_outlined,
          size: 40.0,
        ),
        SizedBox(width: 10.0,),
        Fields.constrainedText(
          Strings.titleAddShareFilePage,
          size: 24.0,
          fontWeight: FontWeight.w800
        ),
      ],
    );

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