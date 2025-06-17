import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart'
    show
        EntryBottomSheetCubit,
        EntryBottomSheetState,
        HideSheetState,
        RepoCubit;
import '../../utils/utils.dart'
    show AppLogger, Dialogs, Dimensions, Fields, FileIO, showSnackBar;
import '../widgets.dart' show ActionsDialog, FolderCreation;

class DirectoryActions extends StatelessWidget with AppLogger {
  const DirectoryActions(
    this.parentContext, {
    required this.repoCubit,
    required this.bottomSheetCubit,
  });

  final BuildContext parentContext;
  final RepoCubit repoCubit;
  final EntryBottomSheetCubit bottomSheetCubit;

  @override
  Widget build(BuildContext context) {
    final sheetTitleStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400);

    return Container(
      padding: MediaQuery.paddingOf(context).add(Dimensions.paddingBottomSheet),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(parentContext),
          Fields.bottomSheetTitle(
            S.current.titleFolderActions,
            style: sheetTitleStyle,
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAction(
                  name: S.current.actionNewFolder,
                  icon: Icons.create_new_folder_outlined,
                  action:
                      () async =>
                          await createFolderDialog(parentContext, repoCubit),
                ),
                _buildNewFileAction(parentContext, cubit: repoCubit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required String name,
    required IconData icon,
    required Function()? action,
  }) {
    Color? disabledColor = action == null ? Colors.grey : null;

    return Padding(
      padding: Dimensions.paddingBottomSheetActions,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action,
        child: Column(
          children: [
            Icon(icon, size: Dimensions.sizeIconBig, color: disabledColor),
            Dimensions.spacingVertical,
            Text(name, style: TextStyle(color: disabledColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildNewFileAction(
    BuildContext parentContext, {
    required RepoCubit cubit,
  }) => BlocBuilder<EntryBottomSheetCubit, EntryBottomSheetState>(
    bloc: bottomSheetCubit,
    builder: (context, state) {
      /// If we are not using the modal bottom sheet, this is, we
      /// are not moving entries or adding media from the device,
      /// we disable the add File button.
      final enable = state is HideSheetState;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAction(
            name: S.current.actionNewFile,
            icon: Icons.upload_file_outlined,
            action:
                enable
                    ? () async => await addFile(
                      parentContext,
                      repoCubit: cubit,
                      type: FileType.any,
                    )
                    : null,
          ),
          if (io.Platform.isIOS)
            _buildAction(
              name: S.current.actionNewMediaFile,
              icon: Icons.photo_library_outlined,
              action:
                  enable
                      ? () async => await addFile(
                        parentContext,
                        repoCubit: cubit,
                        type: FileType.media,
                      )
                      : () async =>
                          await _showNotAvailableAlertDialog(parentContext),
            ),
        ],
      );
    },
  );

  Future<void> _showNotAvailableAlertDialog(BuildContext context) =>
      Dialogs.simpleAlertDialog(
        context,
        title: S.current.titleMovingEntry,
        message: S.current.messageMovingEntry,
      );

  Future<void> createFolderDialog(BuildContext context, RepoCubit cubit) async {
    final parent = cubit.state.currentFolder.path;

    final newFolderPath =
        await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder:
              (BuildContext context) => ActionsDialog(
                title: S.current.titleCreateFolder,
                body: FolderCreation(cubit: cubit, parent: parent),
              ),
        ) ??
        '';

    if (newFolderPath.isEmpty) return;

    final result = await Dialogs.executeWithLoadingDialog(
      null,
      () async => await cubit.createFolder(newFolderPath),
    );

    if (!result) {
      showSnackBar(S.current.messageErrorCreatingFolder(newFolderPath));
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> addFile(
    BuildContext context, {
    required RepoCubit repoCubit,
    required FileType type,
  }) async {
    final callback = Navigator.of(context).maybePop();

    await FileIO(
      context: context,
      repoCubit: repoCubit,
    ).addFileFromDevice(type: type, popCallback: callback);
  }
}
