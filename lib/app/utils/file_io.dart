import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ouisync/ouisync.dart' show EntryType;
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoCubit;
import '../models/models.dart' show FileEntry;
import '../widgets/widgets.dart'
    show RenameOrReplaceResult, RenameOrReplaceEntryDialog;
import 'stage.dart';
import 'platform/platform.dart' show PlatformValues;
import 'utils.dart' show AppLogger, Constants, Permissions;

enum FileDestination { device, ouisync }

class FileIO with AppLogger {
  const FileIO({required this.repoCubit, required this.stage});

  final RepoCubit repoCubit;
  final Stage stage;

  Future<void> addFileFromDevice({
    required FileType type,
    required Future<bool> popCallback,
  }) async {
    final storagePermissionOk = await _maybeRequestPermission();
    if (storagePermissionOk == false) {
      return;
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

      await popCallback;

      for (final srcFile in result.files) {
        final parentPath = repoCubit.state.currentFolder.path;
        String fileName = srcFile.name;
        String destinationFilePath = p.join(parentPath, fileName);

        final exist = await repoCubit.entryExists(destinationFilePath);
        if (!exist) {
          await repoCubit.saveFile(
            filePath: destinationFilePath,
            length: srcFile.size,
            fileByteStream: srcFile.readStream!,
          );

          continue;
        }

        final replaceOrKeepEntry = await RenameOrReplaceEntryDialog.show(
          stage: stage,
          title: S.current.titleAddFile,
          entryName: fileName,
          entryType: EntryType.file,
        );

        if (replaceOrKeepEntry == null) {
          continue;
        }

        if (replaceOrKeepEntry == RenameOrReplaceResult.replace) {
          await repoCubit.replaceFile(
            filePath: destinationFilePath,
            length: srcFile.size,
            fileByteStream: srcFile.readStream!,
          );

          continue;
        }

        if (replaceOrKeepEntry == RenameOrReplaceResult.rename) {
          final newPath = await _renameFileWithVersion(
            fileName,
            parentPath,
            FileDestination.ouisync,
          );

          await repoCubit.saveFile(
            filePath: newPath,
            length: srcFile.size,
            fileByteStream: srcFile.readStream!,
          );
        }
      }
    }
  }

  Future<void> saveFileToDevice(
    FileEntry entry, [
    String? defaultPath,
    ({String parentPath, String destinationPath})? paths,
  ]) async {
    if (defaultPath == null && paths == null) return;

    final storagePermissionOk = await _maybeRequestPermission();
    if (storagePermissionOk == false) {
      return;
    }

    String path = entry.path;
    String fileName = entry.name;

    String parentPath;
    String destinationPath;

    if (defaultPath != null) {
      final destinationPaths = await getDestinationPath(defaultPath, fileName);
      if (destinationPaths.canceled) {
        final errorMessage = S.current.messageDownloadFileCanceled;
        stage.showSnackBar(errorMessage);

        return;
      }

      parentPath = destinationPaths.parentPath;
      destinationPath = destinationPaths.destinationPath;
    } else {
      parentPath = paths!.parentPath;
      destinationPath = paths.destinationPath;
    }

    return repoCubit.downloadFile(
      sourcePath: path,
      parentPath: parentPath,
      destinationPath: destinationPath,
    );
  }

  Future<bool> _maybeRequestPermission() async {
    if (!io.Platform.isAndroid) {
      return true;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final androidSDK = androidInfo.version.sdkInt;

    if (androidSDK > Constants.android12SDK) {
      return true;
    }

    loggy.debug('Android SDK is $androidSDK; requesting STORAGE permission');

    final storagePermission = await Permissions.requestPermission(
      stage,
      Permission.storage,
    );

    if (storagePermission == PermissionStatus.granted) {
      loggy.debug('STORAGE permission granted by the user (SDK $androidSDK)');
      return true;
    }

    loggy.debug(
      'Error: STORAGE permission denied by the user '
      '(SDK $androidSDK)',
    );

    return false;
  }

  Future<({String parentPath, String destinationPath, bool canceled})>
  getDestinationPath(String defaultPath, [String? fileName]) async {
    String parentPath = '';
    String? destinationFilePath = '';

    if (PlatformValues.isDesktopDevice) {
      destinationFilePath = await _getDesktopPath(defaultPath, fileName);

      if (destinationFilePath == null || destinationFilePath.isEmpty) {
        return (parentPath: '', destinationPath: '', canceled: true);
      }

      final dirName = fileName != null
          ? p.dirname(destinationFilePath)
          : destinationFilePath;
      parentPath = p.basename(dirName);
    } else {
      parentPath = p.basename(defaultPath);
      if (io.Platform.isAndroid) {
        parentPath = p.join(parentPath, 'Ouisync');
        defaultPath = p.join(defaultPath, 'Ouisync');
      }

      destinationFilePath = p.join(defaultPath, fileName);

      final exist = await io.File(destinationFilePath).exists();
      if (exist) {
        destinationFilePath = await _renameFileWithVersion(
          fileName ?? '',
          defaultPath,
          FileDestination.device,
        );
      }
    }

    return (
      parentPath: parentPath,
      destinationPath: destinationFilePath,
      canceled: false,
    );
  }

  Future<String?> _getDesktopPath(String parentPath, String? fileName) async {
    final basePath = (fileName ?? '').isEmpty
        ? await FilePicker.platform.getDirectoryPath(
            initialDirectory: parentPath,
          )
        : await FilePicker.platform.saveFile(
            fileName: fileName,
            initialDirectory: parentPath,
          );

    return basePath;
  }

  Future<String> _renameFileWithVersion(
    String fileName,
    String parentPath,
    FileDestination destination,
  ) async {
    loggy.debug(
      'File $fileName already exist on location $parentPath. Renaming...',
    );
    fileName = await _renameFile(parentPath, fileName, destination, 0);

    loggy.debug('The new name is $fileName');
    final destinationFilePath = p.join(parentPath, fileName);

    loggy.debug('The new path is $destinationFilePath');
    return destinationFilePath;
  }

  Future<String> _renameFile(
    String destinationPath,
    String originalFileName,
    FileDestination destination,
    int versions,
  ) async {
    final name = p.basenameWithoutExtension(originalFileName);
    final extension = p.extension(originalFileName);

    final newFileName = '$name (${versions += 1})$extension';
    final newDestinationPath = p.join(destinationPath, newFileName);

    final exist = destination == FileDestination.device
        ? io.File(newDestinationPath).exists()
        : repoCubit.entryExists(newDestinationPath);

    if (await exist) {
      return _renameFile(
        destinationPath,
        originalFileName,
        destination,
        versions,
      );
    }

    return newFileName;
  }
}
