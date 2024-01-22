import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class DirectoryActions extends StatelessWidget with AppLogger {
  const DirectoryActions({
    required this.context,
    required this.cubit,
  });

  final BuildContext context;
  final RepoCubit cubit;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAction(
                    name: S.current.actionNewFolder,
                    icon: Icons.create_new_folder_outlined,
                    action: () => createFolderDialog(context, cubit),
                  ),
                  _buildAction(
                    name: S.current.actionNewFile,
                    icon: Icons.upload_file_outlined,
                    action: () async =>
                        await addFile(context, cubit, FileType.any),
                  ),
                  if (io.Platform.isIOS)
                    _buildAction(
                      name: S.current.actionNewMediaFile,
                      icon: Icons.photo_library_outlined,
                      action: () async =>
                          await addFile(context, cubit, FileType.media),
                    ),
                ],
              ),
            ]));
  }

  Widget _buildAction({name, icon, action}) => Padding(
      padding: Dimensions.paddingBottomSheetActions,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action,
          child: Column(children: [
            Icon(
              icon,
              size: Dimensions.sizeIconBig,
            ),
            Dimensions.spacingVertical,
            Text(name)
          ])));

  void createFolderDialog(context, RepoCubit cubit) async {
    final parent = cubit.state.currentFolder.path;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ActionsDialog(
          title: S.current.titleCreateFolder,
          body: FolderCreation(cubit: cubit, parent: parent)),
    ).then((newFolderPath) async {
      if (newFolderPath.isNotEmpty) {
        await cubit.createFolder(newFolderPath);

        /// If a name for the new folder is provided, the new folder path is returned; otherwise, empty string.
        Navigator.of(this.context).pop();
      }
    });
  }

  Future<void> addFile(context, RepoCubit repo, FileType type) async {
    final dstDir = repo.state.currentFolder.path;

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

      Navigator.of(context).pop();

      for (final srcFile in result.files) {
        String fileName = srcFile.name;
        String dstPath = buildDestinationPath(dstDir, fileName);

        if (await repo.exists(dstPath)) {
          final action = await showDialog<FileAction>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Flex(direction: Axis.horizontal, children: [
                    Fields.constrainedText(S.current.titleAddFile,
                        style: context.theme.appTextStyle.titleMedium,
                        maxLines: 2)
                  ]),
                  content: ReplaceFile(context: context, fileName: fileName)));

          if (action == null) {
            return;
          }

          if (action == FileAction.replace) {
            await repo.replaceFile(
              filePath: dstPath,
              length: srcFile.size,
              fileByteStream: srcFile.readStream!,
            );

            return;
          }

          fileName = await _renameFile(dstPath, 0);
          dstPath = buildDestinationPath(dstDir, fileName);
        }

        await repo.saveFile(
          filePath: dstPath,
          length: srcFile.size,
          fileByteStream: srcFile.readStream!,
        );
      }
    }
  }

  Future<String> _renameFile(String dstPath, int versions) async {
    final name = p.basenameWithoutExtension(dstPath);
    final extension = p.extension(dstPath);

    final newFileName = '$name (${versions += 1})$extension';

    if (await cubit.exists(newFileName)) {
      return await _renameFile(dstPath, versions);
    }

    return newFileName;
  }
}
