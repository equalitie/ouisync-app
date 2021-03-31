import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const List<PermissionStatus> negativePermissionStatus = [
    PermissionStatus.restricted,
    PermissionStatus.limited,
    PermissionStatus.denied,
    PermissionStatus.permanentlyDenied,
  ];

const String repositoriesFolder = 'repos';

const String titleApp = 'OuiSync';
const String titleRootPage = 'Repositories';

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
const String messageNoRepos = 'No repositories found';
const String messageEmptyRepo = 'This repository is empty';
const String messageEmptyFolder = 'This folder is empty';

const String messageCreateNewRepoStyled = 'Create a new repo using <bold>Actions</bold> <arrow_down/>';
const String messageCreateAddNewObjectStyled = 'Create a new folder, or add a file, using <bold>Actions</bold> <arrow_down/>';

const double actionsDialogPadding = 20.0;
const double actionsDialogAvatarRadius = 45.0;

const int actionsFloatingActionButtonAnimationDuration = 300; //milliseconds

const String flagRepoActionsDialog = 'repo_dialog';
const String flagFolderActionsDialog = 'folder_dialog';

const String actionNewRepo = 'Add repo';

const String actionNewFolder = 'Add folder';
const String actionNewFile = 'Add file';

const Map<String, IconData> repoActions = const { actionNewRepo: Icons.create_new_folder_rounded };
const Map<String, IconData> folderActions = const { 
  actionNewFolder: Icons.create_new_folder_rounded, 
  actionNewFile: Icons.file_upload
};