import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class DirectoryActions extends StatelessWidget with OuiSyncAppLogger {
  const DirectoryActions({
    required this.context,
    required this.cubit,
  });

  final BuildContext context;
  final RepoCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(context),
          Fields.bottomSheetTitle(S.current.titleFolderActions),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildAction(
                name: S.current.actionNewFolder,
                icon: Icons.folder_outlined,
                action: () => createFolderDialog(context, cubit)),
            _buildAction(
                name: S.current.actionNewFile,
                icon: Icons.insert_drive_file_outlined,
                action: () async => await addFile(context, cubit))
          ]),
        ]);
  }

  Widget _buildAction({name, icon, action}) => Padding(
        padding: Dimensions.paddingBottomSheetActions,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: action,
            child: Column(
              children: [
                Icon(
                  icon,
                  size: Dimensions.sizeIconExtraBig,
                ),
                Dimensions.spacingVertical,
                Text(name,
                    style: const TextStyle(fontSize: Dimensions.fontAverage))
              ],
            )),
      );

  void createFolderDialog(context, RepoCubit cubit) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.titleCreateFolder,
            body: FolderCreation(
              context: context,
              cubit: cubit,
              formKey: formKey,
            ),
          );
        }).then((newFolder) => {
          if (newFolder.isNotEmpty)
            {
              // If a folder is created, the new folder is returned path; otherwise, empty string.
              Navigator.of(this.context).pop()
            }
        });
  }

  Future<void> addFile(context, RepoCubit repo) async {
    final permissionName = S.current.messageStorage;
    final permissionGranted =
        await _checkPermission(Permission.storage, permissionName);

    if (!permissionGranted) return;

    final dstDir = repo.state.currentFolder.path;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withReadStream: true,
      allowMultiple: true,
    );

    if (result != null) {
      for (final srcFile in result.files) {
        final dstPath = buildDestinationPath(dstDir, srcFile.name);

        if (await repo.exists(dstPath)) {
          final type = await repo.type(dstPath);
          final typeNameForMessage = _getTypeNameForMessage(type);
          showSnackBar(context,
              message: S.current.messageEntryAlreadyExist(typeNameForMessage));
          continue;
        }

        await repo.saveFile(
          filePath: dstPath,
          length: srcFile.size,
          fileByteStream: srcFile.readStream!,
        );
      }
    }

    Navigator.of(context).pop();
  }

  Future<bool> _checkPermission(
      Permission permission, String permissionName) async {
    final result = await Permissions.requestPermission(
        context, permission, permissionName);

    if (result.status != PermissionStatus.granted) {
      loggy.app(result.resultMessage);
      return false;
    }

    return true;
  }

  String _getTypeNameForMessage(EntryType? type) {
    if (type == null) {
      return S.current.messageEntryTypeDefault;
    }

    return type == EntryType.directory
        ? S.current.messageEntryTypeFolder
        : S.current.messageEntryTypeFile;
  }
}
