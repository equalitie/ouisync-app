import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'utils.dart';

class Constants{
  Constants._();

  static const String appDirKey = 'APP_DIR';
  static const String repositoriesDirKey = 'REPOS_DIR';
  static const String currentRepositoryKey = 'CURRENT_REPO';
  static const String sessionStoreKey = 'SESSION_STORE';

  static const int bufferSize = 64000;

  /// In-line text style names
  
  static const String inlineTextBold = 'bold';
  static const String inlineTextSize = 'size';
  static const String inlineTextColor = 'color';
  static const String inlineTextIcon = 'icon';

  // Hero tags

  static const String heroTagMainPageActions = 'MAIN_PAGE_ACTIONS';

  static const Map<AccessMode, String> accessModeDescriptions = const {
    AccessMode.blind: Strings.messageAccessModeBlind,
    AccessMode.read: Strings.messageAccessModeRead,
    AccessMode.write: Strings.messageAccessModeWrite
  };
}