import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'utils.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../cubits/cubits.dart';
import '../models/models.dart';
import 'platform/platform.dart';

class SaveFileToDevice with AppLogger {
  const SaveFileToDevice({required FileItem data, required RepoCubit cubit})
      : _data = data,
        _cubit = cubit;

  final FileItem _data;
  final RepoCubit _cubit;

  Future<void> save(String path) async {
    await _maybeRequestPermission();

    final destinationFilePath = await _getDestinationFilePath(path, _data.name);

    if (destinationFilePath == null || destinationFilePath.isEmpty) {
      return;
    }

    final destinationFile = io.File(destinationFilePath);
    await _cubit.downloadFile(
      sourcePath: _data.path,
      destinationPath: destinationFile.path,
    );
  }

  Future<void> _maybeRequestPermission() async {
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

  Future<String?> _getDestinationFilePath(
      String parentPath, String fileName) async {
    final filePath = PlatformValues.isMobileDevice
        ? await _mobilePath(parentPath, fileName)
        : await _desktopPath(parentPath, fileName);

    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    return filePath;
  }

  Future<String?> _mobilePath(String parentPath, String fileName) async {
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      initialDirectory: parentPath,
    );

    if (directoryPath == null || directoryPath.isEmpty) {
      return null;
    }

    return p.join(directoryPath, fileName);
  }

  Future<String?> _desktopPath(String parentPath, String fileName) async {
    final filePath = await FilePicker.platform.saveFile(
      fileName: fileName,
      initialDirectory: parentPath,
    );

    return filePath;
  }
}
