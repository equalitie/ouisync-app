class Strings {
  Strings._();

  /// Configuration
  static const String folderRepositoriesName = 'repositories';
  static const String configuratiosDirName = 'configs';

  /// Page titles
  static const String titleApp = 'OuiSync';
  static const String titleRootPage = 'Repositories';
  static const String titleAddShareFilePage = 'Add file to OuiSync';

  static const String rootPath = '/';
  static const String atSymbol = '@';
  static const String entryTypeFolder = 'Folder';
  static const String entryTypeFile = 'File';
  // State messages

  // General
  static const String messageLoadingContents = 'Loading the folder contents...';
  static const String messageErrorLoadingContents = 'Oooops!\n(Something went wrong trying to do '
  'the thing, sorry about that. Please try again)';

  static const String messageOhOh = '<color>Oh oh...</color> <size><bold>o.0</bold></size>';
  static const String messageErrorState = 'That did not work as we expected <size>'
  '<bold>:\\</bold></size>\nWould you please try again... ? Thanks!\n\n<size><bold>'
  '<icon></icon><bold></size>';

  static const String messageOoops = 'Oooops...';
  static const String mesageLoading = 'Loading...';

  static const String messageAccessModeBlind = 'Your peer can\'t write nor read the contents.';
  static const String messageAccessModeRead = 'Can\'t be modified, just access the contents.';
  static const String messageAccessModeWrite = 'Full access. Your peer can read and write.';

  static const String messageBitTorrentDHTStatus = 'BitTorrent DHT is [status]';
  static const String messageBitTorrentDHTEnableFailed = 'BitTorrent DHT could not be enabled';
  static const String messageBitTorrentDHTDisableFailed = 'Disabling BitTorrent DHT failed';

  static const String messageErrorNameFormValidator = 'Please enter a valid name '
  '(unique, no spaces, ...)';

  static const String messageErrorPathNotEmpty = '[path] is not empty';

  // main_page.dart
  static const String messageNoRepo = 'Before adding a <bold>file</bold>, you need to create a '
  '<bold>repository</bold>';
  static const String messageCreateNewRepo = 'Create a new <bold>repository</bold>,'
  ' or link to one from a friend using a <bold>repository token</bold>';
  static const String messageNoRepos = 'No repositories found';
  static const String messageEmptyRepo = 'This <bold>repository</bold> is empty';
  static const String messageEmptyFolder = 'This <bold>folder</bold> is empty';
  static const String messageCreateAddNewItem = 'Create a new <bold>folder</bold>, or add a '
  '<bold>file</bold>, using <icon></icon>';
  static const String messageLockedRepository = 'This <bold>repository</bold> is locked';
  static const String messageBlindRepository = 'This repository is a blind replica';
  static const String messageBlindRepositoryContent = 'The provided <bold>password</bold> do not grant you access to its contents';
  static const String messageInputPasswordToUnlock = 'Tap on the <bold>Unlock</bold> button an input the password '
  'to access its contents';
  static const String messageUnlockRepository = 'Enter password to unlock';
  static const String messageRenameRepository = 'Rename repository';

  static const String messageNewFile = 'New file: [name]';
  static const String messageNewFileError = 'Error creating file [name]';
  static const String messageWritingFile = 'Writing to file [name] started...';
  static const String messageWritingFileError = 'Writing to file [name] failed';
  static const String messageWritingFileDone = 'File saved successfully: [name]';

  // Dialogs

  static const String titleMovingEntry = 'Moving entry';
  static const String titleFolderActions = 'Create';
  static const String titleCreateFolder = 'Create a folder';
  static const String titleCreateRepository = 'Create a repository';
  static const String titleEditRepository = 'Edit repository';
  static const String titleUnlockRepository = 'Unlock repository';
  static const String titleAddRepository = 'Add a repository';
  static const String titleSettings = 'Settings';
  static const String titleRepository = 'Repository';
  static const String titleFileDetails = 'File details';
  static const String titleFolderDetails = 'Folder details';
  static const String titleDeleteFolder = 'Delete folder';
  static const String titleDeleteNotEmptyFolder = 'Delete not empty folder';
  static const String titleRepositoriesList = 'Your repositories';
  static const String titleShareRepository = 'Share repository "[name]"';
  static const String titleDeleteFile = 'Delete file';
  static const String titleDeleteRepository = 'Delete repository';
  static const String titleExitOuiSync = 'Close OuiSync';

  static const String labelRepositoryToken = 'Token: ';
  static const String labelName = 'Name: ';
  static const String labelNewName = 'New name: ';
  static const String labelLocation = 'Location: ';
  static const String labelSize = 'Size: ';
  static const String labelPassword = 'Password: ';
  static const String labelRetypePassword = 'Retype password: ';
  static const String labelTypePassword = 'Type password:';
  static const String labelSyncStatus = 'Sync Status: ';
  static const String labelBitTorrentDHT = 'BitTorrent DHT';
  static const String labelSelectRepository = 'select repository';
  static const String labelRenameRepository = 'Enter the new name';
  
  static const String messageMovingEntry = 'This function is not availabe when moving an entry';
  static const String messageRepositoryToken = 'Paste the token here';
  static const String messageRepositoryName = 'Give the repository a name';
  static const String messageRepositoryNewName = 'Repository new name';
  static const String messageRepositoryAccessMode = 'Access mode granted: [access]';
  static const String messageRepositorySuggestedName = 'Suggested: [name]\n'
  '(tap here for using this name)';
  static const String messageRepositoryPassword = 'Repository password';
  static const String messageErrorRepositoryPasswordValidation = 'Please enter a password';
  static const String messageErrorRetypePassword = 'The password and retyped password doesn\'t '
  'match';
  static const String messageErrorTokenInvalid = 'The token seems to be invalid';
  static const String messageErrorTokenValidator = 'Please enter a valid token';
  static const String messageErrorTokenEmpty = 'Please enter a token';
  static const String messageCreateFolder = 'Folder name';
  static const String messageConfirmFolderDeletion = 'Are you sure you want to delete this folder?';
  static const String messageConfirmNotEmptyFolderDeletion = 'This folder is not empty.\n\n'
  'Do you still want to delete it? (this will delete all its contents)';
  static const String messageError = 'Error!';
  static const String messageAck = 'Ack!';
  static const String messageCreatingToken = 'Creating the share token...';
  static const String messageErrorCreatingToken = 'Error while creating the share token';
  static const String messageTokenCopiedToClipboard = 'Repository token copied to the clipboard';
  static const String messageMoveEntryOrigin = 'from [path]';
  static const String messageConfirmFileDeletion = 'Are you sure you want to delete this file?';

  static const String messageConfirmRepositoryDeletion = 'Are you sure you want to delete this repository?';

  static const String mesageNoMediaPresent = 'There is no media present';

  static const String messageEntryTypeDefault = 'An entry';
  static const String messageEntryTypeFolder = 'A folder';
  static const String messageEntryTypeFile = 'A file';

  static const String messageEntryAlreadyExist = '[entry] with the same name already '
  'exist in this location';

  static const String messageFileDeleted = 'File deleted successfully: [name]';
  static const String messageFolderDeleted = 'Folder deleted successfully: [name]';

  static const String messageExitOuiSync = 'Do you want to close the app?';

  static const String messageInitializing = 'Initializing...';

  static const String replacementName = '[name]';
  static const String replacementPath = '[path]';
  static const String replacementStatus = '[status]';
  static const String replacementEntry = '[entry]';
  static const String replacementAccess = '[access]';

  static const String statusSync = 'SYNCED';

  static const String iconInformation = 'Information';
  static const String iconPreview = 'Preview';
  static const String iconShare = 'Share';
  static const String iconMove = 'Move';
  static const String iconDelete = 'Delete';
  static const String iconCreateRepository = 'Create a new repository';
  static const String iconAddRepositoryWithToken = 'Add a repository with token';
  static const String iconAccessMode = 'Access mode';
  static const String iconShareTokenWithPeer = 'Share this with your peer';

  // Buttons text

  static const String actionCreateRepository = 'Create a Repository';
  static const String actionAddRepositoryWithToken = 'Add a Shared Repository';

  static const String actionReloadContents = 'Reload';

  static const String actionNewRepo = 'Create repository';
  static const String actionNewFolder = 'Create folder';
  static const String actionNewFile = 'Add file';
  static const String actionCreate = 'Create';
  static const String actionCancel = 'Cancel';
  static const String actionDelete = 'Delete';
  static const String actionMove = 'Move';
  static const String actionSave = 'Save';
  static const String actionUnlock = 'Unlock';
  static const String actionRetry = 'Retry';
  static const String actionEdit = 'Edit';
  static const String actionShare = 'Share';
  static const String actionRename = 'Rename';
  static const String actionAccept = 'Accept';

  static const String actionDeleteFolder = 'Delete folder';

  static const String actionPreviewFile = 'Preview file';
  static const String actionShareFile = 'Share file';
  static const String actionDeleteFile = 'Delete file';

  static const String actionEditRepositoryName = 'Edit name';
  static const String actionDeleteRepository = 'Delete repository';

  static const String actionAcceptCapital = 'ACCEPT';
  static const String actionCancelCapital = 'CANCEL';
  static const String actionHideCapital = 'HIDE';
  static const String actionCloseCapital = 'CLOSE';
  static const String actionDeleteCapital = 'DELETE';

}
