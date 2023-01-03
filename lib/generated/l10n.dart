// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About`
  String get titleAbout {
    return Intl.message(
      'About',
      name: 'titleAbout',
      desc: '',
      args: [],
    );
  }

  /// `OuiSync`
  String get titleAppTitle {
    return Intl.message(
      'OuiSync',
      name: 'titleAppTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add file to OuiSync`
  String get titleAddFile {
    return Intl.message(
      'Add file to OuiSync',
      name: 'titleAddFile',
      desc: '',
      args: [],
    );
  }

  /// `Moving entry`
  String get titleMovingEntry {
    return Intl.message(
      'Moving entry',
      name: 'titleMovingEntry',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get titleFolderActions {
    return Intl.message(
      'Create',
      name: 'titleFolderActions',
      desc: '',
      args: [],
    );
  }

  /// `Create a folder`
  String get titleCreateFolder {
    return Intl.message(
      'Create a folder',
      name: 'titleCreateFolder',
      desc: '',
      args: [],
    );
  }

  /// `Create a repository`
  String get titleCreateRepository {
    return Intl.message(
      'Create a repository',
      name: 'titleCreateRepository',
      desc: '',
      args: [],
    );
  }

  /// `Edit repository`
  String get titleEditRepository {
    return Intl.message(
      'Edit repository',
      name: 'titleEditRepository',
      desc: '',
      args: [],
    );
  }

  /// `Unlock repository`
  String get titleUnlockRepository {
    return Intl.message(
      'Unlock repository',
      name: 'titleUnlockRepository',
      desc: '',
      args: [],
    );
  }

  /// `Add a repository`
  String get titleAddRepository {
    return Intl.message(
      'Add a repository',
      name: 'titleAddRepository',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get titleSettings {
    return Intl.message(
      'Settings',
      name: 'titleSettings',
      desc: '',
      args: [],
    );
  }

  /// `Repository`
  String get titleRepository {
    return Intl.message(
      'Repository',
      name: 'titleRepository',
      desc: '',
      args: [],
    );
  }

  /// `File details`
  String get titleFileDetails {
    return Intl.message(
      'File details',
      name: 'titleFileDetails',
      desc: '',
      args: [],
    );
  }

  /// `Folder details`
  String get titleFolderDetails {
    return Intl.message(
      'Folder details',
      name: 'titleFolderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Delete folder`
  String get titleDeleteFolder {
    return Intl.message(
      'Delete folder',
      name: 'titleDeleteFolder',
      desc: '',
      args: [],
    );
  }

  /// `Delete non-empty folder`
  String get titleDeleteNotEmptyFolder {
    return Intl.message(
      'Delete non-empty folder',
      name: 'titleDeleteNotEmptyFolder',
      desc: '',
      args: [],
    );
  }

  /// `Your repositories`
  String get titleRepositoriesList {
    return Intl.message(
      'Your repositories',
      name: 'titleRepositoriesList',
      desc: '',
      args: [],
    );
  }

  /// `Share repository "{name}"`
  String titleShareRepository(Object name) {
    return Intl.message(
      'Share repository "$name"',
      name: 'titleShareRepository',
      desc: '',
      args: [name],
    );
  }

  /// `Delete file`
  String get titleDeleteFile {
    return Intl.message(
      'Delete file',
      name: 'titleDeleteFile',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get titleNetwork {
    return Intl.message(
      'Network',
      name: 'titleNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get titleLogs {
    return Intl.message(
      'Logs',
      name: 'titleLogs',
      desc: '',
      args: [],
    );
  }

  /// `Delete repository`
  String get titleDeleteRepository {
    return Intl.message(
      'Delete repository',
      name: 'titleDeleteRepository',
      desc: '',
      args: [],
    );
  }

  /// `Download to device`
  String get titleDownloadToDevice {
    return Intl.message(
      'Download to device',
      name: 'titleDownloadToDevice',
      desc: '',
      args: [],
    );
  }

  /// `Download location`
  String get titleDownloadLocation {
    return Intl.message(
      'Download location',
      name: 'titleDownloadLocation',
      desc: '',
      args: [],
    );
  }

  /// `Permissions needed`
  String get titleBackgroundAndroidPermissionsTitle {
    return Intl.message(
      'Permissions needed',
      name: 'titleBackgroundAndroidPermissionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Lock all repositories`
  String get titleLockAllRepos {
    return Intl.message(
      'Lock all repositories',
      name: 'titleLockAllRepos',
      desc: '',
      args: [],
    );
  }

  /// `Add a repository with token`
  String get titleAddRepoToken {
    return Intl.message(
      'Add a repository with token',
      name: 'titleAddRepoToken',
      desc: '',
      args: [],
    );
  }

  /// `Scan Repository QR`
  String get titleScanRepoQR {
    return Intl.message(
      'Scan Repository QR',
      name: 'titleScanRepoQR',
      desc: '',
      args: [],
    );
  }

  /// `File extension changed`
  String get titleFileExtensionChanged {
    return Intl.message(
      'File extension changed',
      name: 'titleFileExtensionChanged',
      desc: '',
      args: [],
    );
  }

  /// `File extension missing`
  String get titleFileExtensionMissing {
    return Intl.message(
      'File extension missing',
      name: 'titleFileExtensionMissing',
      desc: '',
      args: [],
    );
  }

  /// `Security`
  String get titleSecurity {
    return Intl.message(
      'Security',
      name: 'titleSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Remove biometrics`
  String get titleRemoveBiometrics {
    return Intl.message(
      'Remove biometrics',
      name: 'titleRemoveBiometrics',
      desc: '',
      args: [],
    );
  }

  /// `State Monitor`
  String get titleStateMonitor {
    return Intl.message(
      'State Monitor',
      name: 'titleStateMonitor',
      desc: '',
      args: [],
    );
  }

  /// `Repository name`
  String get titleRepositoryName {
    return Intl.message(
      'Repository name',
      name: 'titleRepositoryName',
      desc: '',
      args: [],
    );
  }

  /// `Folder`
  String get typeFolder {
    return Intl.message(
      'Folder',
      name: 'typeFolder',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get typeFile {
    return Intl.message(
      'File',
      name: 'typeFile',
      desc: '',
      args: [],
    );
  }

  /// `Repository link: `
  String get labelRepositoryLink {
    return Intl.message(
      'Repository link: ',
      name: 'labelRepositoryLink',
      desc: '',
      args: [],
    );
  }

  /// `Name: `
  String get labelName {
    return Intl.message(
      'Name: ',
      name: 'labelName',
      desc: '',
      args: [],
    );
  }

  /// `New name: `
  String get labelNewName {
    return Intl.message(
      'New name: ',
      name: 'labelNewName',
      desc: '',
      args: [],
    );
  }

  /// `Location: `
  String get labelLocation {
    return Intl.message(
      'Location: ',
      name: 'labelLocation',
      desc: '',
      args: [],
    );
  }

  /// `Size: `
  String get labelSize {
    return Intl.message(
      'Size: ',
      name: 'labelSize',
      desc: '',
      args: [],
    );
  }

  /// `Password: `
  String get labelPassword {
    return Intl.message(
      'Password: ',
      name: 'labelPassword',
      desc: '',
      args: [],
    );
  }

  /// `Retype password: `
  String get labelRetypePassword {
    return Intl.message(
      'Retype password: ',
      name: 'labelRetypePassword',
      desc: '',
      args: [],
    );
  }

  /// `Type password: `
  String get labelTypePassword {
    return Intl.message(
      'Type password: ',
      name: 'labelTypePassword',
      desc: '',
      args: [],
    );
  }

  /// `Sync Status: `
  String get labelSyncStatus {
    return Intl.message(
      'Sync Status: ',
      name: 'labelSyncStatus',
      desc: '',
      args: [],
    );
  }

  /// `BitTorrent DHT`
  String get labelBitTorrentDHT {
    return Intl.message(
      'BitTorrent DHT',
      name: 'labelBitTorrentDHT',
      desc: '',
      args: [],
    );
  }

  /// `Select repository `
  String get labelSelectRepository {
    return Intl.message(
      'Select repository ',
      name: 'labelSelectRepository',
      desc: '',
      args: [],
    );
  }

  /// `Enter the new name: `
  String get labelRenameRepository {
    return Intl.message(
      'Enter the new name: ',
      name: 'labelRenameRepository',
      desc: '',
      args: [],
    );
  }

  /// `Endpoint: `
  String get labelEndpoint {
    return Intl.message(
      'Endpoint: ',
      name: 'labelEndpoint',
      desc: '',
      args: [],
    );
  }

  /// `App version`
  String get labelAppVersion {
    return Intl.message(
      'App version',
      name: 'labelAppVersion',
      desc: '',
      args: [],
    );
  }

  /// `Peers`
  String get labelPeers {
    return Intl.message(
      'Peers',
      name: 'labelPeers',
      desc: '',
      args: [],
    );
  }

  /// `Destination`
  String get labelDestination {
    return Intl.message(
      'Destination',
      name: 'labelDestination',
      desc: '',
      args: [],
    );
  }

  /// `Use external storage`
  String get labelUseExternalStorage {
    return Intl.message(
      'Use external storage',
      name: 'labelUseExternalStorage',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded to:`
  String get labelDownloadedTo {
    return Intl.message(
      'Downloaded to:',
      name: 'labelDownloadedTo',
      desc: '',
      args: [],
    );
  }

  /// `Set permission`
  String get labelSetPermission {
    return Intl.message(
      'Set permission',
      name: 'labelSetPermission',
      desc: '',
      args: [],
    );
  }

  /// `Repository share link`
  String get labelTokenLink {
    return Intl.message(
      'Repository share link',
      name: 'labelTokenLink',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get labelCopyLink {
    return Intl.message(
      'Copy link',
      name: 'labelCopyLink',
      desc: '',
      args: [],
    );
  }

  /// `Share link`
  String get labelShareLink {
    return Intl.message(
      'Share link',
      name: 'labelShareLink',
      desc: '',
      args: [],
    );
  }

  /// `QR code`
  String get labelQRCode {
    return Intl.message(
      'QR code',
      name: 'labelQRCode',
      desc: '',
      args: [],
    );
  }

  /// `Lock all`
  String get labelLockAllRepos {
    return Intl.message(
      'Lock all',
      name: 'labelLockAllRepos',
      desc: '',
      args: [],
    );
  }

  /// `Loading…`
  String get messageLoadingDefault {
    return Intl.message(
      'Loading…',
      name: 'messageLoadingDefault',
      desc: '',
      args: [],
    );
  }

  /// `Internal crash detected.`
  String get messageLibraryPanic {
    return Intl.message(
      'Internal crash detected.',
      name: 'messageLibraryPanic',
      desc: '',
      args: [],
    );
  }

  /// `Syncing is disabled while using mobile internet`
  String get messageSyncingIsDisabledOnMobileInternet {
    return Intl.message(
      'Syncing is disabled while using mobile internet',
      name: 'messageSyncingIsDisabledOnMobileInternet',
      desc: '',
      args: [],
    );
  }

  /// `Network is unavailable`
  String get messageNetworkIsUnavailable {
    return Intl.message(
      'Network is unavailable',
      name: 'messageNetworkIsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `A new version is available.`
  String get messageNewVersionIsAvailable {
    return Intl.message(
      'A new version is available.',
      name: 'messageNewVersionIsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get messageErrorDefault {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'messageErrorDefault',
      desc: '',
      args: [],
    );
  }

  /// `Failed.`
  String get messageErrorDefaultShort {
    return Intl.message(
      'Failed.',
      name: 'messageErrorDefaultShort',
      desc: '',
      args: [],
    );
  }

  /// `We couldn’t load this folder's contents. Please try again.`
  String get messageErrorLoadingContents {
    return Intl.message(
      'We couldn’t load this folder\'s contents. Please try again.',
      name: 'messageErrorLoadingContents',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid name.`
  String get messageErrorFormValidatorNameDefault {
    return Intl.message(
      'Please enter a valid name.',
      name: 'messageErrorFormValidatorNameDefault',
      desc: '',
      args: [],
    );
  }

  /// `{path} is not empty`
  String messageErrorPathNotEmpty(Object path) {
    return Intl.message(
      '$path is not empty',
      name: 'messageErrorPathNotEmpty',
      desc: '',
      args: [path],
    );
  }

  /// `The current folder is missing, navigating to its parent: {path}`
  String messageErrorCurrentPathMissing(Object path) {
    return Intl.message(
      'The current folder is missing, navigating to its parent: $path',
      name: 'messageErrorCurrentPathMissing',
      desc: '',
      args: [path],
    );
  }

  /// `Error creating file {name}`
  String messageNewFileError(Object name) {
    return Intl.message(
      'Error creating file $name',
      name: 'messageNewFileError',
      desc: '',
      args: [name],
    );
  }

  /// `{name} - writing failed`
  String messageWritingFileError(Object name) {
    return Intl.message(
      '$name - writing failed',
      name: 'messageWritingFileError',
      desc: '',
      args: [name],
    );
  }

  /// `{name} - download failed`
  String messageDownloadingFileError(Object name) {
    return Intl.message(
      '$name - download failed',
      name: 'messageDownloadingFileError',
      desc: '',
      args: [name],
    );
  }

  /// `entry not found`
  String get messageErrorEntryNotFound {
    return Intl.message(
      'entry not found',
      name: 'messageErrorEntryNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error creating the repository`
  String get messageErrorCreatingRepository {
    return Intl.message(
      'Error creating the repository',
      name: 'messageErrorCreatingRepository',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create repository {name}`
  String messsageFailedCreateRepository(Object name) {
    return Intl.message(
      'Failed to create repository $name',
      name: 'messsageFailedCreateRepository',
      desc: '',
      args: [name],
    );
  }

  /// `Failed to add repository {name}`
  String messsageFailedAddRepository(Object name) {
    return Intl.message(
      'Failed to add repository $name',
      name: 'messsageFailedAddRepository',
      desc: '',
      args: [name],
    );
  }

  /// `There is already a repository with this name`
  String get messageErrorRepositoryNameExist {
    return Intl.message(
      'There is already a repository with this name',
      name: 'messageErrorRepositoryNameExist',
      desc: '',
      args: [],
    );
  }

  /// `Using \ or / is not allowed`
  String get messageErrorCharactersNotAllowed {
    return Intl.message(
      'Using \\ or / is not allowed',
      name: 'messageErrorCharactersNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Your peer cannot write nor read the contents`
  String get messageBlindReplicaExplanation {
    return Intl.message(
      'Your peer cannot write nor read the contents',
      name: 'messageBlindReplicaExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Cannot be modified, just access the contents`
  String get messageReadReplicaExplanation {
    return Intl.message(
      'Cannot be modified, just access the contents',
      name: 'messageReadReplicaExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Full access. Your peer can read and write`
  String get messageWriteReplicaExplanation {
    return Intl.message(
      'Full access. Your peer can read and write',
      name: 'messageWriteReplicaExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Before adding files, you need to create a repository`
  String get messageNoRepo {
    return Intl.message(
      'Before adding files, you need to create a repository',
      name: 'messageNoRepo',
      desc: '',
      args: [],
    );
  }

  /// `Create a new <bold>repository</bold>, or link to one from a friend using a <bold>repository token</bold>`
  String get messageCreateNewRepo {
    return Intl.message(
      'Create a new <bold>repository</bold>, or link to one from a friend using a <bold>repository token</bold>',
      name: 'messageCreateNewRepo',
      desc: '',
      args: [],
    );
  }

  /// `No repositories found`
  String get messageNoRepos {
    return Intl.message(
      'No repositories found',
      name: 'messageNoRepos',
      desc: '',
      args: [],
    );
  }

  /// `This <bold>repository</bold> is empty`
  String get messageEmptyRepo {
    return Intl.message(
      'This <bold>repository</bold> is empty',
      name: 'messageEmptyRepo',
      desc: '',
      args: [],
    );
  }

  /// `This <bold>folder</bold> is empty`
  String get messageEmptyFolder {
    return Intl.message(
      'This <bold>folder</bold> is empty',
      name: 'messageEmptyFolder',
      desc: '',
      args: [],
    );
  }

  /// `Create a new <bold>folder</bold>, or add a <bold>file</bold>, using <icon></icon>`
  String get messageCreateAddNewItem {
    return Intl.message(
      'Create a new <bold>folder</bold>, or add a <bold>file</bold>, using <icon></icon>',
      name: 'messageCreateAddNewItem',
      desc: '',
      args: [],
    );
  }

  /// `This repository is <bold>read-only</bold>.`
  String get messageReadOnlyContents {
    return Intl.message(
      'This repository is <bold>read-only</bold>.',
      name: 'messageReadOnlyContents',
      desc: '',
      args: [],
    );
  }

  /// `This <bold>repository</bold> is locked.`
  String get messageLockedRepository {
    return Intl.message(
      'This <bold>repository</bold> is locked.',
      name: 'messageLockedRepository',
      desc: '',
      args: [],
    );
  }

  /// `This repository is a blind replica.`
  String get messageBlindRepository {
    return Intl.message(
      'This repository is a blind replica.',
      name: 'messageBlindRepository',
      desc: '',
      args: [],
    );
  }

  /// `The provided <bold>password</bold> does not grant you access to view the content of this repository.`
  String get messageBlindRepositoryContent {
    return Intl.message(
      'The provided <bold>password</bold> does not grant you access to view the content of this repository.',
      name: 'messageBlindRepositoryContent',
      desc: '',
      args: [],
    );
  }

  /// `Tap on the <bold>Unlock</bold> button and input the password to access content in this repository.`
  String get messageInputPasswordToUnlock {
    return Intl.message(
      'Tap on the <bold>Unlock</bold> button and input the password to access content in this repository.',
      name: 'messageInputPasswordToUnlock',
      desc: '',
      args: [],
    );
  }

  /// `Enter password to unlock`
  String get messageUnlockRepository {
    return Intl.message(
      'Enter password to unlock',
      name: 'messageUnlockRepository',
      desc: '',
      args: [],
    );
  }

  /// `Rename repository`
  String get messageRenameRepository {
    return Intl.message(
      'Rename repository',
      name: 'messageRenameRepository',
      desc: '',
      args: [],
    );
  }

  /// `Rename file`
  String get messageRenameFile {
    return Intl.message(
      'Rename file',
      name: 'messageRenameFile',
      desc: '',
      args: [],
    );
  }

  /// `Rename folder`
  String get messageRenameFolder {
    return Intl.message(
      'Rename folder',
      name: 'messageRenameFolder',
      desc: '',
      args: [],
    );
  }

  /// `{name} writing canceled`
  String messageWritingFileCanceled(Object name) {
    return Intl.message(
      '$name writing canceled',
      name: 'messageWritingFileCanceled',
      desc: '',
      args: [name],
    );
  }

  /// `{name} - downloading canceled`
  String messageDownloadingFileCanceled(Object name) {
    return Intl.message(
      '$name - downloading canceled',
      name: 'messageDownloadingFileCanceled',
      desc: '',
      args: [name],
    );
  }

  /// `This repository already exists in the app under the name "{name}".`
  String messageRepositoryAlreadyExist(Object name) {
    return Intl.message(
      'This repository already exists in the app under the name "$name".',
      name: 'messageRepositoryAlreadyExist',
      desc: '',
      args: [name],
    );
  }

  /// `This function is not available when moving an entry.`
  String get messageMovingEntry {
    return Intl.message(
      'This function is not available when moving an entry.',
      name: 'messageMovingEntry',
      desc: '',
      args: [],
    );
  }

  /// `Paste the link here`
  String get messageRepositoryToken {
    return Intl.message(
      'Paste the link here',
      name: 'messageRepositoryToken',
      desc: '',
      args: [],
    );
  }

  /// `Give the repository a name`
  String get messageRepositoryName {
    return Intl.message(
      'Give the repository a name',
      name: 'messageRepositoryName',
      desc: '',
      args: [],
    );
  }

  /// `Repository new name`
  String get messageRepositoryNewName {
    return Intl.message(
      'Repository new name',
      name: 'messageRepositoryNewName',
      desc: '',
      args: [],
    );
  }

  /// `Access mode granted: {access}`
  String messageRepositoryAccessMode(Object access) {
    return Intl.message(
      'Access mode granted: $access',
      name: 'messageRepositoryAccessMode',
      desc: '',
      args: [access],
    );
  }

  /// `Suggested: {name}\n(tap here to use this name)`
  String messageRepositorySuggestedName(Object name) {
    return Intl.message(
      'Suggested: $name\n(tap here to use this name)',
      name: 'messageRepositorySuggestedName',
      desc: '',
      args: [name],
    );
  }

  /// `Repository password`
  String get messageRepositoryPassword {
    return Intl.message(
      'Repository password',
      name: 'messageRepositoryPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a password.`
  String get messageErrorRepositoryPasswordValidation {
    return Intl.message(
      'Please enter a password.',
      name: 'messageErrorRepositoryPasswordValidation',
      desc: '',
      args: [],
    );
  }

  /// `The passwords do not match.`
  String get messageErrorRetypePassword {
    return Intl.message(
      'The passwords do not match.',
      name: 'messageErrorRetypePassword',
      desc: '',
      args: [],
    );
  }

  /// `This token is invalid.`
  String get messageErrorTokenInvalid {
    return Intl.message(
      'This token is invalid.',
      name: 'messageErrorTokenInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid token.`
  String get messageErrorTokenValidator {
    return Intl.message(
      'Please enter a valid token.',
      name: 'messageErrorTokenValidator',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a token.`
  String get messageErrorTokenEmpty {
    return Intl.message(
      'Please enter a token.',
      name: 'messageErrorTokenEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Folder name`
  String get messageFolderName {
    return Intl.message(
      'Folder name',
      name: 'messageFolderName',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this folder?`
  String get messageConfirmFolderDeletion {
    return Intl.message(
      'Are you sure you want to delete this folder?',
      name: 'messageConfirmFolderDeletion',
      desc: '',
      args: [],
    );
  }

  /// `This folder is not empty.\n\nDo you still want to delete it? (this will delete all its contents)`
  String get messageConfirmNotEmptyFolderDeletion {
    return Intl.message(
      'This folder is not empty.\n\nDo you still want to delete it? (this will delete all its contents)',
      name: 'messageConfirmNotEmptyFolderDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Error!`
  String get messageError {
    return Intl.message(
      'Error!',
      name: 'messageError',
      desc: '',
      args: [],
    );
  }

  /// `Ack!`
  String get messageAck {
    return Intl.message(
      'Ack!',
      name: 'messageAck',
      desc: '',
      args: [],
    );
  }

  /// `Creating the share token…`
  String get messageCreatingToken {
    return Intl.message(
      'Creating the share token…',
      name: 'messageCreatingToken',
      desc: '',
      args: [],
    );
  }

  /// `Error creating the share token.`
  String get messageErrorCreatingToken {
    return Intl.message(
      'Error creating the share token.',
      name: 'messageErrorCreatingToken',
      desc: '',
      args: [],
    );
  }

  /// `Repository token copied to the clipboard.`
  String get messageTokenCopiedToClipboard {
    return Intl.message(
      'Repository token copied to the clipboard.',
      name: 'messageTokenCopiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `from {path}`
  String messageMoveEntryOrigin(Object path) {
    return Intl.message(
      'from $path',
      name: 'messageMoveEntryOrigin',
      desc: '',
      args: [path],
    );
  }

  /// `Are you sure you want to delete this file?`
  String get messageConfirmFileDeletion {
    return Intl.message(
      'Are you sure you want to delete this file?',
      name: 'messageConfirmFileDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this repository?`
  String get messageConfirmRepositoryDeletion {
    return Intl.message(
      'Are you sure you want to delete this repository?',
      name: 'messageConfirmRepositoryDeletion',
      desc: '',
      args: [],
    );
  }

  /// `There is no media present.`
  String get mesageNoMediaPresent {
    return Intl.message(
      'There is no media present.',
      name: 'mesageNoMediaPresent',
      desc: '',
      args: [],
    );
  }

  /// `An entry`
  String get messageEntryTypeDefault {
    return Intl.message(
      'An entry',
      name: 'messageEntryTypeDefault',
      desc: '',
      args: [],
    );
  }

  /// `A folder`
  String get messageEntryTypeFolder {
    return Intl.message(
      'A folder',
      name: 'messageEntryTypeFolder',
      desc: '',
      args: [],
    );
  }

  /// `A file`
  String get messageEntryTypeFile {
    return Intl.message(
      'A file',
      name: 'messageEntryTypeFile',
      desc: '',
      args: [],
    );
  }

  /// `{entry} already exists.`
  String messageEntryAlreadyExist(Object entry) {
    return Intl.message(
      '$entry already exists.',
      name: 'messageEntryAlreadyExist',
      desc: '',
      args: [entry],
    );
  }

  /// `Folder deleted successfully: {name}`
  String messageFolderDeleted(Object name) {
    return Intl.message(
      'Folder deleted successfully: $name',
      name: 'messageFolderDeleted',
      desc: '',
      args: [name],
    );
  }

  /// `Press back again to exit.`
  String get messageExitOuiSync {
    return Intl.message(
      'Press back again to exit.',
      name: 'messageExitOuiSync',
      desc: '',
      args: [],
    );
  }

  /// `Initializing…`
  String get messageInitializing {
    return Intl.message(
      'Initializing…',
      name: 'messageInitializing',
      desc: '',
      args: [],
    );
  }

  /// `This repository is locked or is a blind replica.\n\nIf you have the password, unlock it and try again.`
  String get messageAddingFileToLockedRepository {
    return Intl.message(
      'This repository is locked or is a blind replica.\n\nIf you have the password, unlock it and try again.',
      name: 'messageAddingFileToLockedRepository',
      desc: '',
      args: [],
    );
  }

  /// `This repository is a read-only replica.`
  String get messageAddingFileToReadRepository {
    return Intl.message(
      'This repository is a read-only replica.',
      name: 'messageAddingFileToReadRepository',
      desc: '',
      args: [],
    );
  }

  /// `File name`
  String get messageFileName {
    return Intl.message(
      'File name',
      name: 'messageFileName',
      desc: '',
      args: [],
    );
  }

  /// `Select the location`
  String get messageSelectLocation {
    return Intl.message(
      'Select the location',
      name: 'messageSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Save the file to this folder`
  String get messageSaveToLocation {
    return Intl.message(
      'Save the file to this folder',
      name: 'messageSaveToLocation',
      desc: '',
      args: [],
    );
  }

  /// `OuiSync`
  String get messageOuiSyncDesktopTitle {
    return Intl.message(
      'OuiSync',
      name: 'messageOuiSyncDesktopTitle',
      desc: '',
      args: [],
    );
  }

  /// `File preview is not yet available`
  String get messageFilePreviewNotAvailable {
    return Intl.message(
      'File preview is not yet available',
      name: 'messageFilePreviewNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `OuiSync is running`
  String get messageBackgroundNotificationAndroid {
    return Intl.message(
      'OuiSync is running',
      name: 'messageBackgroundNotificationAndroid',
      desc: '',
      args: [],
    );
  }

  /// `Shortly the OS will ask you for permission to execute this app in the background.\n\nThis is required in order to keep syncing while the app is not in the foreground`
  String get messageBackgroundAndroidPermissions {
    return Intl.message(
      'Shortly the OS will ask you for permission to execute this app in the background.\n\nThis is required in order to keep syncing while the app is not in the foreground',
      name: 'messageBackgroundAndroidPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Select a permission to create a share link`
  String get messageSelectAccessMode {
    return Intl.message(
      'Select a permission to create a share link',
      name: 'messageSelectAccessMode',
      desc: '',
      args: [],
    );
  }

  /// `Nothing here yet!`
  String get messageNothingHereYet {
    return Intl.message(
      'Nothing here yet!',
      name: 'messageNothingHereYet',
      desc: '',
      args: [],
    );
  }

  /// `Locking all open repositories…`
  String get messageLockingAllRepos {
    return Intl.message(
      'Locking all open repositories…',
      name: 'messageLockingAllRepos',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to lock all open repositories?\n\n({number} open)`
  String messageLockOpenRepos(Object number) {
    return Intl.message(
      'Do you want to lock all open repositories?\n\n($number open)',
      name: 'messageLockOpenRepos',
      desc: '',
      args: [number],
    );
  }

  /// `Share with QR Code`
  String get messageShareWithWR {
    return Intl.message(
      'Share with QR Code',
      name: 'messageShareWithWR',
      desc: '',
      args: [],
    );
  }

  /// `Scan this with your other device or share it with your peers`
  String get messageScanQROrShare {
    return Intl.message(
      'Scan this with your other device or share it with your peers',
      name: 'messageScanQROrShare',
      desc: '',
      args: [],
    );
  }

  /// `Add a repository using a QR code`
  String get messageAddRepoQR {
    return Intl.message(
      'Add a repository using a QR code',
      name: 'messageAddRepoQR',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get messageOr {
    return Intl.message(
      'Or',
      name: 'messageOr',
      desc: '',
      args: [],
    );
  }

  /// `Add a repository using a token link`
  String get messageAddRepoLink {
    return Intl.message(
      'Add a repository using a token link',
      name: 'messageAddRepoLink',
      desc: '',
      args: [],
    );
  }

  /// `This option is not available on read-only repositories`
  String get messageActionNotAvailable {
    return Intl.message(
      'This option is not available on read-only repositories',
      name: 'messageActionNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `The permission cannot be higger than the repository current access mode: {access}`
  String messageAccessModeDisabled(Object access) {
    return Intl.message(
      'The permission cannot be higger than the repository current access mode: $access',
      name: 'messageAccessModeDisabled',
      desc: '',
      args: [access],
    );
  }

  /// `You need to select one permission to create a repository link first`
  String get messageShareActionDisabled {
    return Intl.message(
      'You need to select one permission to create a repository link first',
      name: 'messageShareActionDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Changing the extension of a file can make it unusable`
  String get messageChangeExtensionAlert {
    return Intl.message(
      'Changing the extension of a file can make it unusable',
      name: 'messageChangeExtensionAlert',
      desc: '',
      args: [],
    );
  }

  /// `file`
  String get messageFile {
    return Intl.message(
      'file',
      name: 'messageFile',
      desc: '',
      args: [],
    );
  }

  /// `files`
  String get messageFiles {
    return Intl.message(
      'files',
      name: 'messageFiles',
      desc: '',
      args: [],
    );
  }

  /// `The repository deletion failed`
  String get messageRepoDeletionFailed {
    return Intl.message(
      'The repository deletion failed',
      name: 'messageRepoDeletionFailed',
      desc: '',
      args: [],
    );
  }

  /// `We could not delete the repository "{name}"`
  String messageRepoDeletionErrorDescription(Object name) {
    return Intl.message(
      'We could not delete the repository "$name"',
      name: 'messageRepoDeletionErrorDescription',
      desc: '',
      args: [name],
    );
  }

  /// `The repository is not there anymore`
  String get messageRepoMissing {
    return Intl.message(
      'The repository is not there anymore',
      name: 'messageRepoMissing',
      desc: '',
      args: [],
    );
  }

  /// `We could not find the repository "{name}" at the usual location`
  String messageRepoMissingErrorDescription(Object name) {
    return Intl.message(
      'We could not find the repository "$name" at the usual location',
      name: 'messageRepoMissingErrorDescription',
      desc: '',
      args: [name],
    );
  }

  /// `Error opening the repository`
  String get messageErrorOpeningRepo {
    return Intl.message(
      'Error opening the repository',
      name: 'messageErrorOpeningRepo',
      desc: '',
      args: [],
    );
  }

  /// `Initialization of the repository {name} failed`
  String messageErrorOpeningRepoDescription(Object name) {
    return Intl.message(
      'Initialization of the repository $name failed',
      name: 'messageErrorOpeningRepoDescription',
      desc: '',
      args: [name],
    );
  }

  /// `File is already being uploaded`
  String get messageFileIsDownloading {
    return Intl.message(
      'File is already being uploaded',
      name: 'messageFileIsDownloading',
      desc: '',
      args: [],
    );
  }

  /// `Log viewer`
  String get messageLogViewer {
    return Intl.message(
      'Log viewer',
      name: 'messageLogViewer',
      desc: '',
      args: [],
    );
  }

  /// `Log verbosity`
  String get messageVerbosity {
    return Intl.message(
      'Log verbosity',
      name: 'messageVerbosity',
      desc: '',
      args: [],
    );
  }

  /// `Only Error`
  String get messageLogLevelError {
    return Intl.message(
      'Only Error',
      name: 'messageLogLevelError',
      desc: '',
      args: [],
    );
  }

  /// `Error and Warn`
  String get messageLogLevelErrorWarn {
    return Intl.message(
      'Error and Warn',
      name: 'messageLogLevelErrorWarn',
      desc: '',
      args: [],
    );
  }

  /// `Error, Warn and Info`
  String get messageLogLevelErrorWarnInfo {
    return Intl.message(
      'Error, Warn and Info',
      name: 'messageLogLevelErrorWarnInfo',
      desc: '',
      args: [],
    );
  }

  /// `Error, Warn, Info and Debug`
  String get messageLogLevelErroWarnInfoDebug {
    return Intl.message(
      'Error, Warn, Info and Debug',
      name: 'messageLogLevelErroWarnInfoDebug',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get messageLogLevelAll {
    return Intl.message(
      'All',
      name: 'messageLogLevelAll',
      desc: '',
      args: [],
    );
  }

  /// `Error: unhandled state`
  String get messageErrorUnhandledState {
    return Intl.message(
      'Error: unhandled state',
      name: 'messageErrorUnhandledState',
      desc: '',
      args: [],
    );
  }

  /// `The password did not unlock the repository`
  String get messageUnlockRepoFailed {
    return Intl.message(
      'The password did not unlock the repository',
      name: 'messageUnlockRepoFailed',
      desc: '',
      args: [],
    );
  }

  /// `Unlocked as a {access} replica`
  String messageUnlockRepoOk(Object access) {
    return Intl.message(
      'Unlocked as a $access replica',
      name: 'messageUnlockRepoOk',
      desc: '',
      args: [access],
    );
  }

  /// `Unlock using biometrics`
  String get messageUnlockUsingBiometrics {
    return Intl.message(
      'Unlock using biometrics',
      name: 'messageUnlockUsingBiometrics',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get messagePassword {
    return Intl.message(
      'Password',
      name: 'messagePassword',
      desc: '',
      args: [],
    );
  }

  /// `Password copied to the clipboard`
  String get messagePasswordCopiedClipboard {
    return Intl.message(
      'Password copied to the clipboard',
      name: 'messagePasswordCopiedClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Remove biometric validation`
  String get messageRemoveBiometricValidation {
    return Intl.message(
      'Remove biometric validation',
      name: 'messageRemoveBiometricValidation',
      desc: '',
      args: [],
    );
  }

  /// `If you remove the biometric validation, once you navigate out of this screen you wont be able to see or copy the password anymore; please save it in a secure place.`
  String get messageAlertSaveCopyPassword {
    return Intl.message(
      'If you remove the biometric validation, once you navigate out of this screen you wont be able to see or copy the password anymore; please save it in a secure place.',
      name: 'messageAlertSaveCopyPassword',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this repository biometrics?`
  String get messageRemoveBiometricsConfirmation {
    return Intl.message(
      'Are you sure you want to remove this repository biometrics?',
      name: 'messageRemoveBiometricsConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Generate password`
  String get messageGeneratePassword {
    return Intl.message(
      'Generate password',
      name: 'messageGeneratePassword',
      desc: '',
      args: [],
    );
  }

  /// `Secure using biometrics`
  String get messageSecureUsingBiometrics {
    return Intl.message(
      'Secure using biometrics',
      name: 'messageSecureUsingBiometrics',
      desc: '',
      args: [],
    );
  }

  /// `Remember to securely save the password; if you forget it, there is no way to retrieve it.`
  String get messageRememberSavePasswordAlert {
    return Intl.message(
      'Remember to securely save the password; if you forget it, there is no way to retrieve it.',
      name: 'messageRememberSavePasswordAlert',
      desc: '',
      args: [],
    );
  }

  /// `Biometric validation added for repository "{name}"`
  String messageBiometricValidationAdded(Object name) {
    return Intl.message(
      'Biometric validation added for repository "$name"',
      name: 'messageBiometricValidationAdded',
      desc: '',
      args: [name],
    );
  }

  /// `Biometric validation removed`
  String get messageBiometricValidationRemoved {
    return Intl.message(
      'Biometric validation removed',
      name: 'messageBiometricValidationRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Runtime ID`
  String get messageSettingsRuntimeID {
    return Intl.message(
      'Runtime ID',
      name: 'messageSettingsRuntimeID',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get messageView {
    return Intl.message(
      'View',
      name: 'messageView',
      desc: '',
      args: [],
    );
  }

  /// `Local Discovery`
  String get messageLocalDiscovery {
    return Intl.message(
      'Local Discovery',
      name: 'messageLocalDiscovery',
      desc: '',
      args: [],
    );
  }

  /// `Sync while using mobile data`
  String get messageSyncMobileData {
    return Intl.message(
      'Sync while using mobile data',
      name: 'messageSyncMobileData',
      desc: '',
      args: [],
    );
  }

  /// `NAT type`
  String get messageNATType {
    return Intl.message(
      'NAT type',
      name: 'messageNATType',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth`
  String get messageBluetooth {
    return Intl.message(
      'Bluetooth',
      name: 'messageBluetooth',
      desc: '',
      args: [],
    );
  }

  /// `Wi-Fi`
  String get messageWiFi {
    return Intl.message(
      'Wi-Fi',
      name: 'messageWiFi',
      desc: '',
      args: [],
    );
  }

  /// `Mobile`
  String get messageMobile {
    return Intl.message(
      'Mobile',
      name: 'messageMobile',
      desc: '',
      args: [],
    );
  }

  /// `Ethernet`
  String get messageEthernet {
    return Intl.message(
      'Ethernet',
      name: 'messageEthernet',
      desc: '',
      args: [],
    );
  }

  /// `VPN`
  String get messageVPN {
    return Intl.message(
      'VPN',
      name: 'messageVPN',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get messageNone {
    return Intl.message(
      'None',
      name: 'messageNone',
      desc: '',
      args: [],
    );
  }

  /// `Peer Exchange`
  String get messagePeerExchange {
    return Intl.message(
      'Peer Exchange',
      name: 'messagePeerExchange',
      desc: '',
      args: [],
    );
  }

  /// `{name}`
  String replacementName(Object name) {
    return Intl.message(
      '$name',
      name: 'replacementName',
      desc: '',
      args: [name],
    );
  }

  /// `{path}`
  String replacementPath(Object path) {
    return Intl.message(
      '$path',
      name: 'replacementPath',
      desc: '',
      args: [path],
    );
  }

  /// `{status}`
  String replacementStatus(Object status) {
    return Intl.message(
      '$status',
      name: 'replacementStatus',
      desc: '',
      args: [status],
    );
  }

  /// `{entry}`
  String replacementEntry(Object entry) {
    return Intl.message(
      '$entry',
      name: 'replacementEntry',
      desc: '',
      args: [entry],
    );
  }

  /// `{access}`
  String replacementAccess(Object access) {
    return Intl.message(
      '$access',
      name: 'replacementAccess',
      desc: '',
      args: [access],
    );
  }

  /// `{number}`
  String replacementNumber(Object number) {
    return Intl.message(
      '$number',
      name: 'replacementNumber',
      desc: '',
      args: [number],
    );
  }

  /// `SYNCED`
  String get statusSync {
    return Intl.message(
      'SYNCED',
      name: 'statusSync',
      desc: '',
      args: [],
    );
  }

  /// `Unspecified`
  String get statusUnspecified {
    return Intl.message(
      'Unspecified',
      name: 'statusUnspecified',
      desc: '',
      args: [],
    );
  }

  /// `Information`
  String get iconInformation {
    return Intl.message(
      'Information',
      name: 'iconInformation',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get iconDownload {
    return Intl.message(
      'Download',
      name: 'iconDownload',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get iconPreview {
    return Intl.message(
      'Preview',
      name: 'iconPreview',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get iconShare {
    return Intl.message(
      'Share',
      name: 'iconShare',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get iconRename {
    return Intl.message(
      'Rename',
      name: 'iconRename',
      desc: '',
      args: [],
    );
  }

  /// `Move`
  String get iconMove {
    return Intl.message(
      'Move',
      name: 'iconMove',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get iconDelete {
    return Intl.message(
      'Delete',
      name: 'iconDelete',
      desc: '',
      args: [],
    );
  }

  /// `Create a repository`
  String get iconCreateRepository {
    return Intl.message(
      'Create a repository',
      name: 'iconCreateRepository',
      desc: '',
      args: [],
    );
  }

  /// `Add an existing repository`
  String get iconAddExistingRepository {
    return Intl.message(
      'Add an existing repository',
      name: 'iconAddExistingRepository',
      desc: '',
      args: [],
    );
  }

  /// `Access Mode`
  String get iconAccessMode {
    return Intl.message(
      'Access Mode',
      name: 'iconAccessMode',
      desc: '',
      args: [],
    );
  }

  /// `Share this with your peer`
  String get iconShareTokenWithPeer {
    return Intl.message(
      'Share this with your peer',
      name: 'iconShareTokenWithPeer',
      desc: '',
      args: [],
    );
  }

  /// `Create a Repository`
  String get actionCreateRepository {
    return Intl.message(
      'Create a Repository',
      name: 'actionCreateRepository',
      desc: '',
      args: [],
    );
  }

  /// `Add Repository`
  String get actionAddRepository {
    return Intl.message(
      'Add Repository',
      name: 'actionAddRepository',
      desc: '',
      args: [],
    );
  }

  /// `Add a Shared Repository`
  String get actionAddRepositoryWithToken {
    return Intl.message(
      'Add a Shared Repository',
      name: 'actionAddRepositoryWithToken',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get actionReloadContents {
    return Intl.message(
      'Reload',
      name: 'actionReloadContents',
      desc: '',
      args: [],
    );
  }

  /// `Create repository`
  String get actionNewRepo {
    return Intl.message(
      'Create repository',
      name: 'actionNewRepo',
      desc: '',
      args: [],
    );
  }

  /// `Reload repository`
  String get actionReloadRepo {
    return Intl.message(
      'Reload repository',
      name: 'actionReloadRepo',
      desc: '',
      args: [],
    );
  }

  /// `Delete repository`
  String get actionDeleteRepo {
    return Intl.message(
      'Delete repository',
      name: 'actionDeleteRepo',
      desc: '',
      args: [],
    );
  }

  /// `Create folder`
  String get actionNewFolder {
    return Intl.message(
      'Create folder',
      name: 'actionNewFolder',
      desc: '',
      args: [],
    );
  }

  /// `Add file`
  String get actionNewFile {
    return Intl.message(
      'Add file',
      name: 'actionNewFile',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get actionCreate {
    return Intl.message(
      'Create',
      name: 'actionCreate',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get actionCancel {
    return Intl.message(
      'Cancel',
      name: 'actionCancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get actionDelete {
    return Intl.message(
      'Delete',
      name: 'actionDelete',
      desc: '',
      args: [],
    );
  }

  /// `Move`
  String get actionMove {
    return Intl.message(
      'Move',
      name: 'actionMove',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get actionSave {
    return Intl.message(
      'Save',
      name: 'actionSave',
      desc: '',
      args: [],
    );
  }

  /// `Unlock`
  String get actionUnlock {
    return Intl.message(
      'Unlock',
      name: 'actionUnlock',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get actionRetry {
    return Intl.message(
      'Retry',
      name: 'actionRetry',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get actionShare {
    return Intl.message(
      'Share',
      name: 'actionShare',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get actionRename {
    return Intl.message(
      'Rename',
      name: 'actionRename',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get actionAccept {
    return Intl.message(
      'Accept',
      name: 'actionAccept',
      desc: '',
      args: [],
    );
  }

  /// `Delete folder`
  String get actionDeleteFolder {
    return Intl.message(
      'Delete folder',
      name: 'actionDeleteFolder',
      desc: '',
      args: [],
    );
  }

  /// `Preview file`
  String get actionPreviewFile {
    return Intl.message(
      'Preview file',
      name: 'actionPreviewFile',
      desc: '',
      args: [],
    );
  }

  /// `Share file`
  String get actionShareFile {
    return Intl.message(
      'Share file',
      name: 'actionShareFile',
      desc: '',
      args: [],
    );
  }

  /// `Delete file`
  String get actionDeleteFile {
    return Intl.message(
      'Delete file',
      name: 'actionDeleteFile',
      desc: '',
      args: [],
    );
  }

  /// `Edit name`
  String get actionEditRepositoryName {
    return Intl.message(
      'Edit name',
      name: 'actionEditRepositoryName',
      desc: '',
      args: [],
    );
  }

  /// `Delete repository`
  String get actionDeleteRepository {
    return Intl.message(
      'Delete repository',
      name: 'actionDeleteRepository',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get actionShow {
    return Intl.message(
      'Show',
      name: 'actionShow',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get actionHide {
    return Intl.message(
      'Hide',
      name: 'actionHide',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get actionExit {
    return Intl.message(
      'Exit',
      name: 'actionExit',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get actionOK {
    return Intl.message(
      'OK',
      name: 'actionOK',
      desc: '',
      args: [],
    );
  }

  /// `Scan a QR code`
  String get actionScanQR {
    return Intl.message(
      'Scan a QR code',
      name: 'actionScanQR',
      desc: '',
      args: [],
    );
  }

  /// `ACCEPT`
  String get actionAcceptCapital {
    return Intl.message(
      'ACCEPT',
      name: 'actionAcceptCapital',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get actionCancelCapital {
    return Intl.message(
      'CANCEL',
      name: 'actionCancelCapital',
      desc: '',
      args: [],
    );
  }

  /// `HIDE`
  String get actionHideCapital {
    return Intl.message(
      'HIDE',
      name: 'actionHideCapital',
      desc: '',
      args: [],
    );
  }

  /// `CLOSE`
  String get actionCloseCapital {
    return Intl.message(
      'CLOSE',
      name: 'actionCloseCapital',
      desc: '',
      args: [],
    );
  }

  /// `DELETE`
  String get actionDeleteCapital {
    return Intl.message(
      'DELETE',
      name: 'actionDeleteCapital',
      desc: '',
      args: [],
    );
  }

  /// `LOCK`
  String get actionLockCapital {
    return Intl.message(
      'LOCK',
      name: 'actionLockCapital',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get actionRemove {
    return Intl.message(
      'Remove',
      name: 'actionRemove',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fa'),
      Locale.fromSubtags(languageCode: 'uk'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
