import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'utils.dart';

class Constants{
  Constants._();

  static const String repositoriesFolder = 'repos';

  static const int debouncerMiliseconds = 1500; //milliseconds

  static const int actionsFloatingActionButtonAnimationDuration = 300; //milliseconds
  static const int syncAnimationDuration = 1000; //milliseconds

  static const String flagRepoActionsDialog = 'repo_dialog';
  static const String flagFolderActionsDialog = 'folder_dialog';
  static const String flagReceiveShareActionsDialog = 'receive_share_dialog';

  static const String actionPreview = 'preview';
  static const String actionShare = 'share';

  static const Map<String, IconData> repoActions = const { Strings.actionNewRepo: Icons.create_new_folder_rounded };
  static const Map<String, IconData> folderActions = const { 
    Strings.actionDeleteFolder: Icons.delete_sharp,
    Strings.actionNewFolder: Icons.create_new_folder_rounded,
    Strings.actionNewFile: Icons.file_upload
  };

  static const int bufferSize = 64000;
  static const String EndOfFile = "EOF";

  static const String appDirKey = 'APP_DIR';
  static const String repositoriesDirKey = 'REPOS_DIR';
  static const String localRepositoriesKey = 'LOCAL_REPOS';
  static const String currentRepositoryKey = 'CURRENT_REPO';
  static const String sessionStoreKey = 'SESSION_STORE';

  /// In-line text style names
  
  static const String inlineTextBold = 'bold';
  static const String inlineTextSize = 'size';
  static const String inlineTextColor = 'color';
  static const String inlineTextIcon = 'icon';

  // Hero tags

  static const String heroTagMainPageActions = 'MAIN_PAGE_ACTIONS';

  static const String heroTagCreateFolderSharedFile = 'CREATE_FOLDER_SHARED_FILE';
  static const String heroTagSaveToFolderSharedFile = 'SAVE_TO_FOLDER_SHARED_FILE';

  static const Map<AccessMode, String> accessModeDescriptions = const {
    AccessMode.blind: Strings.messageAccessModeBlind,
    AccessMode.read: Strings.messageAccessModeRead,
    AccessMode.write: Strings.messageAccessModeWrite
  };
}