import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/loggers/ouisync_app_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'utils.dart';

class Constants with OuiSyncAppLogger{
  Constants._();

  static Future<String> get internalPath async {
    return (await getApplicationSupportDirectory()).path;
  }

  static Future<String> get externalPath async { 
    return await Settings.readSetting(Constants.externalPathKey) ?? '';
  }

  static Future<String> get configPath async {
    final internalRoot = await internalPath;
    return join(internalRoot, configuratiosDirName);
  }

  static Future<String> get reposPath async {
    final storageLocation = await storageType;
    if (storageLocation == defaultStorage) {
      final _defaultRoot = await internalPath;
      return join(_defaultRoot, folderRepositoriesName);
    }

    final _externalPath = await externalPath;
    if (_externalPath.isEmpty) {
      return '';
    }

    return join(_externalPath, folderRepositoriesName);
  }

  static Future<String> get storageType async {
    return await Settings.containsSetting(Constants.storageTypeKey)
    ? await Settings.readSetting(Constants.storageTypeKey)
    : Constants.defaultStorage;
  }

  static const String storageTypeKey = 'STORAGE_TYPE';
  static const String externalPathKey = 'EXTERNAL_PATH';
  // static const String appDirKey = 'APP_DIR';
  // static const String repositoriesDirKey = 'REPOS_DIR';
  static const String currentRepositoryKey = 'CURRENT_REPO';
  static const String bitTorrentDHTStatusKey = 'BT_DHT';

  static const String internalStorage = 'internal';
  static const String externalStorage = 'external';
  static const String defaultStorage = internalStorage;

  static const String folderRepositoriesName = 'repositories';
  static const String configuratiosDirName = 'configs';

  static const int bufferSize = 64000;

  /// In-line text style names
  
  static const String inlineTextBold = 'bold';
  static const String inlineTextSize = 'size';
  static const String inlineTextColor = 'color';
  static const String inlineTextIcon = 'icon';

  // Hero tags

  static const String heroTagMainPageActions = 'MAIN_PAGE_ACTIONS';

  static const IconData iconVisibilityOn = Icons.visibility;
  static const IconData iconVisibilityOff = Icons.visibility_off;
}
