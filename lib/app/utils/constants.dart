import 'package:flutter/material.dart';

class Constants{
  Constants._();

  static const String appDirKey = 'APP_DIR';
  static const String repositoriesDirKey = 'REPOS_DIR';
  static const String currentRepositoryKey = 'CURRENT_REPO';
  static const String bitTorrentDHTStatusKey = 'BT_DHT';

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

  static const Color progressBarBackgroundColor = Color.fromRGBO(238, 238, 238, 1);
  static const Color modalBottomSheetBackgroundColor = Color(0xFFEAEEFF);
  static const Color folderIconColor = Color.fromARGB(255, 86, 86, 86);
  static const Color inputBackgroundColor = Color.fromARGB(255, 224, 224, 224);
  static const Color inputLabelForeColor = Color.fromARGB(255,117,117,117);
}
