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

  /// `OuiSync`
  String get appTitle {
    return Intl.message(
      'OuiSync',
      name: 'appTitle',
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

  /// `Delete not empty folder`
  String get titleDeleteNotEmptyFolder {
    return Intl.message(
      'Delete not empty folder',
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

  /// `Token: `
  String get labelRepositoryToken {
    return Intl.message(
      'Token: ',
      name: 'labelRepositoryToken',
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

  /// `select repository`
  String get labelSelectRepository {
    return Intl.message(
      'select repository',
      name: 'labelSelectRepository',
      desc: '',
      args: [],
    );
  }

  /// `Enter the new name`
  String get labelRenameRepository {
    return Intl.message(
      'Enter the new name',
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

  /// `App version: `
  String get labelAppVersion {
    return Intl.message(
      'App version: ',
      name: 'labelAppVersion',
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

  /// `Loading the folder contents…`
  String get messageLoadingContents {
    return Intl.message(
      'Loading the folder contents…',
      name: 'messageLoadingContents',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again`
  String get messageErrorDefault {
    return Intl.message(
      'Something went wrong. Please try again',
      name: 'messageErrorDefault',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get messageErrorDefaultShort {
    return Intl.message(
      'Failed',
      name: 'messageErrorDefaultShort',
      desc: '',
      args: [],
    );
  }

  /// `We couldn’t load this folder contents. Please try again`
  String get messageErrorLoadingContents {
    return Intl.message(
      'We couldn’t load this folder contents. Please try again',
      name: 'messageErrorLoadingContents',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid name (unique, no spaces, …)`
  String get messageErrorFormValidatorNameDefault {
    return Intl.message(
      'Please enter a valid name (unique, no spaces, …)',
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

  /// `The current folder is missing, navigating  to its parent: {path}`
  String messageErrorCurrentPathMissing(Object path) {
    return Intl.message(
      'The current folder is missing, navigating  to its parent: $path',
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

  /// `entry not found`
  String get messageErrorEntryNotFound {
    return Intl.message(
      'entry not found',
      name: 'messageErrorEntryNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Your peer can not write nor read the contents`
  String get messageBlindReplicaExplanation {
    return Intl.message(
      'Your peer can not write nor read the contents',
      name: 'messageBlindReplicaExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Can not be modified, just access the contents`
  String get messageReadReplicaExplanation {
    return Intl.message(
      'Can not be modified, just access the contents',
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

  /// `BitTorrent DHT is {status}`
  String messageBitTorrentDHTStatus(Object status) {
    return Intl.message(
      'BitTorrent DHT is $status',
      name: 'messageBitTorrentDHTStatus',
      desc: '',
      args: [status],
    );
  }

  /// `BitTorrent DHT could not be enabled`
  String get messageBitTorrentDHTEnableFailed {
    return Intl.message(
      'BitTorrent DHT could not be enabled',
      name: 'messageBitTorrentDHTEnableFailed',
      desc: '',
      args: [],
    );
  }

  /// `Disabling BitTorrent DHT failed`
  String get messageBitTorrentDHTDisableFailed {
    return Intl.message(
      'Disabling BitTorrent DHT failed',
      name: 'messageBitTorrentDHTDisableFailed',
      desc: '',
      args: [],
    );
  }

  /// `Before adding a <bold>file</bold>, you need to create a <bold>repository</bold>`
  String get messageNoRepo {
    return Intl.message(
      'Before adding a <bold>file</bold>, you need to create a <bold>repository</bold>',
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

  /// `This repository is <bold>read-only</bold>`
  String get messageReadOnlyContents {
    return Intl.message(
      'This repository is <bold>read-only</bold>',
      name: 'messageReadOnlyContents',
      desc: '',
      args: [],
    );
  }

  /// `This <bold>repository</bold> is locked`
  String get messageLockedRepository {
    return Intl.message(
      'This <bold>repository</bold> is locked',
      name: 'messageLockedRepository',
      desc: '',
      args: [],
    );
  }

  /// `This repository is a blind replica`
  String get messageBlindRepository {
    return Intl.message(
      'This repository is a blind replica',
      name: 'messageBlindRepository',
      desc: '',
      args: [],
    );
  }

  /// `The provided <bold>password</bold> do not grant you access to its contents`
  String get messageBlindRepositoryContent {
    return Intl.message(
      'The provided <bold>password</bold> do not grant you access to its contents',
      name: 'messageBlindRepositoryContent',
      desc: '',
      args: [],
    );
  }

  /// `Tap on the <bold>Unlock</bold> button and input the password to access its contents`
  String get messageInputPasswordToUnlock {
    return Intl.message(
      'Tap on the <bold>Unlock</bold> button and input the password to access its contents',
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

  /// `{name} - saved successfully`
  String messageWritingFileDone(Object name) {
    return Intl.message(
      '$name - saved successfully',
      name: 'messageWritingFileDone',
      desc: '',
      args: [name],
    );
  }

  /// `This function is not available when moving an entry`
  String get messageMovingEntry {
    return Intl.message(
      'This function is not available when moving an entry',
      name: 'messageMovingEntry',
      desc: '',
      args: [],
    );
  }

  /// `Paste the token here`
  String get messageRepositoryToken {
    return Intl.message(
      'Paste the token here',
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

  /// `Suggested: {name}\n(tap here for using this name)`
  String messageRepositorySuggestedName(Object name) {
    return Intl.message(
      'Suggested: $name\n(tap here for using this name)',
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

  /// `Please enter a password`
  String get messageErrorRepositoryPasswordValidation {
    return Intl.message(
      'Please enter a password',
      name: 'messageErrorRepositoryPasswordValidation',
      desc: '',
      args: [],
    );
  }

  /// `The password and retyped password do not match`
  String get messageErrorRetypePassword {
    return Intl.message(
      'The password and retyped password do not match',
      name: 'messageErrorRetypePassword',
      desc: '',
      args: [],
    );
  }

  /// `The token seems to be invalid`
  String get messageErrorTokenInvalid {
    return Intl.message(
      'The token seems to be invalid',
      name: 'messageErrorTokenInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid token`
  String get messageErrorTokenValidator {
    return Intl.message(
      'Please enter a valid token',
      name: 'messageErrorTokenValidator',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a token`
  String get messageErrorTokenEmpty {
    return Intl.message(
      'Please enter a token',
      name: 'messageErrorTokenEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Folder name`
  String get messageCreateFolder {
    return Intl.message(
      'Folder name',
      name: 'messageCreateFolder',
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

  /// `Creating the share token...`
  String get messageCreatingToken {
    return Intl.message(
      'Creating the share token...',
      name: 'messageCreatingToken',
      desc: '',
      args: [],
    );
  }

  /// `Error while creating the share token`
  String get messageErrorCreatingToken {
    return Intl.message(
      'Error while creating the share token',
      name: 'messageErrorCreatingToken',
      desc: '',
      args: [],
    );
  }

  /// `Repository token copied to the clipboard`
  String get messageTokenCopiedToClipboard {
    return Intl.message(
      'Repository token copied to the clipboard',
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

  /// `There is no media present`
  String get mesageNoMediaPresent {
    return Intl.message(
      'There is no media present',
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

  /// `{entry} with the same name already exist in this location`
  String messageEntryAlreadyExist(Object entry) {
    return Intl.message(
      '$entry with the same name already exist in this location',
      name: 'messageEntryAlreadyExist',
      desc: '',
      args: [entry],
    );
  }

  /// `File deleted successfully: {name}`
  String messageFileDeleted(Object name) {
    return Intl.message(
      'File deleted successfully: $name',
      name: 'messageFileDeleted',
      desc: '',
      args: [name],
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

  /// `Press back again to exit`
  String get messageExitOuiSync {
    return Intl.message(
      'Press back again to exit',
      name: 'messageExitOuiSync',
      desc: '',
      args: [],
    );
  }

  /// `Initializing...`
  String get messageInitializing {
    return Intl.message(
      'Initializing...',
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

  /// `Create a new repository`
  String get iconCreateRepository {
    return Intl.message(
      'Create a new repository',
      name: 'iconCreateRepository',
      desc: '',
      args: [],
    );
  }

  /// `Add a repository with token`
  String get iconAddRepositoryWithToken {
    return Intl.message(
      'Add a repository with token',
      name: 'iconAddRepositoryWithToken',
      desc: '',
      args: [],
    );
  }

  /// `Access mode`
  String get iconAccessMode {
    return Intl.message(
      'Access mode',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
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
