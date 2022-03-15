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

  static String m0(status) => "BitTorrent DHT is ${status}";

  static String m1(entry) =>
      "${entry} with the same name already exist in this location";

  static String m2(path) =>
      "The current folder is missing, navigating  to its parent: ${path}";

  static String m3(path) => "${path} is not empty";

  static String m4(name) => "File deleted successfully: ${name}";

  static String m5(name) => "Folder deleted successfully: ${name}";

  static String m6(path) => "from ${path}";

  static String m7(name) => "Error creating file ${name}";

  static String m8(access) => "Access mode granted: ${access}";

  static String m9(name) =>
      "Suggested: ${name}\n(tap here for using this name)";

  static String m10(name) => "${name} - saved successfully";

  static String m11(name) => "${name} - writing failed";

  static String m12(access) => "${access}";

  static String m13(entry) => "${entry}";

  static String m14(name) => "${name}";

  static String m15(path) => "${path}";

  static String m16(status) => "${status}";

  static String m17(name) => "Share repository \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Accept"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ACCEPT"),
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
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Delete repository"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Edit name"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("HIDE"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Move"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("Add file"),
        "actionNewFolder":
            MessageLookupByLibrary.simpleMessage("Create folder"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Create repository"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Preview file"),
        "actionReloadContents": MessageLookupByLibrary.simpleMessage("Reload"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Rename"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("Retry"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Save"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Share"),
        "actionShareFile": MessageLookupByLibrary.simpleMessage("Share file"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Unlock"),
        "appTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Access mode"),
        "iconAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Add a repository with token"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("Create a new repository"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("Delete"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("Information"),
        "iconMove": MessageLookupByLibrary.simpleMessage("Move"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("Preview"),
        "iconShare": MessageLookupByLibrary.simpleMessage("Share"),
        "iconShareTokenWithPeer":
            MessageLookupByLibrary.simpleMessage("Share this with your peer"),
        "labelAppVersion":
            MessageLookupByLibrary.simpleMessage("App version: "),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelEndpoint": MessageLookupByLibrary.simpleMessage("Endpoint: "),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Location: "),
        "labelName": MessageLookupByLibrary.simpleMessage("Name: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("New name: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Password: "),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Enter the new name"),
        "labelRepositoryToken": MessageLookupByLibrary.simpleMessage("Token: "),
        "labelRetypePassword":
            MessageLookupByLibrary.simpleMessage("Retype password: "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("select repository"),
        "labelSize": MessageLookupByLibrary.simpleMessage("Size: "),
        "labelSyncStatus":
            MessageLookupByLibrary.simpleMessage("Sync Status: "),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("Type password: "),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("There is no media present"),
        "messageAck": MessageLookupByLibrary.simpleMessage("Ack!"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "This repository is locked or is a blind replica.\n\nIf you have the password, unlock it and try again."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "This repository is a read-only replica."),
        "messageBitTorrentDHTDisableFailed":
            MessageLookupByLibrary.simpleMessage(
                "Disabling BitTorrent DHT failed"),
        "messageBitTorrentDHTEnableFailed":
            MessageLookupByLibrary.simpleMessage(
                "BitTorrent DHT could not be enabled"),
        "messageBitTorrentDHTStatus": m0,
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Your peer can not write nor read the contents"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
            "This repository is a blind replica"),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "The provided <bold>password</bold> do not grant you access to its contents"),
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
        "messageCreateFolder":
            MessageLookupByLibrary.simpleMessage("Folder name"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Create a new <bold>repository</bold>, or link to one from a friend using a <bold>repository token</bold>"),
        "messageCreatingToken":
            MessageLookupByLibrary.simpleMessage("Creating the share token..."),
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "This <bold>folder</bold> is empty"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is empty"),
        "messageEntryAlreadyExist": m1,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("An entry"),
        "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("A file"),
        "messageEntryTypeFolder":
            MessageLookupByLibrary.simpleMessage("A folder"),
        "messageError": MessageLookupByLibrary.simpleMessage("Error!"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Error while creating the share token"),
        "messageErrorCurrentPathMissing": m2,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Something went wrong. Please try again"),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Failed"),
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("entry not found"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage(
                "Please enter a valid name (unique, no spaces, …)"),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "We couldn’t load this folder contents. Please try again"),
        "messageErrorPathNotEmpty": m3,
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage("Please enter a password"),
        "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
            "The password and retyped password do not match"),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("Please enter a token"),
        "messageErrorTokenInvalid": MessageLookupByLibrary.simpleMessage(
            "The token seems to be invalid"),
        "messageErrorTokenValidator":
            MessageLookupByLibrary.simpleMessage("Please enter a valid token"),
        "messageExitOuiSync":
            MessageLookupByLibrary.simpleMessage("Press back again to exit"),
        "messageFileDeleted": m4,
        "messageFolderDeleted": m5,
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Initializing..."),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Tap on the <bold>Unlock</bold> button and input the password to access its contents"),
        "messageLoadingContents": MessageLookupByLibrary.simpleMessage(
            "Loading the folder contents…"),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Loading…"),
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is locked"),
        "messageMoveEntryOrigin": m6,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "This function is not available when moving an entry"),
        "messageNewFileError": m7,
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Before adding a <bold>file</bold>, you need to create a <bold>repository</bold>"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("No repositories found"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "This repository is <bold>read-only</bold>"),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Can not be modified, just access the contents"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Rename repository"),
        "messageRepositoryAccessMode": m8,
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Give the repository a name"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Repository new name"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Repository password"),
        "messageRepositorySuggestedName": m9,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Paste the token here"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Repository token copied to the clipboard"),
        "messageUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Enter password to unlock"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Full access. Your peer can read and write"),
        "messageWritingFileDone": m10,
        "messageWritingFileError": m11,
        "replacementAccess": m12,
        "replacementEntry": m13,
        "replacementName": m14,
        "replacementPath": m15,
        "replacementStatus": m16,
        "statusSync": MessageLookupByLibrary.simpleMessage("SYNCED"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("Unspecified"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("Add file to OuiSync"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Add a repository"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Create a folder"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Create a repository"),
        "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Delete file"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Delete folder"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Delete not empty folder"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Delete repository"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Edit repository"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("File details"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Create"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Folder details"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Logs"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Moving entry"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Network"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Your repositories"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Repository"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "titleShareRepository": m17,
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Unlock repository"),
        "typeFile": MessageLookupByLibrary.simpleMessage("File"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Folder")
      };
}
