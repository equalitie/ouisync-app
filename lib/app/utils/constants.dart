import 'package:flutter/material.dart';
import 'utils.dart';

class Constants{
  Constants._();

  static const String repositoriesFolder = 'repos';

  static const double actionsDialogPadding = 20.0;
  static const double actionsDialogAvatarRadius = 10.0;

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
}