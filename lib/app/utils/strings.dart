class Strings {
  Strings._();

  /// Configuration
  static const String folderRepositoriesName = 'repositories';
  static const String databaseConfigurationName = 'config.db';

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

  static const String messageAccessModeBlind = 'Your peer can\'t write or read the contents.';
  static const String messageAccessModeRead = 'Can\'t be modified, just access the contents.';
  static const String messageAccessModeWrite = 'Full access. Your peer can read and write.';

  static const String messageBitTorrentDHTStatus = 'BitTorrent DHT is [status]';
  static const String messageBitTorrentDHTEnableFailed = 'BitTorrent DHT could not be enabled';
  static const String messageBitTorrentDHTDisableFailed = 'Disabling BitTorrent DHT failed';

  static const String messageErrorNameFormValidator = 'Please enter a valid name '
  '(unique, no spaces, ...)';

  static const String messageErrorPathNotEmpty = '[path] is not empty';

  // main_page.dart
  static const String messageNoRepo = 'Before adding a file, you need to create a repository';
  static const String messageCreateNewRepo = 'Create a new <bold>repository</bold>,'
  ' or link to one from a friend using a <bold>repository token</bold>';
  static const String messageNoRepos = 'No repositories found';
  static const String messageEmptyRepo = 'This repository is empty';
  static const String messageEmptyFolder = 'This folder is empty';
  static const String messageCreateAddNewItem = 'Create a new <bold>folder</bold>, or add a '
  '<bold>file</bold>, using <icon></icon>';

  // Dialogs

  static const String titleMovingEntry = 'Moving Entry';
  static const String titleFolderActions = 'Add Folders or Files';
  static const String titleCreateFolder = 'Create a folder';
  static const String titleCreateRepository = 'Create a Repository';
  static const String titleAddRepository = 'Add a Repository';
  static const String titleSettings = 'Settings';
  static const String titleRepository = 'Repository';
  static const String titleFileDetails = 'File Details';
  static const String titleFolderDetails = 'Folder Details';
  static const String titleDeleteFolder = 'Delete Folder';
  static const String titleDeleteNotEmptyFolder = 'Delete not Empty Folder';
  static const String titleRepositoriesList = 'Your Repositories';
  static const String titleShareRepository = 'Share [name]';
  static const String titleDeleteFile = 'Delete File';

  static const String labelRepositoryToken = 'Repository token: ';
  static const String labelName = 'Name: ';
  static const String labelLocation = 'Location: ';
  static const String labelSize = 'Size: ';
  static const String labelRepositoryName = 'Repository name: ';
  static const String labelCreatePassword = 'Create a password: : ';
  static const String labelRetypePassword = 'Retype password: ';
  static const String labelCreateFolder = 'Create a new folder: ';
  static const String labelCreateRepository = 'Create a new repository: ';
  static const String labelSyncStatus = 'Sync Status: ';
  static const String labelBitTorrentDHT = 'BitTorrent DHT';
  
  static const String messageMovingEntry = 'This function is not availabe when moving an entry';
  static const String messageRepositoryToken = 'Paste the token here';
  static const String messageRepositoryName = 'Give the repo a name';
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

  static const String mesageNoMediaPresent = 'There is no media present';

  static const String messageEntryTypeDefault = 'An entry';
  static const String messageEntryTypeFolder = 'A folder';
  static const String messageEntryTypeFile = 'A file';

  static const String messageEntryAlreadyExist = '[entry] with the same name already '
  'exist in this location';

  static const String replacementName = '[name]';
  static const String replacementPath = '[path]';
  static const String replacementStatus = '[status]';
  static const String replacementEntry = '[entry]';

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

  static const String actionDeleteFolder = 'Delete folder';

  static const String actionPreviewFile = 'Preview file';
  static const String actionShareFile = 'Share file';
  static const String actionDeleteFile = 'Delete file';

  static const String actionEditRepositoryName = 'Edit name';
  static const String actionDeleteRepository = 'Delete repository';

  static const String actionHide = 'HIDE';
  static const String actionClose = 'CLOSE';

}