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

  static String m1(name) =>
      "Biometric validation added for repository \"${name}\"";

  static String m2(name) => "${name} - downloading canceled";

  static String m3(name) => "${name} - download failed";

  static String m4(entry) => "${entry} already exists.";

  static String m5(path) =>
      "The current folder is missing, navigating to its parent: ${path}";

  static String m6(name) => "Initialization of the repository ${name} failed";

  static String m7(path) => "${path} is not empty";

  static String m8(name) => "Folder deleted successfully: ${name}";

  static String m9(number) =>
      "Do you want to lock all open repositories?\n\n(${number} open)";

  static String m10(path) => "from ${path}";

  static String m11(name) => "Error creating file ${name}";

  static String m12(name) => "We could not delete the repository \"${name}\"";

  static String m13(name) =>
      "We could not find the repository \"${name}\" at the usual location";

  static String m14(access) => "Access mode granted: ${access}";

  static String m15(name) =>
      "This repository already exists in the app under the name \"${name}\".";

  static String m16(name) => "Suggested: ${name}\n(tap here to use this name)";

  static String m17(access) => "Unlocked as a ${access} replica";

  static String m18(name) => "${name} writing canceled";

  static String m19(name) => "${name} - writing failed";

  static String m20(name) => "Failed to add repository ${name}";

  static String m21(name) => "Failed to create repository ${name}";

  static String m22(access) => "${access}";

  static String m23(entry) => "${entry}";

  static String m24(name) => "${name}";

  static String m25(number) => "${number}";

  static String m26(path) => "${path}";

  static String m27(status) => "${status}";

  static String m28(name) => "Share repository \"${name}\"";

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
            MessageLookupByLibrary.simpleMessage("Create a New Repository"),
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
        "actionRemove": MessageLookupByLibrary.simpleMessage("Remove"),
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
            MessageLookupByLibrary.simpleMessage("Create a new repository"),
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
        "messageAlertSaveCopyPassword": MessageLookupByLibrary.simpleMessage(
            "If you remove the biometric validation, once you navigate out of this screen you wont be able to see or copy the password anymore; please save it in a secure place."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Shortly the OS will ask you for permission to execute this app in the background.\n\nThis is required in order to keep syncing while the app is not in the foreground"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("OuiSync is running"),
        "messageBiometricValidationAdded": m1,
        "messageBiometricValidationRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Biometric validation removed"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Your peer cannot write nor read the contents"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
            "This repository is a blind replica."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "The provided <bold>password</bold> does not grant you access to view the content of this repository."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
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
        "messageDownloadingFileCanceled": m2,
        "messageDownloadingFileError": m3,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "This <bold>folder</bold> is empty"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is empty"),
        "messageEntryAlreadyExist": m4,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("An entry"),
        "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("A file"),
        "messageEntryTypeFolder":
            MessageLookupByLibrary.simpleMessage("A folder"),
        "messageError": MessageLookupByLibrary.simpleMessage("Error!"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "There was an error authenticathing using biometrics. Please try again"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "Using \\ or / is not allowed"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Error creating the repository"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Error creating the share token."),
        "messageErrorCurrentPathMissing": m5,
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
        "messageErrorOpeningRepoDescription": m6,
        "messageErrorPathNotEmpty": m7,
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
        "messageErrorUnhandledState":
            MessageLookupByLibrary.simpleMessage("Error: unhandled state"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync":
            MessageLookupByLibrary.simpleMessage("Press back again to exit."),
        "messageFile": MessageLookupByLibrary.simpleMessage("file"),
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "File is already being uploaded"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("File name"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "File preview is not yet available"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("files"),
        "messageFolderDeleted": m8,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Folder name"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Generate password"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Initializing…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Tap on the <bold>Unlock</bold> button and input the password to access content in this repository."),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Internal crash detected."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Loading…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Local Discovery"),
        "messageLockOpenRepos": m9,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is locked."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Locking all open repositories…"),
        "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("All"),
        "messageLogLevelErroWarnInfoDebug":
            MessageLookupByLibrary.simpleMessage("Error, Warn, Info and Debug"),
        "messageLogLevelError":
            MessageLookupByLibrary.simpleMessage("Only Error"),
        "messageLogLevelErrorWarn":
            MessageLookupByLibrary.simpleMessage("Error and Warn"),
        "messageLogLevelErrorWarnInfo":
            MessageLookupByLibrary.simpleMessage("Error, Warn and Info"),
        "messageLogViewer": MessageLookupByLibrary.simpleMessage("Log viewer"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Mobile"),
        "messageMoveEntryOrigin": m10,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "This function is not available when moving an entry."),
        "messageNATType": MessageLookupByLibrary.simpleMessage("NAT type"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Network is unavailable"),
        "messageNewFileError": m11,
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("A new version is available."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Before adding files, you need to create a repository"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("No repositories found"),
        "messageNone": MessageLookupByLibrary.simpleMessage("None"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Nothing here yet!"),
        "messageOr": MessageLookupByLibrary.simpleMessage("Or"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("OuiSync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Password"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Password copied to the clipboard"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Peer Exchange"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "This repository is <bold>read-only</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Cannot be modified, just access the contents"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Remember to securely save the password; if you forget it, there is no way to retrieve it."),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage("Remove biometric validation"),
        "messageRemoveBiometricsConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to remove this repository biometrics?"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Rename file"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("Rename folder"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Rename repository"),
        "messageRepoDeletionErrorDescription": m12,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "The repository deletion failed"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "The repository is not there anymore"),
        "messageRepoMissingErrorDescription": m13,
        "messageRepositoryAccessMode": m14,
        "messageRepositoryAlreadyExist": m15,
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Give the repository a name"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Repository new name"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Repository password"),
        "messageRepositorySuggestedName": m16,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Paste the link here"),
        "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
            "Save the file to this folder"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Scan this with your other device or share it with your peers"),
        "messageSecureUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Secure using biometrics"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Select a permission to create a share link"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Select the location"),
        "messageSettingsRuntimeID":
            MessageLookupByLibrary.simpleMessage("Runtime ID"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "You need to select one permission to create a repository link first"),
        "messageShareWithWR":
            MessageLookupByLibrary.simpleMessage("Share with QR Code"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Sync while using mobile data"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Syncing is disabled while using mobile internet"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Repository token copied to the clipboard."),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "The password did not unlock the repository"),
        "messageUnlockRepoOk": m17,
        "messageUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Enter password to unlock"),
        "messageUnlockUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Unlock using biometrics"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Log verbosity"),
        "messageView": MessageLookupByLibrary.simpleMessage("View"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Full access. Your peer can read and write"),
        "messageWritingFileCanceled": m18,
        "messageWritingFileError": m19,
        "messsageFailedAddRepository": m20,
        "messsageFailedCreateRepository": m21,
        "replacementAccess": m22,
        "replacementEntry": m23,
        "replacementName": m24,
        "replacementNumber": m25,
        "replacementPath": m26,
        "replacementStatus": m27,
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
            MessageLookupByLibrary.simpleMessage("Create a new repository"),
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
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Remove biometrics"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Your repositories"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Repository"),
        "titleRepositoryName":
            MessageLookupByLibrary.simpleMessage("Repository name"),
        "titleScanRepoQR":
            MessageLookupByLibrary.simpleMessage("Scan Repository QR"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("Security"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "titleShareRepository": m28,
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("State Monitor"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Unlock repository"),
        "typeFile": MessageLookupByLibrary.simpleMessage("File"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Folder")
      };
}
