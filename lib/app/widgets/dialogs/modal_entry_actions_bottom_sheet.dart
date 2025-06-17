import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show BottomSheetType, RepoCubit;
import '../../utils/utils.dart'
    show AppThemeExtension, Constants, Dimensions, Fields, ThemeGetter;
import '../widgets.dart' show EntryActionItem;

class EntryActions extends StatefulWidget {
  const EntryActions({required this.repoCubit});

  final RepoCubit repoCubit;

  @override
  State<EntryActions> createState() => _EntryActionsState();
}

class _EntryActionsState extends State<EntryActions> {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Container(
      padding: Dimensions.paddingBottomSheet,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(context),
          Fields.bottomSheetTitle(
            'Select multiple entries',
            style: context.theme.appTextStyle.titleMedium,
          ),
          EntryActionItem(
            iconData: Icons.copy_outlined,
            title: S.current.iconCopy,
            dense: true,
            onTap: () => _handleEntryAction(BottomSheetType.copy),
            disabledMessage: S.current.messageActionNotAvailable,
            disabledMessageDuration:
                Constants.notAvailableActionMessageDuration,
          ),
          EntryActionItem(
            iconData: Icons.drive_file_move_outlined,
            title: S.current.iconMove,
            dense: true,
            onTap: () => _handleEntryAction(BottomSheetType.move),
            disabledMessage: S.current.messageActionNotAvailable,
            disabledMessageDuration:
                Constants.notAvailableActionMessageDuration,
          ),
          EntryActionItem(
            iconData: Icons.download_outlined,
            title: S.current.iconDownload,
            dense: true,
            onTap: () => _handleEntryAction(BottomSheetType.download),
            disabledMessage: S.current.messageActionNotAvailable,
            disabledMessageDuration:
                Constants.notAvailableActionMessageDuration,
          ),
          EntryActionItem(
            iconData: Icons.delete_outlined,
            title: S.current.iconDelete,
            isDanger: true,
            dense: true,
            onTap: () => _handleEntryAction(BottomSheetType.delete),
            disabledMessage: S.current.messageActionNotAvailable,
            disabledMessageDuration:
                Constants.notAvailableActionMessageDuration,
          ),
        ],
      ),
    ),
  );

  void _handleEntryAction(BottomSheetType sheetType) async {
    await Navigator.of(context).maybePop();

    await widget.repoCubit.startEntriesSelection();
    widget.repoCubit.showMoveSelectedEntriesBottomSheet(sheetType: sheetType);
  }
}
