import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../generated/l10n.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SaveSharedMedia extends StatelessWidget {
  const SaveSharedMedia({
    required this.sharedMedia,
    required this.onBottomSheetOpen,
    required this.onSaveFile,
    Key? key,
  }) : super(key: key);

  final List<SharedMediaFile> sharedMedia;
  final BottomSheetControllerCallback onBottomSheetOpen;
  final SaveFileCallback onSaveFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingBottomSheet,
      height: 180.0,
      decoration: Dimensions.decorationBottomSheetAlternative,
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
            getBasename(sharedMedia.first.path),
            softWrap: true,
            textOverflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w800
          ),
          Fields.dialogActions(context,
            buttons: _actions(context),
            padding: const EdgeInsets.only(top: 0.0),
            mainAxisAlignment: MainAxisAlignment.end
          )
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => _cancelSaveFile(context)),
    PositiveButton(
      text: S.current.actionSave,
      onPressed: () async {
        await onSaveFile.call(sharedMedia.first.path);
        Navigator.of(context).pop();
      })
  ];
  
  void _cancelSaveFile(context) {
    onBottomSheetOpen.call(null, '');
    Navigator.of(context).pop('');
  }
}
