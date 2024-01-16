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

    String parentPath = p.basename(defaultPath);

    if (io.Platform.isAndroid) {
      parentPath = p.join(parentPath, 'Ouisync');
      defaultPath = p.join(defaultPath, 'Ouisync');
    }

    final destinationFilePath =
        await _getDestinationFilePath(defaultPath, _data.name);

    if (destinationFilePath == null || destinationFilePath.isEmpty) {
      final errorMessage = S.current.messageDownloadFileCanceled;
      showSnackBar(context, message: errorMessage);

      return;
    }

    final destinationFile =
        await io.File(destinationFilePath).create(recursive: true);
        
    await _cubit.downloadFile(
      sourcePath: _data.path,
      parentPath: parentPath,
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

  Future<String?> _getDestinationFilePath(
      String defaultPath, String fileName) async {
    if (PlatformValues.isDesktopDevice) {
      return await _desktopPath(defaultPath, fileName);
    }

    return p.join(defaultPath, _data.name);
  }

  Future<String?> _desktopPath(String parentPath, String fileName) async {
    final filePath = await FilePicker.platform.saveFile(
      fileName: fileName,
      initialDirectory: parentPath,
    );

    return filePath;
  }
}
