// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(access) =>
      "The permission cannot be higger than the repository current access mode: ${access}";

  static String m1(name) => "${name} - downloading canceled";

  static String m2(name) => "${name} - download failed";

  static String m3(entry) => "${entry} already exists.";

  static String m4(path) =>
      "The current folder is missing, navigating to its parent: ${path}";

  static String m5(name) => "Initialization of the repository ${name} failed";

  static String m6(path) => "${path} is not empty";

  static String m7(name) => "Folder deleted successfully: ${name}";

  static String m8(number) =>
      "Do you want to lock all open repositories?\n\n(${number} open)";

  static String m9(path) => "from ${path}";

  static String m10(name) => "Error creating file ${name}";

  static String m11(name) => "We could not delete the repository \"${name}\"";

  static String m12(name) =>
      "We could not find the repository \"${name}\" at the usual location";

  static String m13(access) => "Access mode granted: ${access}";

  static String m14(name) =>
      "This repository already exists in the app under the name \"${name}\".";

  static String m15(name) => "Suggested: ${name}\n(tap here to use this name)";

  static String m16(name) => "${name} writing canceled";

  static String m17(name) => "${name} - writing failed";

  static String m18(name) => "Failed to add repository ${name}";

  static String m19(name) => "Failed to create repository ${name}";

  static String m20(access) => "${access}";

  static String m21(entry) => "${entry}";

  static String m22(name) => "${name}";

  static String m23(number) => "${number}";

  static String m24(path) => "${path}";

  static String m25(status) => "${status}";

  static String m26(name) => "Share repository \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Accept"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ACCEPT"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Add Repository"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Add a Shared Repository"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "actionCancelCapital": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("CLOSE"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Create"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("Create a Repository"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Delete"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("DELETE"),
        "actionDeleteFile": MessageLookupByLibrary.simpleMessage("Delete file"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Delete folder"),
        "actionDeleteRepo":
            MessageLookupByLibrary.simpleMessage("Delete repository"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Delete repository"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Edit name"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Exit"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Hide"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("HIDE"),
        "actionLockCapital": MessageLookupByLibrary.simpleMessage("LOCK"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Move"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("Add file"),
        "actionNewFolder":
            MessageLookupByLibrary.simpleMessage("Create folder"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Create repository"),
        "actionOK": MessageLookupByLibrary.simpleMessage("OK"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Preview file"),
        "actionReloadContents": MessageLookupByLibrary.simpleMessage("Reload"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Reload repository"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Rename"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("Retry"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Save"),
        "actionScanQR": MessageLookupByLibrary.simpleMessage("Scan a QR code"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Share"),
        "actionShareFile": MessageLookupByLibrary.simpleMessage("Share file"),
        "actionShow": MessageLookupByLibrary.simpleMessage("Show"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Unlock"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Access Mode"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("Add an existing repository"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("Create a repository"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("Delete"),
        "iconDownload": MessageLookupByLibrary.simpleMessage("Download"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("Information"),
        "iconMove": MessageLookupByLibrary.simpleMessage("Move"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("Preview"),
        "iconRename": MessageLookupByLibrary.simpleMessage("Rename"),
        "iconShare": MessageLookupByLibrary.simpleMessage("Share"),
        "iconShareTokenWithPeer":
            MessageLookupByLibrary.simpleMessage("Share this with your peer"),
        "labelAppVersion": MessageLookupByLibrary.simpleMessage("App version"),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelCopyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Destination"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Downloaded to:"),
        "labelEndpoint": MessageLookupByLibrary.simpleMessage("Endpoint: "),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Location: "),
        "labelLockAllRepos": MessageLookupByLibrary.simpleMessage("Lock all"),
        "labelName": MessageLookupByLibrary.simpleMessage("Name: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("New name: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Password: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Peers"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("QR code"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Enter the new name: "),
        "labelRepositoryLink":
            MessageLookupByLibrary.simpleMessage("Repository link: "),
        "labelRetypePassword":
            MessageLookupByLibrary.simpleMessage("Retype password: "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("Select repository "),
        "labelSetPermission":
            MessageLookupByLibrary.simpleMessage("Set permission"),
        "labelShareLink": MessageLookupByLibrary.simpleMessage("Share link"),
        "labelSize": MessageLookupByLibrary.simpleMessage("Size: "),
        "labelSyncStatus":
            MessageLookupByLibrary.simpleMessage("Sync Status: "),
        "labelTokenLink":
            MessageLookupByLibrary.simpleMessage("Repository share link"),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("Type password: "),
        "labelUseExternalStorage":
            MessageLookupByLibrary.simpleMessage("Use external storage"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("There is no media present."),
        "messageAccessModeDisabled": m0,
        "messageAck": MessageLookupByLibrary.simpleMessage("Ack!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "This option is not available on read-only repositories"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Add a repository using a token link"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Add a repository using a QR code"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "This repository is locked or is a blind replica.\n\nIf you have the password, unlock it and try again."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "This repository is a read-only replica."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Shortly the OS will ask you for permission to execute this app in the background.\n\nThis is required in order to keep syncing while the app is not in the foreground"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("OuiSync is running"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Your peer cannot write nor read the contents"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
            "This repository is a blind replica."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "The provided <bold>password</bold> does not grant you access to view the content of this repository."),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Changing the extension of a file can make it unusable"),
        "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this file?"),
        "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this folder?"),
        "messageConfirmNotEmptyFolderDeletion":
            MessageLookupByLibrary.simpleMessage(
                "This folder is not empty.\n\nDo you still want to delete it? (this will delete all its contents)"),
        "messageConfirmRepositoryDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to delete this repository?"),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Create a new <bold>folder</bold>, or add a <bold>file</bold>, using <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Create a new <bold>repository</bold>, or link to one from a friend using a <bold>repository token</bold>"),
        "messageCreatingToken":
            MessageLookupByLibrary.simpleMessage("Creating the share token…"),
        "messageDownloadingFileCanceled": m1,
        "messageDownloadingFileError": m2,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "This <bold>folder</bold> is empty"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is empty"),
        "messageEntryAlreadyExist": m3,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("An entry"),
        "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("A file"),
        "messageEntryTypeFolder":
            MessageLookupByLibrary.simpleMessage("A folder"),
        "messageError": MessageLookupByLibrary.simpleMessage("Error!"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "Using \\ or / is not allowed"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Error creating the repository"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Error creating the share token."),
        "messageErrorCurrentPathMissing": m4,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Something went wrong. Please try again."),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Failed."),
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("entry not found"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage("Please enter a valid name."),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "We couldn’t load this folder\'s contents. Please try again."),
        "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
            "Error opening the repository"),
        "messageErrorOpeningRepoDescription": m5,
        "messageErrorPathNotEmpty": m6,
        "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
            "There is already a repository with this name"),
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage("Please enter a password."),
        "messageErrorRetypePassword":
            MessageLookupByLibrary.simpleMessage("The passwords do not match."),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("Please enter a token."),
        "messageErrorTokenInvalid":
            MessageLookupByLibrary.simpleMessage("This token is invalid."),
        "messageErrorTokenValidator":
            MessageLookupByLibrary.simpleMessage("Please enter a valid token."),
        "messageExitOuiSync":
            MessageLookupByLibrary.simpleMessage("Press back again to exit."),
        "messageFile": MessageLookupByLibrary.simpleMessage("file"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("File name"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "File preview is not yet available"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("files"),
        "messageFolderDeleted": m7,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Folder name"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Initializing…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Tap on the <bold>Unlock</bold> button and input the password to access content in this repository."),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Internal crash detected."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Loading…"),
        "messageLockOpenRepos": m8,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is locked."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Locking all open repositories…"),
        "messageMoveEntryOrigin": m9,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "This function is not available when moving an entry."),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Network is unavailable"),
        "messageNewFileError": m10,
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("A new version is available."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Before adding files, you need to create a repository"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("No repositories found"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Nothing here yet!"),
        "messageOr": MessageLookupByLibrary.simpleMessage("Or"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("OuiSync"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "This repository is <bold>read-only</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Cannot be modified, just access the contents"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Rename file"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("Rename folder"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Rename repository"),
        "messageRepoDeletionErrorDescription": m11,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "The repository deletion failed"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "The repository is not there anymore"),
        "messageRepoMissingErrorDescription": m12,
        "messageRepositoryAccessMode": m13,
        "messageRepositoryAlreadyExist": m14,
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Give the repository a name"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Repository new name"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Repository password"),
        "messageRepositorySuggestedName": m15,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Paste the link here"),
        "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
            "Save the file to this folder"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Scan this with your other device or share it with your peers"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Select a permission to create a share link"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Select the location"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "You need to select one permission to create a repository link first"),
        "messageShareWithWR":
            MessageLookupByLibrary.simpleMessage("Share with QR Code"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Syncing is disabled while using mobile internet"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Repository token copied to the clipboard."),
        "messageUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Enter password to unlock"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Full access. Your peer can read and write"),
        "messageWritingFileCanceled": m16,
        "messageWritingFileError": m17,
        "messsageFailedAddRepository": m18,
        "messsageFailedCreateRepository": m19,
        "replacementAccess": m20,
        "replacementEntry": m21,
        "replacementName": m22,
        "replacementNumber": m23,
        "replacementPath": m24,
        "replacementStatus": m25,
        "statusSync": MessageLookupByLibrary.simpleMessage("SYNCED"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("Unspecified"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("About"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("Add file to OuiSync"),
        "titleAddRepoToken":
            MessageLookupByLibrary.simpleMessage("Add a repository with token"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Add a repository"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Permissions needed"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Create a folder"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Create a repository"),
        "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Delete file"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Delete folder"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Delete non-empty folder"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Delete repository"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Download location"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Download to device"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Edit repository"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("File details"),
        "titleFileExtensionChanged":
            MessageLookupByLibrary.simpleMessage("File extension changed"),
        "titleFileExtensionMissing":
            MessageLookupByLibrary.simpleMessage("File extension missing"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Create"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Folder details"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Lock all repositories"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Logs"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Moving entry"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Network"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Your repositories"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Repository"),
        "titleScanRepoQR":
            MessageLookupByLibrary.simpleMessage("Scan Repository QR"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "titleShareRepository": m26,
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Unlock repository"),
        "typeFile": MessageLookupByLibrary.simpleMessage("File"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Folder")
      };
}
