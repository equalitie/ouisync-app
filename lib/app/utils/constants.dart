import 'package:flutter/material.dart';

class Constants{
  Constants._();

  static const String folderRepositoriesName = 'repositories';
  static const String configuratiosDirName = 'configs';

  static const int bufferSize = 64000;

  static const int maxCharacterRepoTokenForDisplay = 8;
  static const String ouisyncUrl = 'https://ouisync.net/';

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

  static const String appIcon = './assets/Ouisync-icon-blue.png';
  static const String windowsAppIcon = './assets/Ouisync-icon-blue.ico';

  static const String eventLeftMouseUp = 'leftMouseUp';
  static const String eventRightMouseUp = 'rightMouseUp';
}
