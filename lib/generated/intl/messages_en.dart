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

  static String m8(name) =>
      "${name} already exist in this location.\n\nWhat do you want to do?";

  static String m9(name) => "Folder deleted successfully: ${name}";

  static String m10(number) =>
      "Do you want to lock all open repositories?\n\n(${number} open)";

  static String m11(path) => "from ${path}";

  static String m12(name) => "Error creating file ${name}";

  static String m13(name) => "Error opening file ${name}";

  static String m14(name) => "We could not delete the repository \"${name}\"";

  static String m15(name) =>
      "We could not find the repository \"${name}\" at the usual location";

  static String m16(access) => "Access mode granted: ${access}";

  static String m17(name) =>
      "This repository already exists in the app under the name \"${name}\".";

  static String m18(name) => "Suggested: ${name}\n(tap here to use this name)";

  static String m19(access) => "Unlocked as a ${access} replica";

  static String m20(name) => "${name} writing canceled";

  static String m21(name) => "${name} - writing failed";

  static String m22(name) => "Failed to import repository ${name}";

  static String m23(name) => "Failed to create repository ${name}";

  static String m24(access) => "${access}";

  static String m25(changes) => "${changes}";

  static String m26(entry) => "${entry}";

  static String m27(name) => "${name}";

  static String m28(number) => "${number}";

  static String m29(path) => "${path}";

  static String m30(status) => "${status}";

  static String m31(name) => "Share repository \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Accept"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ACCEPT"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Import a Repository"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Import Repository"),
        "actionBack": MessageLookupByLibrary.simpleMessage("Back"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "actionCancelCapital": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "actionClear": MessageLookupByLibrary.simpleMessage("Clear"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("CLOSE"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Create"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("Create Repository"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Delete"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("DELETE"),
        "actionDeleteFile": MessageLookupByLibrary.simpleMessage("Delete file"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Delete folder"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Delete repository"),
        "actionDiscard": MessageLookupByLibrary.simpleMessage("Discard"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Edit name"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Exit"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Go to settings"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Hide"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("HIDE"),
        "actionImport": MessageLookupByLibrary.simpleMessage("Import"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("Import repository"),
        "actionLockCapital": MessageLookupByLibrary.simpleMessage("LOCK"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Move"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("File"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("Folder"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Create repository"),
        "actionOK": MessageLookupByLibrary.simpleMessage("OK"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Preview file"),
        "actionReloadContents": MessageLookupByLibrary.simpleMessage("Reload"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Reload repository"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("Remove"),
        "actionRemoveRepo":
            MessageLookupByLibrary.simpleMessage("Remove repository"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Rename"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("Retry"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Save"),
        "actionSaveChanges":
            MessageLookupByLibrary.simpleMessage("Save changes"),
        "actionScanQR": MessageLookupByLibrary.simpleMessage("Scan a QR code"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Share"),
        "actionShareFile": MessageLookupByLibrary.simpleMessage("Share file"),
        "actionShow": MessageLookupByLibrary.simpleMessage("Show"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Undo"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Unlock"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Access Mode"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("Import a repository"),
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
        "labelRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Current password"),
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
        "menuItemAbout": MessageLookupByLibrary.simpleMessage("About"),
        "menuItemLogs": MessageLookupByLibrary.simpleMessage("Logs"),
        "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Network"),
        "menuItemRepository":
            MessageLookupByLibrary.simpleMessage("Repository"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("There is no media present."),
        "messageAccessModeDisabled": m0,
        "messageAccessingSecureStorage":
            MessageLookupByLibrary.simpleMessage("Accessing secure storage"),
        "messageAck": MessageLookupByLibrary.simpleMessage("Ack!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "This option is not available on read-only repositories"),
        "messageAddLocalPassword":
            MessageLookupByLibrary.simpleMessage("Add local password"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Import a repository using a token link"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Import a repository using a QR code"),
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
        "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Biometric authentication failed"),
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
        "messageCamera": MessageLookupByLibrary.simpleMessage("Camera"),
        "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
            "We need this permission to use the camera and read the QR code"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Changing the extension of a file can make it unusable"),
        "messageChangeLocalPassword":
            MessageLookupByLibrary.simpleMessage("Change local password"),
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
        "messageErrorAddingLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Adding a local password failed"),
        "messageErrorAddingSecureStorge": MessageLookupByLibrary.simpleMessage(
            "Adding a local password failed"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "There was an error authenticathing using biometrics. Please try again"),
        "messageErrorChangingLocalPassword":
            MessageLookupByLibrary.simpleMessage(
                "Changing local password failed"),
        "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
            "There was a problem changing the password. Please try again"),
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
        "messageErrorNewPasswordSameOldPassword":
            MessageLookupByLibrary.simpleMessage(
                "The new password is the same as the old password"),
        "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
            "Error opening the repository"),
        "messageErrorOpeningRepoDescription": m6,
        "messageErrorPathNotEmpty": m7,
        "messageErrorRemovingPassword": MessageLookupByLibrary.simpleMessage(
            "Removing the password failed"),
        "messageErrorRemovingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Removing the password from the secure storage failed"),
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
        "messageErrorUpdatingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Updating the password in the secure storage failed"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync":
            MessageLookupByLibrary.simpleMessage("Press back again to exit."),
        "messageFile": MessageLookupByLibrary.simpleMessage("file"),
        "messageFileAlreadyExist": m8,
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "File is already being uploaded"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("File name"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "File preview is not yet available"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("files"),
        "messageFolderDeleted": m9,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Folder name"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Generate password"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("Granted"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "Granting this permission requires navigating to the settings:\n\n Settings > Apps & notifications"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "Allows the app to keep syncing in the background"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Initializing…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Tap on the <bold>Unlock</bold> button and input the password to access content in this repository."),
        "messageKeepBothFiles":
            MessageLookupByLibrary.simpleMessage("Keep both files"),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Internal crash detected."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Loading…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Local Discovery"),
        "messageLockOpenRepos": m10,
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
        "messageMoveEntryOrigin": m11,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "This function is not available when moving an entry."),
        "messageNATType": MessageLookupByLibrary.simpleMessage("NAT type"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Network is unavailable"),
        "messageNewFileError": m12,
        "messageNewPassword":
            MessageLookupByLibrary.simpleMessage("New password"),
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "New password copied to the clipboard"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("A new version is available."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Before adding files, you need to create a repository"),
        "messageNoRepoIsSelected":
            MessageLookupByLibrary.simpleMessage("No repository is selected"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("No repositories found"),
        "messageNone": MessageLookupByLibrary.simpleMessage("None"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Nothing here yet!"),
        "messageOpenFileError": m13,
        "messageOr": MessageLookupByLibrary.simpleMessage("Or"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("OuiSync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Password"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Password copied to the clipboard"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Peer Exchange"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("This permission is required"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "This repository is <bold>read-only</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Cannot be modified, just access the contents"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Remember to securely save the password; if you forget it, there is no way to retrieve it."),
        "messageRemovaLocalPassword":
            MessageLookupByLibrary.simpleMessage("Remove local password"),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage("Remove biometric validation"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Remove biometrics"),
        "messageRemoveBiometricsConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to remove this repository biometrics?"),
        "messageRemovedInBrackets":
            MessageLookupByLibrary.simpleMessage("<removed>"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Rename file"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("Rename folder"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Rename repository"),
        "messageReplaceExistingFile":
            MessageLookupByLibrary.simpleMessage("Replace existing file"),
        "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Repository authentication failed"),
        "messageRepoDeletionErrorDescription": m14,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "The repository deletion failed"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "The repository is not there anymore"),
        "messageRepoMissingErrorDescription": m15,
        "messageRepositoryAccessMode": m16,
        "messageRepositoryAlreadyExist": m17,
        "messageRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("The current password"),
        "messageRepositoryIsNotOpen":
            MessageLookupByLibrary.simpleMessage("The repository is not open"),
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Give the repository a name"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Repository new name"),
        "messageRepositoryNewPassword":
            MessageLookupByLibrary.simpleMessage("New password"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Password"),
        "messageRepositorySuggestedName": m18,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Paste the link here"),
        "messageSaveLogFile":
            MessageLookupByLibrary.simpleMessage("Save log file"),
        "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
            "Save the file to this folder"),
        "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
            "Do you want to save the current changes?"),
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
        "messageStorage": MessageLookupByLibrary.simpleMessage("Storage"),
        "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
            "Needed for getting access to the files"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Sync while using mobile data"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Syncing is disabled while using mobile internet"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Repository token copied to the clipboard."),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "The password did not unlock the repository"),
        "messageUnlockRepoOk": m19,
        "messageUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Enter password to unlock"),
        "messageUnlockUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Unlock using biometrics"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "You have unsaved changes.\n\nDo you want to discard them?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
        "messageValidateLocalPassword":
            MessageLookupByLibrary.simpleMessage("Validate local password"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Log verbosity"),
        "messageView": MessageLookupByLibrary.simpleMessage("View"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Full access. Your peer can read and write"),
        "messageWritingFileCanceled": m20,
        "messageWritingFileError": m21,
        "messsageFailedAddRepository": m22,
        "messsageFailedCreateRepository": m23,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Change password"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Copy password"),
        "replacementAccess": m24,
        "replacementChanges": m25,
        "replacementEntry": m26,
        "replacementName": m27,
        "replacementNumber": m28,
        "replacementPath": m29,
        "replacementStatus": m30,
        "statusSync": MessageLookupByLibrary.simpleMessage("SYNCED"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("Unspecified"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("About"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("Add file to OuiSync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Import a repository with token"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Import a repository"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Permissions needed"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("Change password"),
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
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Add"),
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
        "titleRequiredPermission":
            MessageLookupByLibrary.simpleMessage("Required permission"),
        "titleSaveChanges":
            MessageLookupByLibrary.simpleMessage("Save changes"),
        "titleScanRepoQR":
            MessageLookupByLibrary.simpleMessage("Scan Repository QR"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("Security"),
        "titleSetPasswordFor":
            MessageLookupByLibrary.simpleMessage("Set password for"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "titleShareRepository": m31,
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("State Monitor"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Unlock repository"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Unsaved changes"),
        "typeFile": MessageLookupByLibrary.simpleMessage("File"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Folder")
      };
}
