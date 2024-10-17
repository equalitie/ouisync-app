import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/utils.dart';
import '../widgets.dart';

class DirectoryActions extends StatelessWidget with AppLogger {
  const DirectoryActions({
    required this.parentContext,
    required this.repoCubit,
    required this.bottomSheetCubit,
  });

  final BuildContext parentContext;
  final RepoCubit repoCubit;
  final EntryBottomSheetCubit bottomSheetCubit;

  @override
  Widget build(BuildContext context) {
    final sheetTitleStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w400);

    return Container(
      padding: Dimensions.paddingBottomSheet,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(context),
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
                  action: () => createFolderDialog(context, repoCubit),
                ),
                _buildNewFileAction(parentContext),
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
    Color? dissabledColor = action == null ? Colors.grey : null;

    return Padding(
      padding: Dimensions.paddingBottomSheetActions,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action,
        child: Column(
          children: [
            Icon(
              icon,
              size: Dimensions.sizeIconBig,
              color: dissabledColor,
            ),
            Dimensions.spacingVertical,
            Text(
              name,
              style: TextStyle(color: dissabledColor),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNewFileAction(BuildContext parentContext) =>
      BlocBuilder<EntryBottomSheetCubit, EntryBottomSheetState>(
        bloc: bottomSheetCubit,
        builder: (context, state) {
          /// If we are not using the modal bottom sheet, this is, we
          /// are not moving entries or adding media from the device,
          /// we dissable the add File button.
          final enable = state is HideSheetState;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAction(
                name: S.current.actionNewFile,
                icon: Icons.upload_file_outlined,
                action: enable
                    ? () async => await addFile(
                          parentContext,
                          repoCubit,
                          FileType.any,
                        )
                    : null,
              ),
              if (io.Platform.isIOS)
                _buildAction(
                  name: S.current.actionNewMediaFile,
                  icon: Icons.photo_library_outlined,
                  action: enable
                      ? () async => await addFile(
                            parentContext,
                            repoCubit,
                            FileType.media,
                          )
                      : () async => await _showNotAvailableAlertDialog(context),
                ),
            ],
          );
        },
      );

  Future<void> _showNotAvailableAlertDialog(BuildContext context) =>
      Dialogs.simpleAlertDialog(
        context: context,
        title: S.current.titleMovingEntry,
        message: S.current.messageMovingEntry,
      );

  void createFolderDialog(context, RepoCubit cubit) async {
    final parent = cubit.state.currentFolder.path;
    var newFolderPath = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ActionsDialog(
          title: S.current.titleCreateFolder,
          body: FolderCreation(cubit: cubit, parent: parent)),
    );

    if (newFolderPath == null || newFolderPath.isEmpty) {
      return;
    }

    Navigator.of(parentContext).pop();
  }

  Future<void> addFile(
    parentContext,
    RepoCubit repoCubit,
    FileType type,
  ) async {
    if (io.Platform.isAndroid) {
      /// On Android 12 (Sdk API 32) or lower, the strorage
      /// permission needs to be requested before using the file picker.
      ///
      /// This is not longer the case, starting with version 13 (Sdk API 33)
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final status = await Permissions.requestPermission(
            parentContext, Permission.storage);

        if (status != PermissionStatus.granted) return;
      }
    }

    final result = await FilePicker.platform.pickFiles(
      type: type,
      withReadStream: true,
      allowMultiple: true,
    );

    if (result != null) {
      loggy.debug(() {
        final fileNames = result.files.map((file) => file.name).toList();
        return 'Adding files $fileNames';
      });

      Navigator.of(parentContext).pop();

      for (final srcFile in result.files) {
        final dstDir = repoCubit.state.currentFolder.path;
        String fileName = srcFile.name;

        String dstPath = repo_path.join(dstDir, fileName);

        if (await repoCubit.exists(dstPath)) {
          await showDialog<FileAction>(
            context: parentContext,
            builder: (BuildContext context) => AlertDialog(
              title: Flex(
                direction: Axis.horizontal,
                children: [
                  Fields.constrainedText(
                    S.current.titleAddFile,
                    style: context.theme.appTextStyle.titleMedium,
                    maxLines: 2,
                  )
                ],
              ),
              content: ReplaceKeepEntry(name: fileName, type: EntryType.file),
            ),
          ).then(
            (fileAction) async {
              if (fileAction == null) {
                return;
              }

              if (fileAction == FileAction.replace) {
                await repoCubit.replaceFile(
                  filePath: dstPath,
                  length: srcFile.size,
                  fileByteStream: srcFile.readStream!,
                );
              }

              if (fileAction == FileAction.keep) {
                final newPath = await _renameFile(dstPath, 0);
                await repoCubit.saveFile(
                  filePath: newPath,
                  length: srcFile.size,
                  fileByteStream: srcFile.readStream!,
                );
              }
            },
          );
        } else {
          await repoCubit.saveFile(
            filePath: dstPath,
            length: srcFile.size,
            fileByteStream: srcFile.readStream!,
          );
        }
      }
    }
  }

  Future<String> _renameFile(String dstPath, int versions) async {
    final parent = repo_path.dirname(dstPath);
    final name = repo_path.basenameWithoutExtension(dstPath);
    final extension = repo_path.extension(dstPath);

    final newFileName = '$name (${versions += 1})$extension';
    final newPath = repo_path.join(parent, newFileName);

    if (await repoCubit.exists(newPath)) {
      return await _renameFile(dstPath, versions);
    }
    return newPath;
  }
}
