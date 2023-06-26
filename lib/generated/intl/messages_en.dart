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
        "actionDone": MessageLookupByLibrary.simpleMessage("Done"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Edit name"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Exit"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Go to settings"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Hide"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("HIDE"),
        "actionIAgree": MessageLookupByLibrary.simpleMessage("I agree"),
        "actionIDontAgree":
            MessageLookupByLibrary.simpleMessage("I don\'t agree"),
        "actionImport": MessageLookupByLibrary.simpleMessage("Import"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("Import repository"),
        "actionLockCapital": MessageLookupByLibrary.simpleMessage("LOCK"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Move"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("File"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("Folder"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Create repository"),
        "actionNext": MessageLookupByLibrary.simpleMessage("Next"),
        "actionNo": MessageLookupByLibrary.simpleMessage("No"),
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
        "actionSkip": MessageLookupByLibrary.simpleMessage("Skip"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Undo"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Unlock"),
        "actionYes": MessageLookupByLibrary.simpleMessage("Yes"),
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
        "labelAttachLogs": MessageLookupByLibrary.simpleMessage("Attach logs"),
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
            MessageLookupByLibrary.simpleMessage("Is running"),
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
        "messageBy": MessageLookupByLibrary.simpleMessage("by"),
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
        "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
            "Declaration for Distributed Online Services"),
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
        "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
            "Basic rights and fundamental freedoms are inherent, inalienable and apply equally to everyone. Human rights are universal; protected in international law and enshrined in the "),
        "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
            "As an organisation, we seek to be transparent with our policies and procedures. As often as possible, our source code is open and freely available, protected by licences that encourage community-driven development, sharing and the propagation of these principles"),
        "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
            "The ability to express oneself freely and to access public information is the backbone of a true democracy. Public information should be in the public domain. Freedom of expression includes active and heated debate, even arguments that are inelegantly articulated, poorly constructed and that may be considered offensive to some. However, freedom of expression is not an absolute right. We stand firmly against violence and the incitement to violate the rights of others, especially the propagation of violence, hate, discrimination and disenfranchisement of any identifiable ethnic or social group"),
        "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
            "We operate from different countries and come from various social backgrounds. We work together towards a society that will respect and defend the rights of others in the physical and the digital world. The International Bill of Rights articulates the suite of human rights that inspires our work; we believe that people have a right and a duty to protect these rights"),
        "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
            "We understand that our tools and services can be abused to contravene these principles and our terms of service, and we firmly and actively condemn and forbid such usage. We neither permit our software and services to be used to further the commission of illicit activities, nor will we assist in the propagation of hate speech or the promotion of violence through the Internet"),
        "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
            "We have put safeguards in place to mitigate the misuse of our products and services. When we become aware of any use that violates our principles or terms of service, we take action to stop it. Guided by our internal policies, we carefully deliberate over acts that might compromise our principles. Our procedures will continue to evolve based on experience and best practices so that we can achieve the right balance between enabling open access to our products and services, and upholding our principles"),
        "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
            "Brave people risk life and liberty to defend human rights, to mobilise, to criticise and to expose the perpetrators of abuse. Brave people voice support for others, for ideas, and communicate their concerns to the world. These brave people exercise their human rights online"),
        "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
            "The Internet is a platform for free expression and self-determination. Like any communication tool, the Internet is not immune from censorship, surveillance, attacks and attempts by state actors and criminal groups to silence dissident voices. When democratic expression is criminalised, when there is ethnic and political discrimination, the Internet becomes another battleground for non-violent resistance"),
        "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
            "Our mission is to promote and defend fundamental freedoms and human rights, including the free flow of information online. Our goal is to create accessible technology and improve the skill set needed for defending human rights and freedoms in the digital age"),
        "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
            "We aim to educate and raise the capacity of our constituents to enjoy secure operations in the digital domain. We do this by building tools that enable and protect free expression, circumvent censorship, empower anonymity and protect from surveillance where and when necessary. Our tools also improve information management and analytic functions"),
        "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
            "We are an international group of activists of diverse backgrounds and beliefs, standing together to defend the principles common among us. We are software developers, cryptographers, security specialists, as well as educators, sociologists, historians, anthropologists and journalists. We develop open and reusable tools with a focus on privacy, online security and better information management. We finance our operations with public grants and consultancies with the private sector. We believe in an Internet that is free from intrusive and unjustified surveillance, censorship and oppression"),
        "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
            "Inspired by the International Bill of Human Rights, our principles apply to every individual, group and organ of society that we work with, including the beneficiaries of the software and services we release. All of our projects are designed with our principles in mind. Our knowledge, tools and services are available to these groups and individuals as long as our principles and terms of service are respected"),
        "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
            "The right to privacy is a fundamental right that we aim to protect whenever and wherever possible. The privacy of our direct beneficiaries is sacrosanct to our operations. Our tools, services and internal policies are designed to this effect. We will use all technical and legal resources at our disposal to protect the privacy of our beneficiaries. Please refer to our Privacy Policy and our "),
        "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
            "Security is a constant thematic throughout all of our software development, service provision and capacity-building projects. We design our systems and processes to improve information security on the Internet and raise the user’s security profile and experience. We try to lead by example by not compromising the security properties of a tool or system for the sake of speed, usability or cost. We do not believe in security through obscurity and we maintain transparency through open access to our code base. We always err on the side of caution and try to implement good internal operational security"),
        "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
            "is built in line with our values.\n\nBy using it you agree to abide by these principles."),
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
        "messageFAQ":
            MessageLookupByLibrary.simpleMessage("Frequently Asked Questions"),
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
        "messageInternationalBillHumanRights":
            MessageLookupByLibrary.simpleMessage(
                "International Bill of Human Rights"),
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
        "messageMissingBackgroundServicePermission":
            MessageLookupByLibrary.simpleMessage(
                "Ouisync does not have permission to run in the background, opening another application may stop ongoing synchronization"),
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
        "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Share files to all of your devices or with others and build your own secure cloud!"),
        "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Repositories can be shared as read-write, read-only, or blind (you store files for others, but cannot access them)"),
        "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "All files and folders added to Ouisync are securely encrypted by default, both in transit and at rest."),
        "messageOpenFileError": m13,
        "messageOr": MessageLookupByLibrary.simpleMessage("Or"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("Ouisync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Password"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Password copied to the clipboard"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Peer Exchange"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("This permission is required"),
        "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
            "“Man is born free, and everywhere he is in chains.”"),
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
        "messageRousseau":
            MessageLookupByLibrary.simpleMessage("Jean-Jacques Rousseau"),
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
        "messageTapForValues":
            MessageLookupByLibrary.simpleMessage("Tap here to read our values"),
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
            MessageLookupByLibrary.simpleMessage("Add file to Ouisync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Import a repository with token"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Import a repository"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
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
        "titleDigitalSecurity":
            MessageLookupByLibrary.simpleMessage("Digital Security"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Download location"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Download to device"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Edit repository"),
        "titleEqualitiesValues":
            MessageLookupByLibrary.simpleMessage("eQualitie’s Values"),
        "titleFAQShort": MessageLookupByLibrary.simpleMessage("FAQ"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("File details"),
        "titleFileExtensionChanged":
            MessageLookupByLibrary.simpleMessage("File extension changed"),
        "titleFileExtensionMissing":
            MessageLookupByLibrary.simpleMessage("File extension missing"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Add"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Folder details"),
        "titleFreedomExpresionAccessInfo": MessageLookupByLibrary.simpleMessage(
            "Freedom of expression and access to information"),
        "titleIssueTracker":
            MessageLookupByLibrary.simpleMessage("Issue tracker"),
        "titleJustLegalSociety":
            MessageLookupByLibrary.simpleMessage("Just and legal society"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Lock all repositories"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Logs"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Moving entry"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Network"),
        "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Access files from multiple devices"),
        "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Set permissions to collaborate, broadcast, or simply store"),
        "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "Send and receive files securely"),
        "titleOpennessTransparency":
            MessageLookupByLibrary.simpleMessage("Openness and Transparency"),
        "titleOurMission": MessageLookupByLibrary.simpleMessage("Our mission"),
        "titleOurPrinciples":
            MessageLookupByLibrary.simpleMessage("Our Principles"),
        "titleOurValues": MessageLookupByLibrary.simpleMessage("Our values"),
        "titlePrivacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Remove biometrics"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("My repositories"),
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
        "titleSendFeedback":
            MessageLookupByLibrary.simpleMessage("Send feedback"),
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
        "titleWeAreEq":
            MessageLookupByLibrary.simpleMessage("We are eQualit.ie"),
        "typeFile": MessageLookupByLibrary.simpleMessage("File"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Folder")
      };
}
