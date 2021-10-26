import 'package:flutter/material.dart';

const String repositoriesFolder = 'repos';

const String titleApp = 'OuiSync';
const String titleRootPage = 'Repositories';

const String slash = '/';

const String messageNoStoragePermissionsGranted = 'OuiSync need access to the phone storage to operate.'
'\n\nWithout this permission the app can\'t function properly.'
'\n\nTo grant the permissions needed, please follow the instructions below:\n'
'\n   > Go to Settings'
'\n   > Privacy'
'\n   > Permission manager'
'\n   > Storage'
'\n   > Scroll down to the DENIED apps'
'\n   > Look for OuiSync and select it'
'\n   > Select Allow'
'\n\nThen you can open OuiSync again and use it as expected';
const String messageOhOh = 'Oh oh...';
const String messageErrorState = 'Something went wrong <bold>:\\</bold>';
const String messageNoRepos = 'No lockboxes found';
const String messageEmptyRepo = 'This repository is empty';
const String messageEmptyFolder = 'This folder is empty';
const String messageEmptyFolderStructure = 'Move along, nothing to see here...';
const String messageCreateNewFolderRootToStartStyled = 'Maybe start by creating a new folder using <bold>Actions</bold> <arrow_down/>'
'\n... or just go ahead and use <bold>/</bold>, we are not your mother';
const String messageCreateNewFolderStyled = 'You can create a new folder using (look down <arrow_down/>)'
'\n... or just drop it here, champ';

const String messageCreateNewRepoStyled = 'Create a new lockbox, or link to one from a friend <arrow_down/>';
const String messageCreateAddNewItemStyled = 'Create a new folder, or add a file, using <bold>Actions</bold> <arrow_down/>';

const double actionsDialogPadding = 20.0;
const double actionsDialogAvatarRadius = 10.0;

const int debouncerMiliseconds = 1500; //milliseconds

const int actionsFloatingActionButtonAnimationDuration = 300; //milliseconds
const int syncAnimationDuration = 1000; //milliseconds

const String flagRepoActionsDialog = 'repo_dialog';
const String flagFolderActionsDialog = 'folder_dialog';
const String flagReceiveShareActionsDialog = 'receive_share_dialog';

const String actionNewRepo = 'Create repo';

const String actionNewFolder = 'Create folder';
const String actionNewFile = 'Add file';

const String actionDeleteFolder = 'Delete folder';

const String actionPreviewFile = 'Preview file';
const String actionShareFile = 'Share file';
const String actionDeleteFile = 'Delete file';

const String actionPreview = 'preview';
const String actionShare = 'share';

const Map<String, IconData> repoActions = const { actionNewRepo: Icons.create_new_folder_rounded };
const Map<String, IconData> folderActions = const { 
  actionDeleteFolder: Icons.delete_sharp,
  actionNewFolder: Icons.create_new_folder_rounded,
  actionNewFile: Icons.file_upload
};

const int bufferSize = 64000;
const String EndOfFile = "EOF";

const String appDirKey = 'APP_DIR';
const String repositoriesDirKey = 'REPOS_DIR';
const String localRepositoriesKey = 'LOCAL_REPOS';
const String currentRepositoryKey = 'CURRENT_REPO';
const String sessionStoreKey = 'SESSION_STORE';