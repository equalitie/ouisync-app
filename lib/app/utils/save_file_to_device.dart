import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import 'platform/platform.dart';
import 'utils.dart';

class SaveFileToDevice with AppLogger {
  const SaveFileToDevice({required FileItem data, required RepoCubit cubit})
      : _data = data,
        _cubit = cubit;

  final FileItem _data;
  final RepoCubit _cubit;

  Future<void> save(BuildContext context, String defaultPath) async {
    await _maybeRequestPermission();

    String fileName = _data.name;

    String? parentDir;
    String? destinationFilePath;

    if (PlatformValues.isDesktopDevice) {
      destinationFilePath = await _desktopPath(defaultPath, fileName);

      if (destinationFilePath == null || destinationFilePath.isEmpty) {
        final errorMessage = S.current.messageDownloadFileCanceled;
        showSnackBar(context, message: errorMessage);

        return;
      }

      final dirName = p.dirname(destinationFilePath);
      parentDir = p.basename(dirName);
    } else {
      parentDir = p.basename(defaultPath);
      if (io.Platform.isAndroid) {
        parentDir = p.join(parentDir, 'Ouisync');
        defaultPath = p.join(defaultPath, 'Ouisync');
      }

      destinationFilePath = p.join(defaultPath, fileName);

      final exist = await io.File(destinationFilePath).exists();
      if (exist) {
        destinationFilePath = await _renameFileWithVersion(
          fileName,
          defaultPath,
          destinationFilePath,
        );
      }
    }

    final destinationFile =
        await io.File(destinationFilePath).create(recursive: true);

    await _cubit.downloadFile(
      sourcePath: _data.path,
      parentPath: parentDir,
      destinationPath: destinationFile.path,
    );
  }

  Future<void> _maybeRequestPermission() async {
    if (!io.Platform.isAndroid) return;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final androidSDK = androidInfo.version.sdkInt;
    if (androidSDK <= Constants.android12SDK) {
      loggy.app('Android SDK is $androidSDK; requesting STORAGE permission');

      final storagePermission = await Permission.storage.status;
      if (!storagePermission.isGranted) {
        final status = await Permission.storage.request();

        assert(status.isGranted, 'Status denied');
        loggy.app(
            'Error: STORAGE permission denied by the user (SDK $androidSDK)');

        return;
      }

      loggy.app('STORAGE permission granted by the user (SDK $androidSDK)');
    }
  }

  Future<String?> _desktopPath(String parentPath, String fileName) async {
    final filePath = await FilePicker.platform.saveFile(
      fileName: fileName,
      initialDirectory: parentPath,
    );

    return filePath;
  }

  Future<String> _renameFileWithVersion(
      String fileName, String defaultPath, String? destinationFilePath) async {
    loggy.app(
        'File $fileName already exist on location $defaultPath. Renaming...');
    fileName = await _renameFile(defaultPath, fileName, 0);

    loggy.app('The new name is $fileName');
    destinationFilePath = p.join(defaultPath, fileName);

    loggy.app('The new path is $destinationFilePath');
    return destinationFilePath;
  }

  Future<String> _renameFile(
    String destinationPath,
    String originalFileName,
    int versions,
  ) async {
    final name = p.basenameWithoutExtension(originalFileName);
    final extension = p.extension(originalFileName);

    final newFileName = '$name (${versions += 1})$extension';
    final newDestinationPath = p.join(destinationPath, newFileName);

    if (await io.File(newDestinationPath).exists()) {
      return await _renameFile(destinationPath, originalFileName, versions);
    }

    return newFileName;
  }
}
