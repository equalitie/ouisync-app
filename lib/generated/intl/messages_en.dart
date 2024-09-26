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
      "The permission cannot be higher than the repository current access mode: ${access}";

  static String m1(path) => "File downloaded to ${path}";

  static String m2(name) => "${name} - downloading canceled";

  static String m3(name) => "${name} - download failed";

  static String m4(entry) => "${entry} already exists.";

  static String m5(path) =>
      "The current folder is missing, navigating to its parent: ${path}";

  static String m6(error) => "Error: ${error}";

  static String m7(dokanUrl) => "Dokan is missing.${dokanUrl}";

  static String m8(name) => "Initialization of the repository ${name} failed";

  static String m9(path) => "${path} is not empty";

  static String m10(reason) =>
      "Accessing repositories via File Explorer is not available: ${reason}";

  static String m11(name) =>
      "${name} already exist in this location.\n\nWhat do you want to do?";

  static String m12(name) => "Folder deleted successfully: ${name}";

  static String m13(number) =>
      "Do you want to lock all open repositories?\n\n(${number} open)";

  static String m14(path) => "from ${path}";

  static String m15(name) => "Error creating file ${name}";

  static String m16(name) => "Error opening file ${name}";

  static String m17(path) => "Previewing file ${path} failed";

  static String m18(name) => "We could not delete the repository \"${name}\"";

  static String m19(name) =>
      "We could not find the repository \"${name}\" at the usual location";

  static String m20(access) => "Access mode granted: ${access}";

  static String m21(name) =>
      "This repository already exists in the app under the name \"${name}\".";

  static String m22(name) => "Suggested: ${name}\n(tap here to use this name)";

  static String m23(name) => "Sort by: ${name}";

  static String m24(access) => "Unlocked as a ${access} replica";

  static String m25(name) => "Enter password to unlock \"${name}\"";

  static String m26(name) => "${name} writing canceled";

  static String m27(name) => "${name} - writing failed";

  static String m28(name) => "Failed to import repository ${name}";

  static String m29(name) => "Failed to create repository ${name}";

  static String m30(access) => "${access}";

  static String m31(changes) => "${changes}";

  static String m32(entry) => "${entry}";

  static String m33(error) => "${error}";

  static String m34(name) => "${name}";

  static String m35(number) => "${number}";

  static String m36(path) => "${path}";

  static String m37(status) => "${status}";

  static String m38(name) => "Share repository \"${name}\"";

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
        "actionEject": MessageLookupByLibrary.simpleMessage("Eject"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Exit"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Go to settings"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Hide"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("HIDE"),
        "actionIAgree": MessageLookupByLibrary.simpleMessage("I agree"),
        "actionIDontAgree":
            MessageLookupByLibrary.simpleMessage("I don’t agree"),
        "actionImport": MessageLookupByLibrary.simpleMessage("Import"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("Import repository"),
        "actionInstallDokan":
            MessageLookupByLibrary.simpleMessage("Install Dokan"),
        "actionLocateRepo":
            MessageLookupByLibrary.simpleMessage("Locate repository"),
        "actionLockCapital": MessageLookupByLibrary.simpleMessage("LOCK"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Move"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("File"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("Folder"),
        "actionNewMediaFile": MessageLookupByLibrary.simpleMessage("Media"),
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
        "actionRemoveLocalPassword":
            MessageLookupByLibrary.simpleMessage("Remove local password"),
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
        "actionUpdate": MessageLookupByLibrary.simpleMessage("Update"),
        "actionUpdateDokan":
            MessageLookupByLibrary.simpleMessage("Update Dokan"),
        "actionYes": MessageLookupByLibrary.simpleMessage("Yes"),
        "buttonLocateRepository":
            MessageLookupByLibrary.simpleMessage("Locate"),
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
        "labelConnectionType":
            MessageLookupByLibrary.simpleMessage("Connection type"),
        "labelCopyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Destination"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Downloaded to:"),
        "labelEndpoint": MessageLookupByLibrary.simpleMessage("Endpoint: "),
        "labelExternalIPv4":
            MessageLookupByLibrary.simpleMessage("External IPv4"),
        "labelExternalIPv6":
            MessageLookupByLibrary.simpleMessage("External IPv6"),
        "labelLocalIPv4": MessageLookupByLibrary.simpleMessage("Local IPv4"),
        "labelLocalIPv6": MessageLookupByLibrary.simpleMessage("Local IPv6"),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Location: "),
        "labelLockAllRepos": MessageLookupByLibrary.simpleMessage("Lock all"),
        "labelName": MessageLookupByLibrary.simpleMessage("Name: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("New name: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Password: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Peers"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("QR code"),
        "labelQuicListenerEndpointV4":
            MessageLookupByLibrary.simpleMessage("Listening on QUIC/UDP IPv4"),
        "labelQuicListenerEndpointV6":
            MessageLookupByLibrary.simpleMessage("Listening on QUIC/UDP IPv6"),
        "labelRememberPassword":
            MessageLookupByLibrary.simpleMessage("Remember password"),
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
        "labelTcpListenerEndpointV4":
            MessageLookupByLibrary.simpleMessage("Listening on TCP IPv4"),
        "labelTcpListenerEndpointV6":
            MessageLookupByLibrary.simpleMessage("Listening on TCP IPv6"),
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
        "messageAddRepoDb": MessageLookupByLibrary.simpleMessage(
            "Import repository from file system"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Import a repository using a token link"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Import a repository using a QR code"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "This repository is locked or is a blind replica.\n\nIf you have the password, unlock it and try again."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "This repository is a read-only replica."),
        "messageAuthenticate":
            MessageLookupByLibrary.simpleMessage("Authenticate"),
        "messageAutomaticUnlockRepositoryFailed":
            MessageLookupByLibrary.simpleMessage(
                "We couldn’t unlock the repository"),
        "messageAvailableOnMobile":
            MessageLookupByLibrary.simpleMessage("Available on mobile"),
        "messageAwaitingResult":
            MessageLookupByLibrary.simpleMessage("Awaiting result..."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Shortly the OS will ask you for permission to execute this app in the background.\n\nThis is required in order to keep syncing while the app is not in the foreground"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("Is running"),
        "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Biometric authentication failed"),
        "messageBiometricUnlockRepositoryFailed":
            MessageLookupByLibrary.simpleMessage("Biometric unlocking failed"),
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
        "messageCanadaPrivacyAct":
            MessageLookupByLibrary.simpleMessage("Canada’s Privacy Act"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Changing the extension of a file can make it unusable"),
        "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
            "We may update our Terms from time to time. Thus, you are advised to review this page periodically for any changes"),
        "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
            "This policy is effective as of 2022-03-09"),
        "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
            "We do not knowingly collect personally identifiable information from children. We encourage all children to never submit any personally identifiable information through the Application and/or Services. We encourage parents and legal guardians to monitor their childrens’ Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission. If you have reason to believe that a child has provided personally identifiable information to us through the Application and/or Services, please contact us. You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country (in some countries we may allow your parent or guardian to do so on your behalf)"),
        "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this file?"),
        "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this folder?"),
        "messageConfirmIrreversibleChange":
            MessageLookupByLibrary.simpleMessage(
                "This action is irreversible, would you like to proceed?"),
        "messageConfirmNotEmptyFolderDeletion":
            MessageLookupByLibrary.simpleMessage(
                "This folder is not empty.\n\nDo you still want to delete it? (this will delete all its contents)"),
        "messageConfirmRepositoryDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to delete this repository?"),
        "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
            "If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at"),
        "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
            "The Ouisync app does not use cookies"),
        "messageCopiedToClipboard":
            MessageLookupByLibrary.simpleMessage("Copied to the clipboard."),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Create a new <bold>folder</bold>, or add a <bold>file</bold>, using <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Create a new <bold>repository</bold>, or link to one from a friend using a <bold>repository token</bold>"),
        "messageCreatingToken":
            MessageLookupByLibrary.simpleMessage("Creating the share token…"),
        "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
            "The Ouisync team values user privacy and thus does not collect any user information"),
        "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
            "The Ouisync app is designed to be able to provide file sharing services without a user ID, name, nickname, user account or any other form of user data. We don’t know who uses our app and with whom they sync or share their data"),
        "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
            "Ouisync (and eQualit.ie) does not share any data with any third parties"),
        "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
            "Declaration for Distributed Online Services"),
        "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
            "The Ouisync team cannot delete individual files from repositories, as it is not possible to identify them because they are encrypted. We are able to delete whole repositories if you send us the link to the repository that needs to be deleted"),
        "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
            "The simplest way to delete your data is by deleting files or repositories from your own device. Any file deletion will be propagated to all your peers - ie, if you have Write access to a repository, you can delete any files within it and the same files will be deleted from your peers’ repositories as well as from our Always-On-Peer. If you need to delete only the repositories from our Always-On-Peer (but still keep them in your own repository on your own device), please contact us at the address below"),
        "messageDistributedHashTables":
            MessageLookupByLibrary.simpleMessage("Distributed Hash Tables"),
        "messageDokan": MessageLookupByLibrary.simpleMessage("Dokan"),
        "messageDokanDifferentMayorP1":
            MessageLookupByLibrary.simpleMessage("The installed"),
        "messageDokanDifferentMayorP2": MessageLookupByLibrary.simpleMessage(
            "is out of date. Please update it to the latest version."),
        "messageDokanInstallationFailed": MessageLookupByLibrary.simpleMessage(
            "The Dokan installation failed."),
        "messageDokanOlderVersionP2": MessageLookupByLibrary.simpleMessage(
            "is out of date.\n\nPlease uninstall the existing version of Dokan, reboot the system and run Ouisync again."),
        "messageDownloadFileCanceled":
            MessageLookupByLibrary.simpleMessage("File download canceled"),
        "messageDownloadFileLocation": m1,
        "messageDownloadingFileCanceled": m2,
        "messageDownloadingFileError": m3,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "This <bold>folder</bold> is empty"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is empty"),
        "messageEnterDifferentName": MessageLookupByLibrary.simpleMessage(
            "Please enter a different name"),
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
            "is built in line with our values.\n\nBy using it you agree to abide by these principles, and accept our Terms of Use and Privacy Notice."),
        "messageError": MessageLookupByLibrary.simpleMessage("Error!"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "There was an error authenticathing using biometrics. Please try again"),
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
        "messageErrorDetail": m6,
        "messageErrorDokanNotInstalled": m7,
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("entry not found"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage("Please enter a valid name."),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "We couldn’t load this folder’s contents. Please try again."),
        "messageErrorNewPasswordSameOldPassword":
            MessageLookupByLibrary.simpleMessage(
                "The new password is the same as the old password"),
        "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
            "Error opening the repository"),
        "messageErrorOpeningRepoDescription": m8,
        "messageErrorPathNotEmpty": m9,
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
        "messageFAQ":
            MessageLookupByLibrary.simpleMessage("Frequently Asked Questions"),
        "messageFailedToMount": m10,
        "messageFile": MessageLookupByLibrary.simpleMessage("file"),
        "messageFileAlreadyExist": m11,
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "File is already being uploaded"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("File name"),
        "messageFilePreviewFailed": MessageLookupByLibrary.simpleMessage(
            "We couldn’t start the file preview"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "File preview is not yet available"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("files"),
        "messageFolderDeleted": m12,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Folder name"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Generate password"),
        "messageGoToMailApp":
            MessageLookupByLibrary.simpleMessage("Go to the mail app"),
        "messageGoToPeers": MessageLookupByLibrary.simpleMessage("Go to Peers"),
        "messageGood": MessageLookupByLibrary.simpleMessage("Good"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("Granted"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "Granting this permission requires navigating to the settings:\n\n Settings > Apps & notifications"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "Allows the app to keep syncing in the background"),
        "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
            "Is a tool that allows peers to find each other on the P2P (Peer to Peer) network without a centralized server"),
        "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
            "The Local Peer Discovery allows your Ouisync apps to share files with your peers without going through internet service providers, where a local WiFi or other network is available.\n\nFor local connectivity this setting needs to be ON"),
        "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
            "This value depends on your router and/or your Internet service provider.\n\nConnectivity with your peers is best achieved when it is Endpoint Independent"),
        "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
            "Is a tool used for exchanging peer list with the peers you are connected to"),
        "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
            "Is a unique ID generated by Ouisync everytime it starts.\n\nYou can use it to confirm your connection with others in the Peer section of the app"),
        "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "When this setting is on, your mobile services provider may charge you for data used when syncing the repositories you share with your peers"),
        "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
            "Is a set of networking protocols that will allow your Ouisync apps to discover and communicate with each other.\n\nFor best connectivity we recommend this setting to be ON"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Initializing…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Tap on the <bold>Unlock</bold> button and input the password to access content in this repository."),
        "messageInstallDokanForOuisyncP1":
            MessageLookupByLibrary.simpleMessage("Ouisync uses"),
        "messageInstallDokanForOuisyncP2": MessageLookupByLibrary.simpleMessage(
            "to access repositories via the File Explorer.\nPlease install Dokan to enhance your Ouisync experience."),
        "messageInternationalBillHumanRights":
            MessageLookupByLibrary.simpleMessage(
                "International Bill of Human Rights"),
        "messageKeepBothFiles":
            MessageLookupByLibrary.simpleMessage("Keep both files"),
        "messageKeepBothFolders":
            MessageLookupByLibrary.simpleMessage("Keep both folders"),
        "messageLaunchAtStartup":
            MessageLookupByLibrary.simpleMessage("Launch at startup"),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Internal crash detected."),
        "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
            "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services"),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Loading…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Local Discovery"),
        "messageLocalDiscoveryNotAvailableOnMobileNetwork":
            MessageLookupByLibrary.simpleMessage(
                "Not available on mobile networks"),
        "messageLockOpenRepos": m13,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "This <bold>repository</bold> is locked."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Locking all open repositories…"),
        "messageLogData1": MessageLookupByLibrary.simpleMessage(
            "Email address - if the user decided to contact us by email"),
        "messageLogData2": MessageLookupByLibrary.simpleMessage(
            "Information the user may provide by email, through help tickets, or through our website, and associated metadata - for the purposes of providing technical support"),
        "messageLogData3": MessageLookupByLibrary.simpleMessage(
            "User’s IP address - for the purposes of providing technical support"),
        "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
            "The Ouisync app creates logfiles on users\' devices. Their purpose is only to log device’s activity to facilitate the debugging process in case the user experiences difficulties in connecting with their peers or otherwise in using the Ouisync app. The logfile remains on a user\'s device unless the user decides to send it to us for support purposes"),
        "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
            "If the user does decide to contact us, the personally indetifiable data we may collect is:"),
        "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
            "None of this data is shared with any third parties"),
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
        "messageMedium": MessageLookupByLibrary.simpleMessage("Medium"),
        "messageMissingBackgroundServicePermission":
            MessageLookupByLibrary.simpleMessage(
                "Ouisync does not have permission to run in the background, opening another application may stop ongoing synchronization"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Mobile"),
        "messageMoveEntryOrigin": m14,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "This function is not available when moving an entry."),
        "messageNATOnWikipedia":
            MessageLookupByLibrary.simpleMessage("NAT on Wikipedia"),
        "messageNATType": MessageLookupByLibrary.simpleMessage("NAT type"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Network is unavailable"),
        "messageNewFileError": m15,
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "New password copied to the clipboard"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("A new version is available."),
        "messageNoAppsForThisAction": MessageLookupByLibrary.simpleMessage(
            "Not apps can perform this action"),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Before adding files, you need to create a repository"),
        "messageNoRepoIsSelected":
            MessageLookupByLibrary.simpleMessage("No repository is selected"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("No repositories found"),
        "messageNone": MessageLookupByLibrary.simpleMessage("None"),
        "messageNote": MessageLookupByLibrary.simpleMessage("Note"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Nothing here yet!"),
        "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Share files to all of your devices or with others and build your own secure cloud!"),
        "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Repositories can be shared as read-write, read-only, or blind (you store files for others, but cannot access them)"),
        "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "All files and folders added to Ouisync are securely encrypted by default, both in transit and at rest."),
        "messageOnlyAvailableFiles":
            MessageLookupByLibrary.simpleMessage("Only available for files"),
        "messageOpenFileError": m16,
        "messageOr": MessageLookupByLibrary.simpleMessage("Or"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("Ouisync"),
        "messagePIPEDA": MessageLookupByLibrary.simpleMessage("PIPEDA"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Password"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Password copied to the clipboard"),
        "messagePasswordStrength":
            MessageLookupByLibrary.simpleMessage("Password strength"),
        "messagePeerAdded": MessageLookupByLibrary.simpleMessage("Peer added"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Peer Exchange"),
        "messagePeerExchangeWikipedia":
            MessageLookupByLibrary.simpleMessage("Peer Exchange on Wikipedia"),
        "messagePeerRemoved":
            MessageLookupByLibrary.simpleMessage("Peer removed"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("This permission is required"),
        "messagePreviewingFileFailed": m17,
        "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
            "This section is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decides to use our Service"),
        "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
            "“Man is born free, and everywhere he is in chains.”"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "This repository is <bold>read-only</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Cannot be modified, just access the contents"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Remember to securely save the password; if you forget it, there is no way to retrieve it."),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage("Remove biometric validation"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Remove biometrics"),
        "messageRemoveBiometricsConfirmationMoreInfo":
            MessageLookupByLibrary.simpleMessage(
                "This will remove the repository password and use the biometric validation for unlocking"),
        "messageRemoveLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Remove this repository local password?\n\nThe repository will unlock automatically, unless a local password is added again"),
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
        "messageReplaceExistingFolder":
            MessageLookupByLibrary.simpleMessage("Replace existing folder"),
        "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Repository authentication failed"),
        "messageRepoDeletionErrorDescription": m18,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "The repository deletion failed"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "The repository is not there anymore"),
        "messageRepoMissingErrorDescription": m19,
        "messageRepositoryAccessMode": m20,
        "messageRepositoryAlreadyExist": m21,
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
        "messageRepositoryNotMounted": MessageLookupByLibrary.simpleMessage(
            "The repository is not mounted "),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Password"),
        "messageRepositorySuggestedName": m22,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Paste the link here"),
        "messageResetLocalSecret":
            MessageLookupByLibrary.simpleMessage("Reset local secret"),
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
        "messageSecurityOptionsNotAvailableBlind":
            MessageLookupByLibrary.simpleMessage(
                "The security options are not available for blind repositories"),
        "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
            "Data that the user uploads into the Ouisync repositories is end-to-end encrypted in transit as well as at rest. This includes metadata such as file names, sizes, folder structure etc. Within Ouisync, data is readable only by the person who uploaded the data and those persons with whom they shared their repositories"),
        "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
            "You can learn more about the encryption techniques used in our documentation"),
        "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
            "The Ouisync app stores users’ data on an \'Always-On Peer\', which is a server located in Canada. All data is stored as encrypted chunks and is not readable by the server or its operators. The purpose of this server is simply to bridge the gaps between peers who are not online at the same time. All data is periodically purged from this server - its purpose is not to provide permanent data storage but simply facilitation of data syncing by peers"),
        "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
            "If you have a reason to believe that your personal data has been illegaly obtained and shared by other Ouisync users, please contact us at the address below"),
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
        "messageSortBy": m23,
        "messageStorage": MessageLookupByLibrary.simpleMessage("Storage"),
        "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
            "Needed for getting access to the files"),
        "messageStrong": MessageLookupByLibrary.simpleMessage("Strong"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Sync while using mobile data"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Syncing is disabled while using mobile data"),
        "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Tap here to read our Terms of Use and Privacy Notice"),
        "messageTapForValues":
            MessageLookupByLibrary.simpleMessage("Tap here to read our values"),
        "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
            "Infringes on personal information protection rights, including the underlying values or the letter of "),
        "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
            "(the Personal Information Protection and Electronic Documents Act)"),
        "messageTerms2": MessageLookupByLibrary.simpleMessage(
            "Constitutes child sexually exploitative material (including material which may not be illegal child sexual abuse material but which nonetheless sexually exploits or promotes the sexual exploitation of minors), unlawful pornography, or are otherwise indecent"),
        "messageTerms3": MessageLookupByLibrary.simpleMessage(
            "Contains or promotes extreme acts of violence or terrorist activity, including terror or violent extremist propaganda"),
        "messageTerms4": MessageLookupByLibrary.simpleMessage(
            "Advocates bigotry, hatred, or the incitement of violence against any person or group of people based on their race, religion, ethnicity, national origin, sex, gender identity, sexual orientation, disability, impairment, or any other characteristic(s) associated with systemic discrimination or marginalization"),
        "messageTerms5": MessageLookupByLibrary.simpleMessage(
            "Files that contain viruses, trojans, worms, logic bombs or other material that is malicious or technologically harmful"),
        "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
            "This Ouisync Terms of Use (the “Agreement”), along with our Privacy Notice (collectively, the “Terms”), govern your use of Ouisync - an online file synchronization protocol and software."),
        "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
            "By installing and running the Ouisync application, you indicate your assent to be bound by and to comply with this Agreement between you and eQualitie inc. (“eQualitie”, “we”, or “us”). Usage of the Ouisync application and the Ouisync network (the Service) is provided by eQualitie at no cost and is intended for use as is"),
        "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
            "The Ouisync application is built in-line with eQualitie’s values. By using this software you agree that you will not use Ouisync to publish, share, or store materials that is contrary to the underlying values nor the letter of the laws of Quebec or Canada or the International Bill of Human Rights, including content that:"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Repository token copied to the clipboard."),
        "messageUnknownFileExtension":
            MessageLookupByLibrary.simpleMessage("Unknown file extension"),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "The password did not unlock the repository"),
        "messageUnlockRepoOk": m24,
        "messageUnlockRepository": m25,
        "messageUnlockUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Unlock using biometrics"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "You have unsaved changes.\n\nWould you like to discard them?"),
        "messageUpdateLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Update this repository localpassword?"),
        "messageUpdateLocalSecretFailed": MessageLookupByLibrary.simpleMessage(
            "Updating security properties of the repository failed."),
        "messageUpdateLocalSecretOk": MessageLookupByLibrary.simpleMessage(
            "Security properties of the repository have been updated."),
        "messageUseCacheServers":
            MessageLookupByLibrary.simpleMessage("Use cache servers"),
        "messageUseLocalPassword":
            MessageLookupByLibrary.simpleMessage("Use local password"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
        "messageValidateLocalPassword":
            MessageLookupByLibrary.simpleMessage("Validate local password"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Log verbosity"),
        "messageView": MessageLookupByLibrary.simpleMessage("View"),
        "messageWeak": MessageLookupByLibrary.simpleMessage("Weak"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Full access. Your peer can read and write"),
        "messageWritingFileCanceled": m26,
        "messageWritingFileError": m27,
        "messsageFailedAddRepository": m28,
        "messsageFailedCreateRepository": m29,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Change password"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Copy password"),
        "replacementAccess": m30,
        "replacementChanges": m31,
        "replacementEntry": m32,
        "replacementError": m33,
        "replacementName": m34,
        "replacementNumber": m35,
        "replacementPath": m36,
        "replacementStatus": m37,
        "repositoryIsAlreadyImported": MessageLookupByLibrary.simpleMessage(
            "Repository is already imported"),
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
        "titleChangesToTerms":
            MessageLookupByLibrary.simpleMessage("Changes to these Terms"),
        "titleChildrensPrivacy":
            MessageLookupByLibrary.simpleMessage("Children’s Privacy"),
        "titleContactUs": MessageLookupByLibrary.simpleMessage("Contact Us"),
        "titleCookies": MessageLookupByLibrary.simpleMessage("Cookies"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Create a folder"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Create a new repository"),
        "titleDataCollection":
            MessageLookupByLibrary.simpleMessage("3.1 Data Collection"),
        "titleDataSharing":
            MessageLookupByLibrary.simpleMessage("3.2 Data Sharing"),
        "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Delete file"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Delete folder"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Delete non-empty folder"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Delete repository"),
        "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
            "3.4 Deletion of your data from our Always-On-Peer server"),
        "titleDigitalSecurity":
            MessageLookupByLibrary.simpleMessage("Digital Security"),
        "titleDokanInstallation":
            MessageLookupByLibrary.simpleMessage("Dokan installation"),
        "titleDokanInstallationFound":
            MessageLookupByLibrary.simpleMessage("Dokan installation found"),
        "titleDokanMissing":
            MessageLookupByLibrary.simpleMessage("Dokan is missing"),
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
        "titleLinksOtherSites":
            MessageLookupByLibrary.simpleMessage("Links to Other Sites"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Lock all repositories"),
        "titleLogData": MessageLookupByLibrary.simpleMessage("Log Data"),
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
        "titleOverview": MessageLookupByLibrary.simpleMessage("1. Overview"),
        "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
            "The Personal Information Protection and Electronic Documents Act (PIPEDA)"),
        "titlePrivacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "titlePrivacyNotice":
            MessageLookupByLibrary.simpleMessage("3. Privacy Notice"),
        "titlePrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("Privacy Policy"),
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
        "titleSecurityPractices":
            MessageLookupByLibrary.simpleMessage("3.3 Security Practices"),
        "titleSendFeedback":
            MessageLookupByLibrary.simpleMessage("Send feedback"),
        "titleSetPasswordFor":
            MessageLookupByLibrary.simpleMessage("Set password for"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "titleShareRepository": m38,
        "titleSortBy": MessageLookupByLibrary.simpleMessage("Sort by"),
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("State Monitor"),
        "titleTermsOfUse":
            MessageLookupByLibrary.simpleMessage("2. Terms of Use"),
        "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Ouisync Terms of Use & Privacy Notice"),
        "titleUPnP": MessageLookupByLibrary.simpleMessage(
            "Universal Plug and Play (UPnP)"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Unlock repository"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Unsaved changes"),
        "titleUserProvidedPeers":
            MessageLookupByLibrary.simpleMessage("User provided peers"),
        "titleWeAreEq":
            MessageLookupByLibrary.simpleMessage("We are eQualit.ie"),
        "typeFile": MessageLookupByLibrary.simpleMessage("File"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Folder")
      };
}
