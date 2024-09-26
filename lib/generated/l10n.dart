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

  /// `Ouisync`
  String get titleAppTitle {
    return Intl.message(
      'Ouisync',
      name: 'titleAppTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add file to Ouisync`
  String get titleAddFile {
    return Intl.message(
      'Add file to Ouisync',
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

  /// `Add`
  String get titleFolderActions {
    return Intl.message(
      'Add',
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

  /// `Create a new repository`
  String get titleCreateRepository {
    return Intl.message(
      'Create a new repository',
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

  /// `Import a repository`
  String get titleAddRepository {
    return Intl.message(
      'Import a repository',
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

  /// `My repositories`
  String get titleRepositoriesList {
    return Intl.message(
      'My repositories',
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

  /// `Import a repository with token`
  String get titleAddRepoToken {
    return Intl.message(
      'Import a repository with token',
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

  /// `Unsaved changes`
  String get titleUnsavedChanges {
    return Intl.message(
      'Unsaved changes',
      name: 'titleUnsavedChanges',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get titleChangePassword {
    return Intl.message(
      'Change password',
      name: 'titleChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Set password for`
  String get titleSetPasswordFor {
    return Intl.message(
      'Set password for',
      name: 'titleSetPasswordFor',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get titleSaveChanges {
    return Intl.message(
      'Save changes',
      name: 'titleSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Required permission`
  String get titleRequiredPermission {
    return Intl.message(
      'Required permission',
      name: 'titleRequiredPermission',
      desc: '',
      args: [],
    );
  }

  /// `FAQ`
  String get titleFAQShort {
    return Intl.message(
      'FAQ',
      name: 'titleFAQShort',
      desc: '',
      args: [],
    );
  }

  /// `Send feedback`
  String get titleSendFeedback {
    return Intl.message(
      'Send feedback',
      name: 'titleSendFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Issue tracker`
  String get titleIssueTracker {
    return Intl.message(
      'Issue tracker',
      name: 'titleIssueTracker',
      desc: 'link to github issue tracker in setting/about',
      args: [],
    );
  }

  /// `Our values`
  String get titleOurValues {
    return Intl.message(
      'Our values',
      name: 'titleOurValues',
      desc: '',
      args: [],
    );
  }

  /// `Send and receive files securely`
  String get titleOnboardingShare {
    return Intl.message(
      'Send and receive files securely',
      name: 'titleOnboardingShare',
      desc: '',
      args: [],
    );
  }

  /// `Set permissions to collaborate, broadcast, or simply store`
  String get titleOnboardingPermissions {
    return Intl.message(
      'Set permissions to collaborate, broadcast, or simply store',
      name: 'titleOnboardingPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Access files from multiple devices`
  String get titleOnboardingAccess {
    return Intl.message(
      'Access files from multiple devices',
      name: 'titleOnboardingAccess',
      desc: '',
      args: [],
    );
  }

  /// `eQualitie’s Values`
  String get titleEqualitiesValues {
    return Intl.message(
      'eQualitie’s Values',
      name: 'titleEqualitiesValues',
      desc: '',
      args: [],
    );
  }

  /// `Our mission`
  String get titleOurMission {
    return Intl.message(
      'Our mission',
      name: 'titleOurMission',
      desc: '',
      args: [],
    );
  }

  /// `We are eQualit.ie`
  String get titleWeAreEq {
    return Intl.message(
      'We are eQualit.ie',
      name: 'titleWeAreEq',
      desc: '',
      args: [],
    );
  }

  /// `Our Principles`
  String get titleOurPrinciples {
    return Intl.message(
      'Our Principles',
      name: 'titleOurPrinciples',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get titlePrivacy {
    return Intl.message(
      'Privacy',
      name: 'titlePrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get titlePrivacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'titlePrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Digital Security`
  String get titleDigitalSecurity {
    return Intl.message(
      'Digital Security',
      name: 'titleDigitalSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Openness and Transparency`
  String get titleOpennessTransparency {
    return Intl.message(
      'Openness and Transparency',
      name: 'titleOpennessTransparency',
      desc: '',
      args: [],
    );
  }

  /// `Freedom of expression and access to information`
  String get titleFreedomExpresionAccessInfo {
    return Intl.message(
      'Freedom of expression and access to information',
      name: 'titleFreedomExpresionAccessInfo',
      desc: '',
      args: [],
    );
  }

  /// `Just and legal society`
  String get titleJustLegalSociety {
    return Intl.message(
      'Just and legal society',
      name: 'titleJustLegalSociety',
      desc: '',
      args: [],
    );
  }

  /// `Ouisync Terms of Use & Privacy Notice`
  String get titleTermsPrivacy {
    return Intl.message(
      'Ouisync Terms of Use & Privacy Notice',
      name: 'titleTermsPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `1. Overview`
  String get titleOverview {
    return Intl.message(
      '1. Overview',
      name: 'titleOverview',
      desc: '',
      args: [],
    );
  }

  /// `2. Terms of Use`
  String get titleTermsOfUse {
    return Intl.message(
      '2. Terms of Use',
      name: 'titleTermsOfUse',
      desc: '',
      args: [],
    );
  }

  /// `3. Privacy Notice`
  String get titlePrivacyNotice {
    return Intl.message(
      '3. Privacy Notice',
      name: 'titlePrivacyNotice',
      desc: '',
      args: [],
    );
  }

  /// `3.1 Data Collection`
  String get titleDataCollection {
    return Intl.message(
      '3.1 Data Collection',
      name: 'titleDataCollection',
      desc: '',
      args: [],
    );
  }

  /// `3.2 Data Sharing`
  String get titleDataSharing {
    return Intl.message(
      '3.2 Data Sharing',
      name: 'titleDataSharing',
      desc: '',
      args: [],
    );
  }

  /// `3.3 Security Practices`
  String get titleSecurityPractices {
    return Intl.message(
      '3.3 Security Practices',
      name: 'titleSecurityPractices',
      desc: '',
      args: [],
    );
  }

  /// `3.4 Deletion of your data from our Always-On-Peer server`
  String get titleDeletionDataServer {
    return Intl.message(
      '3.4 Deletion of your data from our Always-On-Peer server',
      name: 'titleDeletionDataServer',
      desc: '',
      args: [],
    );
  }

  /// `Log Data`
  String get titleLogData {
    return Intl.message(
      'Log Data',
      name: 'titleLogData',
      desc: '',
      args: [],
    );
  }

  /// `Cookies`
  String get titleCookies {
    return Intl.message(
      'Cookies',
      name: 'titleCookies',
      desc: '',
      args: [],
    );
  }

  /// `Links to Other Sites`
  String get titleLinksOtherSites {
    return Intl.message(
      'Links to Other Sites',
      name: 'titleLinksOtherSites',
      desc: '',
      args: [],
    );
  }

  /// `Children’s Privacy`
  String get titleChildrensPrivacy {
    return Intl.message(
      'Children’s Privacy',
      name: 'titleChildrensPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Changes to these Terms`
  String get titleChangesToTerms {
    return Intl.message(
      'Changes to these Terms',
      name: 'titleChangesToTerms',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get titleContactUs {
    return Intl.message(
      'Contact Us',
      name: 'titleContactUs',
      desc: '',
      args: [],
    );
  }

  /// `The Personal Information Protection and Electronic Documents Act (PIPEDA)`
  String get titlePIPEDA {
    return Intl.message(
      'The Personal Information Protection and Electronic Documents Act (PIPEDA)',
      name: 'titlePIPEDA',
      desc: '',
      args: [],
    );
  }

  /// `Universal Plug and Play (UPnP)`
  String get titleUPnP {
    return Intl.message(
      'Universal Plug and Play (UPnP)',
      name: 'titleUPnP',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get titleSortBy {
    return Intl.message(
      'Sort by',
      name: 'titleSortBy',
      desc: '',
      args: [],
    );
  }

  /// `User provided peers`
  String get titleUserProvidedPeers {
    return Intl.message(
      'User provided peers',
      name: 'titleUserProvidedPeers',
      desc: '',
      args: [],
    );
  }

  /// `Dokan installation`
  String get titleDokanInstallation {
    return Intl.message(
      'Dokan installation',
      name: 'titleDokanInstallation',
      desc: '',
      args: [],
    );
  }

  /// `Dokan is missing`
  String get titleDokanMissing {
    return Intl.message(
      'Dokan is missing',
      name: 'titleDokanMissing',
      desc: '',
      args: [],
    );
  }

  /// `Dokan installation found`
  String get titleDokanInstallationFound {
    return Intl.message(
      'Dokan installation found',
      name: 'titleDokanInstallationFound',
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

  /// `Current password`
  String get labelRepositoryCurrentPassword {
    return Intl.message(
      'Current password',
      name: 'labelRepositoryCurrentPassword',
      desc: '',
      args: [],
    );
  }

  /// `Attach logs`
  String get labelAttachLogs {
    return Intl.message(
      'Attach logs',
      name: 'labelAttachLogs',
      desc: '',
      args: [],
    );
  }

  /// `Connection type`
  String get labelConnectionType {
    return Intl.message(
      'Connection type',
      name: 'labelConnectionType',
      desc: '',
      args: [],
    );
  }

  /// `Listening on TCP IPv4`
  String get labelTcpListenerEndpointV4 {
    return Intl.message(
      'Listening on TCP IPv4',
      name: 'labelTcpListenerEndpointV4',
      desc: '',
      args: [],
    );
  }

  /// `Listening on TCP IPv6`
  String get labelTcpListenerEndpointV6 {
    return Intl.message(
      'Listening on TCP IPv6',
      name: 'labelTcpListenerEndpointV6',
      desc: '',
      args: [],
    );
  }

  /// `Listening on QUIC/UDP IPv4`
  String get labelQuicListenerEndpointV4 {
    return Intl.message(
      'Listening on QUIC/UDP IPv4',
      name: 'labelQuicListenerEndpointV4',
      desc: '',
      args: [],
    );
  }

  /// `Listening on QUIC/UDP IPv6`
  String get labelQuicListenerEndpointV6 {
    return Intl.message(
      'Listening on QUIC/UDP IPv6',
      name: 'labelQuicListenerEndpointV6',
      desc: '',
      args: [],
    );
  }

  /// `External IPv4`
  String get labelExternalIPv4 {
    return Intl.message(
      'External IPv4',
      name: 'labelExternalIPv4',
      desc: '',
      args: [],
    );
  }

  /// `External IPv6`
  String get labelExternalIPv6 {
    return Intl.message(
      'External IPv6',
      name: 'labelExternalIPv6',
      desc: '',
      args: [],
    );
  }

  /// `Local IPv4`
  String get labelLocalIPv4 {
    return Intl.message(
      'Local IPv4',
      name: 'labelLocalIPv4',
      desc: '',
      args: [],
    );
  }

  /// `Local IPv6`
  String get labelLocalIPv6 {
    return Intl.message(
      'Local IPv6',
      name: 'labelLocalIPv6',
      desc: '',
      args: [],
    );
  }

  /// `Remember password`
  String get labelRememberPassword {
    return Intl.message(
      'Remember password',
      name: 'labelRememberPassword',
      desc: '',
      args: [],
    );
  }

  /// `Repository is already imported`
  String get repositoryIsAlreadyImported {
    return Intl.message(
      'Repository is already imported',
      name: 'repositoryIsAlreadyImported',
      desc: '',
      args: [],
    );
  }

  /// `No repository is selected`
  String get messageNoRepoIsSelected {
    return Intl.message(
      'No repository is selected',
      name: 'messageNoRepoIsSelected',
      desc: '',
      args: [],
    );
  }

  /// `The repository is not open`
  String get messageRepositoryIsNotOpen {
    return Intl.message(
      'The repository is not open',
      name: 'messageRepositoryIsNotOpen',
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

  /// `Ouisync does not have permission to run in the background, opening another application may stop ongoing synchronization`
  String get messageMissingBackgroundServicePermission {
    return Intl.message(
      'Ouisync does not have permission to run in the background, opening another application may stop ongoing synchronization',
      name: 'messageMissingBackgroundServicePermission',
      desc: '',
      args: [],
    );
  }

  /// `Syncing is disabled while using mobile data`
  String get messageSyncingIsDisabledOnMobileInternet {
    return Intl.message(
      'Syncing is disabled while using mobile data',
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

  /// `We couldn’t load this folder’s contents. Please try again.`
  String get messageErrorLoadingContents {
    return Intl.message(
      'We couldn’t load this folder’s contents. Please try again.',
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

  /// `Error opening file {name}`
  String messageOpenFileError(Object name) {
    return Intl.message(
      'Error opening file $name',
      name: 'messageOpenFileError',
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

  /// `Failed to import repository {name}`
  String messsageFailedAddRepository(Object name) {
    return Intl.message(
      'Failed to import repository $name',
      name: 'messsageFailedAddRepository',
      desc: '',
      args: [name],
    );
  }

  /// `Repository authentication failed`
  String get messageRepoAuthFailed {
    return Intl.message(
      'Repository authentication failed',
      name: 'messageRepoAuthFailed',
      desc: '',
      args: [],
    );
  }

  /// `Biometric authentication failed`
  String get messageBioAuthFailed {
    return Intl.message(
      'Biometric authentication failed',
      name: 'messageBioAuthFailed',
      desc: '',
      args: [],
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

  /// `Enter password to unlock "{name}"`
  String messageUnlockRepository(Object name) {
    return Intl.message(
      'Enter password to unlock "$name"',
      name: 'messageUnlockRepository',
      desc: '',
      args: [name],
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

  /// `Password`
  String get messageRepositoryPassword {
    return Intl.message(
      'Password',
      name: 'messageRepositoryPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get messageRepositoryNewPassword {
    return Intl.message(
      'New password',
      name: 'messageRepositoryNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password strength`
  String get messagePasswordStrength {
    return Intl.message(
      'Password strength',
      name: 'messagePasswordStrength',
      desc: '',
      args: [],
    );
  }

  /// `Weak`
  String get messageWeak {
    return Intl.message(
      'Weak',
      name: 'messageWeak',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get messageMedium {
    return Intl.message(
      'Medium',
      name: 'messageMedium',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get messageGood {
    return Intl.message(
      'Good',
      name: 'messageGood',
      desc: '',
      args: [],
    );
  }

  /// `Strong`
  String get messageStrong {
    return Intl.message(
      'Strong',
      name: 'messageStrong',
      desc: '',
      args: [],
    );
  }

  /// `The current password`
  String get messageRepositoryCurrentPassword {
    return Intl.message(
      'The current password',
      name: 'messageRepositoryCurrentPassword',
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

  /// `The new password is the same as the old password`
  String get messageErrorNewPasswordSameOldPassword {
    return Intl.message(
      'The new password is the same as the old password',
      name: 'messageErrorNewPasswordSameOldPassword',
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

  /// `Ouisync`
  String get messageOuiSyncDesktopTitle {
    return Intl.message(
      'Ouisync',
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

  /// `Is running`
  String get messageBackgroundNotificationAndroid {
    return Intl.message(
      'Is running',
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

  /// `Import a repository using a QR code`
  String get messageAddRepoQR {
    return Intl.message(
      'Import a repository using a QR code',
      name: 'messageAddRepoQR',
      desc: '',
      args: [],
    );
  }

  /// `Locate`
  String get buttonLocateRepository {
    return Intl.message(
      'Locate',
      name: 'buttonLocateRepository',
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

  /// `Import a repository using a token link`
  String get messageAddRepoLink {
    return Intl.message(
      'Import a repository using a token link',
      name: 'messageAddRepoLink',
      desc: '',
      args: [],
    );
  }

  /// `Import repository from file system`
  String get messageAddRepoDb {
    return Intl.message(
      'Import repository from file system',
      name: 'messageAddRepoDb',
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

  /// `The permission cannot be higher than the repository current access mode: {access}`
  String messageAccessModeDisabled(Object access) {
    return Intl.message(
      'The permission cannot be higher than the repository current access mode: $access',
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

  /// `Save log file`
  String get messageSaveLogFile {
    return Intl.message(
      'Save log file',
      name: 'messageSaveLogFile',
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

  /// `New password copied to the clipboard`
  String get messageNewPasswordCopiedClipboard {
    return Intl.message(
      'New password copied to the clipboard',
      name: 'messageNewPasswordCopiedClipboard',
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

  /// `Remove biometrics`
  String get messageRemoveBiometrics {
    return Intl.message(
      'Remove biometrics',
      name: 'messageRemoveBiometrics',
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

  /// `The security options are not available for blind repositories`
  String get messageSecurityOptionsNotAvailableBlind {
    return Intl.message(
      'The security options are not available for blind repositories',
      name: 'messageSecurityOptionsNotAvailableBlind',
      desc: '',
      args: [],
    );
  }

  /// `There was an error authenticathing using biometrics. Please try again`
  String get messageErrorAuthenticatingBiometrics {
    return Intl.message(
      'There was an error authenticathing using biometrics. Please try again',
      name: 'messageErrorAuthenticatingBiometrics',
      desc: '',
      args: [],
    );
  }

  /// `There was a problem changing the password. Please try again`
  String get messageErrorChangingPassword {
    return Intl.message(
      'There was a problem changing the password. Please try again',
      name: 'messageErrorChangingPassword',
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

  /// `You have unsaved changes.\n\nWould you like to discard them?`
  String get messageUnsavedChanges {
    return Intl.message(
      'You have unsaved changes.\n\nWould you like to discard them?',
      name: 'messageUnsavedChanges',
      desc: '',
      args: [],
    );
  }

  /// `Accessing secure storage`
  String get messageAccessingSecureStorage {
    return Intl.message(
      'Accessing secure storage',
      name: 'messageAccessingSecureStorage',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to save the current changes?`
  String get messageSavingChanges {
    return Intl.message(
      'Do you want to save the current changes?',
      name: 'messageSavingChanges',
      desc: '',
      args: [],
    );
  }

  /// `Updating security properties of the repository failed.`
  String get messageUpdateLocalSecretFailed {
    return Intl.message(
      'Updating security properties of the repository failed.',
      name: 'messageUpdateLocalSecretFailed',
      desc: '',
      args: [],
    );
  }

  /// `Security properties of the repository have been updated.`
  String get messageUpdateLocalSecretOk {
    return Intl.message(
      'Security properties of the repository have been updated.',
      name: 'messageUpdateLocalSecretOk',
      desc: '',
      args: [],
    );
  }

  /// `Use local password`
  String get messageUseLocalPassword {
    return Intl.message(
      'Use local password',
      name: 'messageUseLocalPassword',
      desc: '',
      args: [],
    );
  }

  /// `Validate local password`
  String get messageValidateLocalPassword {
    return Intl.message(
      'Validate local password',
      name: 'messageValidateLocalPassword',
      desc: '',
      args: [],
    );
  }

  /// `<removed>`
  String get messageRemovedInBrackets {
    return Intl.message(
      '<removed>',
      name: 'messageRemovedInBrackets',
      desc: '',
      args: [],
    );
  }

  /// `Granted`
  String get messageGranted {
    return Intl.message(
      'Granted',
      name: 'messageGranted',
      desc: '',
      args: [],
    );
  }

  /// `This permission is required`
  String get messagePermissionRequired {
    return Intl.message(
      'This permission is required',
      name: 'messagePermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Granting this permission requires navigating to the settings:\n\n Settings > Apps & notifications`
  String get messageGrantingRequiresSettings {
    return Intl.message(
      'Granting this permission requires navigating to the settings:\n\n Settings > Apps & notifications',
      name: 'messageGrantingRequiresSettings',
      desc: '',
      args: [],
    );
  }

  /// `We need this permission to use the camera and read the QR code`
  String get messageCameraPermission {
    return Intl.message(
      'We need this permission to use the camera and read the QR code',
      name: 'messageCameraPermission',
      desc: '',
      args: [],
    );
  }

  /// `Allows the app to keep syncing in the background`
  String get messageIgnoreBatteryOptimizationsPermission {
    return Intl.message(
      'Allows the app to keep syncing in the background',
      name: 'messageIgnoreBatteryOptimizationsPermission',
      desc: '',
      args: [],
    );
  }

  /// `Needed for getting access to the files`
  String get messageStoragePermission {
    return Intl.message(
      'Needed for getting access to the files',
      name: 'messageStoragePermission',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get messageStorage {
    return Intl.message(
      'Storage',
      name: 'messageStorage',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get messageCamera {
    return Intl.message(
      'Camera',
      name: 'messageCamera',
      desc: '',
      args: [],
    );
  }

  /// `{name} already exist in this location.\n\nWhat do you want to do?`
  String messageFileAlreadyExist(Object name) {
    return Intl.message(
      '$name already exist in this location.\n\nWhat do you want to do?',
      name: 'messageFileAlreadyExist',
      desc: '',
      args: [name],
    );
  }

  /// `Replace existing file`
  String get messageReplaceExistingFile {
    return Intl.message(
      'Replace existing file',
      name: 'messageReplaceExistingFile',
      desc: '',
      args: [],
    );
  }

  /// `Replace existing folder`
  String get messageReplaceExistingFolder {
    return Intl.message(
      'Replace existing folder',
      name: 'messageReplaceExistingFolder',
      desc: '',
      args: [],
    );
  }

  /// `Keep both files`
  String get messageKeepBothFiles {
    return Intl.message(
      'Keep both files',
      name: 'messageKeepBothFiles',
      desc: '',
      args: [],
    );
  }

  /// `Keep both folders`
  String get messageKeepBothFolders {
    return Intl.message(
      'Keep both folders',
      name: 'messageKeepBothFolders',
      desc: '',
      args: [],
    );
  }

  /// `Only available for files`
  String get messageOnlyAvailableFiles {
    return Intl.message(
      'Only available for files',
      name: 'messageOnlyAvailableFiles',
      desc: '',
      args: [],
    );
  }

  /// `Frequently Asked Questions`
  String get messageFAQ {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'messageFAQ',
      desc: '',
      args: [],
    );
  }

  /// `is built in line with our values.\n\nBy using it you agree to abide by these principles, and accept our Terms of Use and Privacy Notice.`
  String get messageEqualitieValues {
    return Intl.message(
      'is built in line with our values.\n\nBy using it you agree to abide by these principles, and accept our Terms of Use and Privacy Notice.',
      name: 'messageEqualitieValues',
      desc: '',
      args: [],
    );
  }

  /// `All files and folders added to Ouisync are securely encrypted by default, both in transit and at rest.`
  String get messageOnboardingShare {
    return Intl.message(
      'All files and folders added to Ouisync are securely encrypted by default, both in transit and at rest.',
      name: 'messageOnboardingShare',
      desc: '',
      args: [],
    );
  }

  /// `Repositories can be shared as read-write, read-only, or blind (you store files for others, but cannot access them)`
  String get messageOnboardingPermissions {
    return Intl.message(
      'Repositories can be shared as read-write, read-only, or blind (you store files for others, but cannot access them)',
      name: 'messageOnboardingPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Share files to all of your devices or with others and build your own secure cloud!`
  String get messageOnboardingAccess {
    return Intl.message(
      'Share files to all of your devices or with others and build your own secure cloud!',
      name: 'messageOnboardingAccess',
      desc: '',
      args: [],
    );
  }

  /// `by`
  String get messageBy {
    return Intl.message(
      'by',
      name: 'messageBy',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to read our values`
  String get messageTapForValues {
    return Intl.message(
      'Tap here to read our values',
      name: 'messageTapForValues',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to read our Terms of Use and Privacy Notice`
  String get messageTapForTermsPrivacy {
    return Intl.message(
      'Tap here to read our Terms of Use and Privacy Notice',
      name: 'messageTapForTermsPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `“Man is born free, and everywhere he is in chains.”`
  String get messageQuoteMainIsFree {
    return Intl.message(
      '“Man is born free, and everywhere he is in chains.”',
      name: 'messageQuoteMainIsFree',
      desc: '',
      args: [],
    );
  }

  /// `Jean-Jacques Rousseau`
  String get messageRousseau {
    return Intl.message(
      'Jean-Jacques Rousseau',
      name: 'messageRousseau',
      desc: '',
      args: [],
    );
  }

  /// `Basic rights and fundamental freedoms are inherent, inalienable and apply equally to everyone. Human rights are universal; protected in international law and enshrined in the `
  String get messageEqValuesP1 {
    return Intl.message(
      'Basic rights and fundamental freedoms are inherent, inalienable and apply equally to everyone. Human rights are universal; protected in international law and enshrined in the ',
      name: 'messageEqValuesP1',
      desc: '',
      args: [],
    );
  }

  /// `International Bill of Human Rights`
  String get messageInternationalBillHumanRights {
    return Intl.message(
      'International Bill of Human Rights',
      name: 'messageInternationalBillHumanRights',
      desc: '',
      args: [],
    );
  }

  /// `Brave people risk life and liberty to defend human rights, to mobilise, to criticise and to expose the perpetrators of abuse. Brave people voice support for others, for ideas, and communicate their concerns to the world. These brave people exercise their human rights online`
  String get messageEqValuesP2 {
    return Intl.message(
      'Brave people risk life and liberty to defend human rights, to mobilise, to criticise and to expose the perpetrators of abuse. Brave people voice support for others, for ideas, and communicate their concerns to the world. These brave people exercise their human rights online',
      name: 'messageEqValuesP2',
      desc: '',
      args: [],
    );
  }

  /// `The Internet is a platform for free expression and self-determination. Like any communication tool, the Internet is not immune from censorship, surveillance, attacks and attempts by state actors and criminal groups to silence dissident voices. When democratic expression is criminalised, when there is ethnic and political discrimination, the Internet becomes another battleground for non-violent resistance`
  String get messageEqValuesP3 {
    return Intl.message(
      'The Internet is a platform for free expression and self-determination. Like any communication tool, the Internet is not immune from censorship, surveillance, attacks and attempts by state actors and criminal groups to silence dissident voices. When democratic expression is criminalised, when there is ethnic and political discrimination, the Internet becomes another battleground for non-violent resistance',
      name: 'messageEqValuesP3',
      desc: '',
      args: [],
    );
  }

  /// `Our mission is to promote and defend fundamental freedoms and human rights, including the free flow of information online. Our goal is to create accessible technology and improve the skill set needed for defending human rights and freedoms in the digital age`
  String get messageEqValuesP4 {
    return Intl.message(
      'Our mission is to promote and defend fundamental freedoms and human rights, including the free flow of information online. Our goal is to create accessible technology and improve the skill set needed for defending human rights and freedoms in the digital age',
      name: 'messageEqValuesP4',
      desc: '',
      args: [],
    );
  }

  /// `We aim to educate and raise the capacity of our constituents to enjoy secure operations in the digital domain. We do this by building tools that enable and protect free expression, circumvent censorship, empower anonymity and protect from surveillance where and when necessary. Our tools also improve information management and analytic functions`
  String get messageEqValuesP5 {
    return Intl.message(
      'We aim to educate and raise the capacity of our constituents to enjoy secure operations in the digital domain. We do this by building tools that enable and protect free expression, circumvent censorship, empower anonymity and protect from surveillance where and when necessary. Our tools also improve information management and analytic functions',
      name: 'messageEqValuesP5',
      desc: '',
      args: [],
    );
  }

  /// `We are an international group of activists of diverse backgrounds and beliefs, standing together to defend the principles common among us. We are software developers, cryptographers, security specialists, as well as educators, sociologists, historians, anthropologists and journalists. We develop open and reusable tools with a focus on privacy, online security and better information management. We finance our operations with public grants and consultancies with the private sector. We believe in an Internet that is free from intrusive and unjustified surveillance, censorship and oppression`
  String get messageEqValuesP6 {
    return Intl.message(
      'We are an international group of activists of diverse backgrounds and beliefs, standing together to defend the principles common among us. We are software developers, cryptographers, security specialists, as well as educators, sociologists, historians, anthropologists and journalists. We develop open and reusable tools with a focus on privacy, online security and better information management. We finance our operations with public grants and consultancies with the private sector. We believe in an Internet that is free from intrusive and unjustified surveillance, censorship and oppression',
      name: 'messageEqValuesP6',
      desc: '',
      args: [],
    );
  }

  /// `Inspired by the International Bill of Human Rights, our principles apply to every individual, group and organ of society that we work with, including the beneficiaries of the software and services we release. All of our projects are designed with our principles in mind. Our knowledge, tools and services are available to these groups and individuals as long as our principles and terms of service are respected`
  String get messageEqValuesP7 {
    return Intl.message(
      'Inspired by the International Bill of Human Rights, our principles apply to every individual, group and organ of society that we work with, including the beneficiaries of the software and services we release. All of our projects are designed with our principles in mind. Our knowledge, tools and services are available to these groups and individuals as long as our principles and terms of service are respected',
      name: 'messageEqValuesP7',
      desc: '',
      args: [],
    );
  }

  /// `The right to privacy is a fundamental right that we aim to protect whenever and wherever possible. The privacy of our direct beneficiaries is sacrosanct to our operations. Our tools, services and internal policies are designed to this effect. We will use all technical and legal resources at our disposal to protect the privacy of our beneficiaries. Please refer to our Privacy Policy and our `
  String get messageEqValuesP8 {
    return Intl.message(
      'The right to privacy is a fundamental right that we aim to protect whenever and wherever possible. The privacy of our direct beneficiaries is sacrosanct to our operations. Our tools, services and internal policies are designed to this effect. We will use all technical and legal resources at our disposal to protect the privacy of our beneficiaries. Please refer to our Privacy Policy and our ',
      name: 'messageEqValuesP8',
      desc: '',
      args: [],
    );
  }

  /// `Declaration for Distributed Online Services`
  String get messageDeclarationDOS {
    return Intl.message(
      'Declaration for Distributed Online Services',
      name: 'messageDeclarationDOS',
      desc: '',
      args: [],
    );
  }

  /// `Security is a constant thematic throughout all of our software development, service provision and capacity-building projects. We design our systems and processes to improve information security on the Internet and raise the user’s security profile and experience. We try to lead by example by not compromising the security properties of a tool or system for the sake of speed, usability or cost. We do not believe in security through obscurity and we maintain transparency through open access to our code base. We always err on the side of caution and try to implement good internal operational security`
  String get messageEqValuesP9 {
    return Intl.message(
      'Security is a constant thematic throughout all of our software development, service provision and capacity-building projects. We design our systems and processes to improve information security on the Internet and raise the user’s security profile and experience. We try to lead by example by not compromising the security properties of a tool or system for the sake of speed, usability or cost. We do not believe in security through obscurity and we maintain transparency through open access to our code base. We always err on the side of caution and try to implement good internal operational security',
      name: 'messageEqValuesP9',
      desc: '',
      args: [],
    );
  }

  /// `As an organisation, we seek to be transparent with our policies and procedures. As often as possible, our source code is open and freely available, protected by licences that encourage community-driven development, sharing and the propagation of these principles`
  String get messageEqValuesP10 {
    return Intl.message(
      'As an organisation, we seek to be transparent with our policies and procedures. As often as possible, our source code is open and freely available, protected by licences that encourage community-driven development, sharing and the propagation of these principles',
      name: 'messageEqValuesP10',
      desc: '',
      args: [],
    );
  }

  /// `The ability to express oneself freely and to access public information is the backbone of a true democracy. Public information should be in the public domain. Freedom of expression includes active and heated debate, even arguments that are inelegantly articulated, poorly constructed and that may be considered offensive to some. However, freedom of expression is not an absolute right. We stand firmly against violence and the incitement to violate the rights of others, especially the propagation of violence, hate, discrimination and disenfranchisement of any identifiable ethnic or social group`
  String get messageEqValuesP11 {
    return Intl.message(
      'The ability to express oneself freely and to access public information is the backbone of a true democracy. Public information should be in the public domain. Freedom of expression includes active and heated debate, even arguments that are inelegantly articulated, poorly constructed and that may be considered offensive to some. However, freedom of expression is not an absolute right. We stand firmly against violence and the incitement to violate the rights of others, especially the propagation of violence, hate, discrimination and disenfranchisement of any identifiable ethnic or social group',
      name: 'messageEqValuesP11',
      desc: '',
      args: [],
    );
  }

  /// `We operate from different countries and come from various social backgrounds. We work together towards a society that will respect and defend the rights of others in the physical and the digital world. The International Bill of Rights articulates the suite of human rights that inspires our work; we believe that people have a right and a duty to protect these rights`
  String get messageEqValuesP12 {
    return Intl.message(
      'We operate from different countries and come from various social backgrounds. We work together towards a society that will respect and defend the rights of others in the physical and the digital world. The International Bill of Rights articulates the suite of human rights that inspires our work; we believe that people have a right and a duty to protect these rights',
      name: 'messageEqValuesP12',
      desc: '',
      args: [],
    );
  }

  /// `We understand that our tools and services can be abused to contravene these principles and our terms of service, and we firmly and actively condemn and forbid such usage. We neither permit our software and services to be used to further the commission of illicit activities, nor will we assist in the propagation of hate speech or the promotion of violence through the Internet`
  String get messageEqValuesP13 {
    return Intl.message(
      'We understand that our tools and services can be abused to contravene these principles and our terms of service, and we firmly and actively condemn and forbid such usage. We neither permit our software and services to be used to further the commission of illicit activities, nor will we assist in the propagation of hate speech or the promotion of violence through the Internet',
      name: 'messageEqValuesP13',
      desc: '',
      args: [],
    );
  }

  /// `We have put safeguards in place to mitigate the misuse of our products and services. When we become aware of any use that violates our principles or terms of service, we take action to stop it. Guided by our internal policies, we carefully deliberate over acts that might compromise our principles. Our procedures will continue to evolve based on experience and best practices so that we can achieve the right balance between enabling open access to our products and services, and upholding our principles`
  String get messageEqValuesP14 {
    return Intl.message(
      'We have put safeguards in place to mitigate the misuse of our products and services. When we become aware of any use that violates our principles or terms of service, we take action to stop it. Guided by our internal policies, we carefully deliberate over acts that might compromise our principles. Our procedures will continue to evolve based on experience and best practices so that we can achieve the right balance between enabling open access to our products and services, and upholding our principles',
      name: 'messageEqValuesP14',
      desc: '',
      args: [],
    );
  }

  /// `This Ouisync Terms of Use (the “Agreement”), along with our Privacy Notice (collectively, the “Terms”), govern your use of Ouisync - an online file synchronization protocol and software.`
  String get messageTermsPrivacyP1 {
    return Intl.message(
      'This Ouisync Terms of Use (the “Agreement”), along with our Privacy Notice (collectively, the “Terms”), govern your use of Ouisync - an online file synchronization protocol and software.',
      name: 'messageTermsPrivacyP1',
      desc: '',
      args: [],
    );
  }

  /// `By installing and running the Ouisync application, you indicate your assent to be bound by and to comply with this Agreement between you and eQualitie inc. (“eQualitie”, “we”, or “us”). Usage of the Ouisync application and the Ouisync network (the Service) is provided by eQualitie at no cost and is intended for use as is`
  String get messageTermsPrivacyP2 {
    return Intl.message(
      'By installing and running the Ouisync application, you indicate your assent to be bound by and to comply with this Agreement between you and eQualitie inc. (“eQualitie”, “we”, or “us”). Usage of the Ouisync application and the Ouisync network (the Service) is provided by eQualitie at no cost and is intended for use as is',
      name: 'messageTermsPrivacyP2',
      desc: '',
      args: [],
    );
  }

  /// `The Ouisync application is built in-line with eQualitie’s values. By using this software you agree that you will not use Ouisync to publish, share, or store materials that is contrary to the underlying values nor the letter of the laws of Quebec or Canada or the International Bill of Human Rights, including content that:`
  String get messageTermsPrivacyP3 {
    return Intl.message(
      'The Ouisync application is built in-line with eQualitie’s values. By using this software you agree that you will not use Ouisync to publish, share, or store materials that is contrary to the underlying values nor the letter of the laws of Quebec or Canada or the International Bill of Human Rights, including content that:',
      name: 'messageTermsPrivacyP3',
      desc: '',
      args: [],
    );
  }

  /// `Infringes on personal information protection rights, including the underlying values or the letter of `
  String get messageTerms1_1 {
    return Intl.message(
      'Infringes on personal information protection rights, including the underlying values or the letter of ',
      name: 'messageTerms1_1',
      desc: '',
      args: [],
    );
  }

  /// `(the Personal Information Protection and Electronic Documents Act)`
  String get messageTerms1_2 {
    return Intl.message(
      '(the Personal Information Protection and Electronic Documents Act)',
      name: 'messageTerms1_2',
      desc: '',
      args: [],
    );
  }

  /// `Constitutes child sexually exploitative material (including material which may not be illegal child sexual abuse material but which nonetheless sexually exploits or promotes the sexual exploitation of minors), unlawful pornography, or are otherwise indecent`
  String get messageTerms2 {
    return Intl.message(
      'Constitutes child sexually exploitative material (including material which may not be illegal child sexual abuse material but which nonetheless sexually exploits or promotes the sexual exploitation of minors), unlawful pornography, or are otherwise indecent',
      name: 'messageTerms2',
      desc: '',
      args: [],
    );
  }

  /// `Contains or promotes extreme acts of violence or terrorist activity, including terror or violent extremist propaganda`
  String get messageTerms3 {
    return Intl.message(
      'Contains or promotes extreme acts of violence or terrorist activity, including terror or violent extremist propaganda',
      name: 'messageTerms3',
      desc: '',
      args: [],
    );
  }

  /// `Advocates bigotry, hatred, or the incitement of violence against any person or group of people based on their race, religion, ethnicity, national origin, sex, gender identity, sexual orientation, disability, impairment, or any other characteristic(s) associated with systemic discrimination or marginalization`
  String get messageTerms4 {
    return Intl.message(
      'Advocates bigotry, hatred, or the incitement of violence against any person or group of people based on their race, religion, ethnicity, national origin, sex, gender identity, sexual orientation, disability, impairment, or any other characteristic(s) associated with systemic discrimination or marginalization',
      name: 'messageTerms4',
      desc: '',
      args: [],
    );
  }

  /// `Files that contain viruses, trojans, worms, logic bombs or other material that is malicious or technologically harmful`
  String get messageTerms5 {
    return Intl.message(
      'Files that contain viruses, trojans, worms, logic bombs or other material that is malicious or technologically harmful',
      name: 'messageTerms5',
      desc: '',
      args: [],
    );
  }

  /// `This section is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decides to use our Service`
  String get messagePrivacyIntro {
    return Intl.message(
      'This section is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decides to use our Service',
      name: 'messagePrivacyIntro',
      desc: '',
      args: [],
    );
  }

  /// `The Ouisync team values user privacy and thus does not collect any user information`
  String get messageDataCollectionP1 {
    return Intl.message(
      'The Ouisync team values user privacy and thus does not collect any user information',
      name: 'messageDataCollectionP1',
      desc: '',
      args: [],
    );
  }

  /// `The Ouisync app is designed to be able to provide file sharing services without a user ID, name, nickname, user account or any other form of user data. We don’t know who uses our app and with whom they sync or share their data`
  String get messageDataCollectionP2 {
    return Intl.message(
      'The Ouisync app is designed to be able to provide file sharing services without a user ID, name, nickname, user account or any other form of user data. We don’t know who uses our app and with whom they sync or share their data',
      name: 'messageDataCollectionP2',
      desc: '',
      args: [],
    );
  }

  /// `Ouisync (and eQualit.ie) does not share any data with any third parties`
  String get messageDataSharingP1 {
    return Intl.message(
      'Ouisync (and eQualit.ie) does not share any data with any third parties',
      name: 'messageDataSharingP1',
      desc: '',
      args: [],
    );
  }

  /// `Data that the user uploads into the Ouisync repositories is end-to-end encrypted in transit as well as at rest. This includes metadata such as file names, sizes, folder structure etc. Within Ouisync, data is readable only by the person who uploaded the data and those persons with whom they shared their repositories`
  String get messageSecurityPracticesP1 {
    return Intl.message(
      'Data that the user uploads into the Ouisync repositories is end-to-end encrypted in transit as well as at rest. This includes metadata such as file names, sizes, folder structure etc. Within Ouisync, data is readable only by the person who uploaded the data and those persons with whom they shared their repositories',
      name: 'messageSecurityPracticesP1',
      desc: '',
      args: [],
    );
  }

  /// `You can learn more about the encryption techniques used in our documentation`
  String get messageSecurityPracticesP2 {
    return Intl.message(
      'You can learn more about the encryption techniques used in our documentation',
      name: 'messageSecurityPracticesP2',
      desc: '',
      args: [],
    );
  }

  /// `The Ouisync app stores users’ data on an 'Always-On Peer', which is a server located in Canada. All data is stored as encrypted chunks and is not readable by the server or its operators. The purpose of this server is simply to bridge the gaps between peers who are not online at the same time. All data is periodically purged from this server - its purpose is not to provide permanent data storage but simply facilitation of data syncing by peers`
  String get messageSecurityPracticesP3 {
    return Intl.message(
      'The Ouisync app stores users’ data on an \'Always-On Peer\', which is a server located in Canada. All data is stored as encrypted chunks and is not readable by the server or its operators. The purpose of this server is simply to bridge the gaps between peers who are not online at the same time. All data is periodically purged from this server - its purpose is not to provide permanent data storage but simply facilitation of data syncing by peers',
      name: 'messageSecurityPracticesP3',
      desc: '',
      args: [],
    );
  }

  /// `If you have a reason to believe that your personal data has been illegaly obtained and shared by other Ouisync users, please contact us at the address below`
  String get messageSecurityPracticesP4 {
    return Intl.message(
      'If you have a reason to believe that your personal data has been illegaly obtained and shared by other Ouisync users, please contact us at the address below',
      name: 'messageSecurityPracticesP4',
      desc: '',
      args: [],
    );
  }

  /// `The simplest way to delete your data is by deleting files or repositories from your own device. Any file deletion will be propagated to all your peers - ie, if you have Write access to a repository, you can delete any files within it and the same files will be deleted from your peers’ repositories as well as from our Always-On-Peer. If you need to delete only the repositories from our Always-On-Peer (but still keep them in your own repository on your own device), please contact us at the address below`
  String get messageDeletionDataServerP1 {
    return Intl.message(
      'The simplest way to delete your data is by deleting files or repositories from your own device. Any file deletion will be propagated to all your peers - ie, if you have Write access to a repository, you can delete any files within it and the same files will be deleted from your peers’ repositories as well as from our Always-On-Peer. If you need to delete only the repositories from our Always-On-Peer (but still keep them in your own repository on your own device), please contact us at the address below',
      name: 'messageDeletionDataServerP1',
      desc: '',
      args: [],
    );
  }

  /// `The Ouisync team cannot delete individual files from repositories, as it is not possible to identify them because they are encrypted. We are able to delete whole repositories if you send us the link to the repository that needs to be deleted`
  String get messageDeletionDataServerNote {
    return Intl.message(
      'The Ouisync team cannot delete individual files from repositories, as it is not possible to identify them because they are encrypted. We are able to delete whole repositories if you send us the link to the repository that needs to be deleted',
      name: 'messageDeletionDataServerNote',
      desc: '',
      args: [],
    );
  }

  /// `The Ouisync app creates logfiles on users' devices. Their purpose is only to log device’s activity to facilitate the debugging process in case the user experiences difficulties in connecting with their peers or otherwise in using the Ouisync app. The logfile remains on a user's device unless the user decides to send it to us for support purposes`
  String get messageLogDataP1 {
    return Intl.message(
      'The Ouisync app creates logfiles on users\' devices. Their purpose is only to log device’s activity to facilitate the debugging process in case the user experiences difficulties in connecting with their peers or otherwise in using the Ouisync app. The logfile remains on a user\'s device unless the user decides to send it to us for support purposes',
      name: 'messageLogDataP1',
      desc: '',
      args: [],
    );
  }

  /// `If the user does decide to contact us, the personally indetifiable data we may collect is:`
  String get messageLogDataP2 {
    return Intl.message(
      'If the user does decide to contact us, the personally indetifiable data we may collect is:',
      name: 'messageLogDataP2',
      desc: '',
      args: [],
    );
  }

  /// `Email address - if the user decided to contact us by email`
  String get messageLogData1 {
    return Intl.message(
      'Email address - if the user decided to contact us by email',
      name: 'messageLogData1',
      desc: '',
      args: [],
    );
  }

  /// `Information the user may provide by email, through help tickets, or through our website, and associated metadata - for the purposes of providing technical support`
  String get messageLogData2 {
    return Intl.message(
      'Information the user may provide by email, through help tickets, or through our website, and associated metadata - for the purposes of providing technical support',
      name: 'messageLogData2',
      desc: '',
      args: [],
    );
  }

  /// `User’s IP address - for the purposes of providing technical support`
  String get messageLogData3 {
    return Intl.message(
      'User’s IP address - for the purposes of providing technical support',
      name: 'messageLogData3',
      desc: '',
      args: [],
    );
  }

  /// `None of this data is shared with any third parties`
  String get messageLogDataP3 {
    return Intl.message(
      'None of this data is shared with any third parties',
      name: 'messageLogDataP3',
      desc: '',
      args: [],
    );
  }

  /// `The Ouisync app does not use cookies`
  String get messageCookiesP1 {
    return Intl.message(
      'The Ouisync app does not use cookies',
      name: 'messageCookiesP1',
      desc: '',
      args: [],
    );
  }

  /// `This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services`
  String get messageLinksOtherSitesP1 {
    return Intl.message(
      'This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services',
      name: 'messageLinksOtherSitesP1',
      desc: '',
      args: [],
    );
  }

  /// `We do not knowingly collect personally identifiable information from children. We encourage all children to never submit any personally identifiable information through the Application and/or Services. We encourage parents and legal guardians to monitor their childrens’ Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission. If you have reason to believe that a child has provided personally identifiable information to us through the Application and/or Services, please contact us. You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country (in some countries we may allow your parent or guardian to do so on your behalf)`
  String get messageChildrensPolicyP1 {
    return Intl.message(
      'We do not knowingly collect personally identifiable information from children. We encourage all children to never submit any personally identifiable information through the Application and/or Services. We encourage parents and legal guardians to monitor their childrens’ Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission. If you have reason to believe that a child has provided personally identifiable information to us through the Application and/or Services, please contact us. You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country (in some countries we may allow your parent or guardian to do so on your behalf)',
      name: 'messageChildrensPolicyP1',
      desc: '',
      args: [],
    );
  }

  /// `We may update our Terms from time to time. Thus, you are advised to review this page periodically for any changes`
  String get messageChangesToTermsP1 {
    return Intl.message(
      'We may update our Terms from time to time. Thus, you are advised to review this page periodically for any changes',
      name: 'messageChangesToTermsP1',
      desc: '',
      args: [],
    );
  }

  /// `This policy is effective as of 2022-03-09`
  String get messageChangesToTermsP2 {
    return Intl.message(
      'This policy is effective as of 2022-03-09',
      name: 'messageChangesToTermsP2',
      desc: '',
      args: [],
    );
  }

  /// `If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at`
  String get messageContatUsP1 {
    return Intl.message(
      'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at',
      name: 'messageContatUsP1',
      desc: '',
      args: [],
    );
  }

  /// `Canada’s Privacy Act`
  String get messageCanadaPrivacyAct {
    return Intl.message(
      'Canada’s Privacy Act',
      name: 'messageCanadaPrivacyAct',
      desc: '',
      args: [],
    );
  }

  /// `PIPEDA`
  String get messagePIPEDA {
    return Intl.message(
      'PIPEDA',
      name: 'messagePIPEDA',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get messageNote {
    return Intl.message(
      'Note',
      name: 'messageNote',
      desc: '',
      args: [],
    );
  }

  /// `The repository is not mounted `
  String get messageRepositoryNotMounted {
    return Intl.message(
      'The repository is not mounted ',
      name: 'messageRepositoryNotMounted',
      desc: '',
      args: [],
    );
  }

  /// `Launch at startup`
  String get messageLaunchAtStartup {
    return Intl.message(
      'Launch at startup',
      name: 'messageLaunchAtStartup',
      desc: '',
      args: [],
    );
  }

  /// `Distributed Hash Tables`
  String get messageDistributedHashTables {
    return Intl.message(
      'Distributed Hash Tables',
      name: 'messageDistributedHashTables',
      desc: '',
      args: [],
    );
  }

  /// `Peer Exchange on Wikipedia`
  String get messagePeerExchangeWikipedia {
    return Intl.message(
      'Peer Exchange on Wikipedia',
      name: 'messagePeerExchangeWikipedia',
      desc: '',
      args: [],
    );
  }

  /// `Go to Peers`
  String get messageGoToPeers {
    return Intl.message(
      'Go to Peers',
      name: 'messageGoToPeers',
      desc: '',
      args: [],
    );
  }

  /// `NAT on Wikipedia`
  String get messageNATOnWikipedia {
    return Intl.message(
      'NAT on Wikipedia',
      name: 'messageNATOnWikipedia',
      desc: '',
      args: [],
    );
  }

  /// `Is a tool that allows peers to find each other on the P2P (Peer to Peer) network without a centralized server`
  String get messageInfoBittorrentDHT {
    return Intl.message(
      'Is a tool that allows peers to find each other on the P2P (Peer to Peer) network without a centralized server',
      name: 'messageInfoBittorrentDHT',
      desc: '',
      args: [],
    );
  }

  /// `Is a tool used for exchanging peer list with the peers you are connected to`
  String get messageInfoPeerExchange {
    return Intl.message(
      'Is a tool used for exchanging peer list with the peers you are connected to',
      name: 'messageInfoPeerExchange',
      desc: '',
      args: [],
    );
  }

  /// `Is a unique ID generated by Ouisync everytime it starts.\n\nYou can use it to confirm your connection with others in the Peer section of the app`
  String get messageInfoRuntimeID {
    return Intl.message(
      'Is a unique ID generated by Ouisync everytime it starts.\n\nYou can use it to confirm your connection with others in the Peer section of the app',
      name: 'messageInfoRuntimeID',
      desc: '',
      args: [],
    );
  }

  /// `Is a set of networking protocols that will allow your Ouisync apps to discover and communicate with each other.\n\nFor best connectivity we recommend this setting to be ON`
  String get messageInfoUPnP {
    return Intl.message(
      'Is a set of networking protocols that will allow your Ouisync apps to discover and communicate with each other.\n\nFor best connectivity we recommend this setting to be ON',
      name: 'messageInfoUPnP',
      desc: '',
      args: [],
    );
  }

  /// `Not available on mobile networks`
  String get messageLocalDiscoveryNotAvailableOnMobileNetwork {
    return Intl.message(
      'Not available on mobile networks',
      name: 'messageLocalDiscoveryNotAvailableOnMobileNetwork',
      desc: '',
      args: [],
    );
  }

  /// `The Local Peer Discovery allows your Ouisync apps to share files with your peers without going through internet service providers, where a local WiFi or other network is available.\n\nFor local connectivity this setting needs to be ON`
  String get messageInfoLocalDiscovery {
    return Intl.message(
      'The Local Peer Discovery allows your Ouisync apps to share files with your peers without going through internet service providers, where a local WiFi or other network is available.\n\nFor local connectivity this setting needs to be ON',
      name: 'messageInfoLocalDiscovery',
      desc: '',
      args: [],
    );
  }

  /// `When this setting is on, your mobile services provider may charge you for data used when syncing the repositories you share with your peers`
  String get messageInfoSyncMobileData {
    return Intl.message(
      'When this setting is on, your mobile services provider may charge you for data used when syncing the repositories you share with your peers',
      name: 'messageInfoSyncMobileData',
      desc: '',
      args: [],
    );
  }

  /// `This value depends on your router and/or your Internet service provider.\n\nConnectivity with your peers is best achieved when it is Endpoint Independent`
  String get messageInfoNATType {
    return Intl.message(
      'This value depends on your router and/or your Internet service provider.\n\nConnectivity with your peers is best achieved when it is Endpoint Independent',
      name: 'messageInfoNATType',
      desc: '',
      args: [],
    );
  }

  /// `Go to the mail app`
  String get messageGoToMailApp {
    return Intl.message(
      'Go to the mail app',
      name: 'messageGoToMailApp',
      desc: '',
      args: [],
    );
  }

  /// `Available on mobile`
  String get messageAvailableOnMobile {
    return Intl.message(
      'Available on mobile',
      name: 'messageAvailableOnMobile',
      desc: '',
      args: [],
    );
  }

  /// `Remove this repository local password?\n\nThe repository will unlock automatically, unless a local password is added again`
  String get messageRemoveLocalPasswordConfirmation {
    return Intl.message(
      'Remove this repository local password?\n\nThe repository will unlock automatically, unless a local password is added again',
      name: 'messageRemoveLocalPasswordConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Update this repository localpassword?`
  String get messageUpdateLocalPasswordConfirmation {
    return Intl.message(
      'Update this repository localpassword?',
      name: 'messageUpdateLocalPasswordConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `This action is irreversible, would you like to proceed?`
  String get messageConfirmIrreversibleChange {
    return Intl.message(
      'This action is irreversible, would you like to proceed?',
      name: 'messageConfirmIrreversibleChange',
      desc: '',
      args: [],
    );
  }

  /// `This will remove the repository password and use the biometric validation for unlocking`
  String get messageRemoveBiometricsConfirmationMoreInfo {
    return Intl.message(
      'This will remove the repository password and use the biometric validation for unlocking',
      name: 'messageRemoveBiometricsConfirmationMoreInfo',
      desc: '',
      args: [],
    );
  }

  /// `We couldn’t unlock the repository`
  String get messageAutomaticUnlockRepositoryFailed {
    return Intl.message(
      'We couldn’t unlock the repository',
      name: 'messageAutomaticUnlockRepositoryFailed',
      desc: '',
      args: [],
    );
  }

  /// `Biometric unlocking failed`
  String get messageBiometricUnlockRepositoryFailed {
    return Intl.message(
      'Biometric unlocking failed',
      name: 'messageBiometricUnlockRepositoryFailed',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a different name`
  String get messageEnterDifferentName {
    return Intl.message(
      'Please enter a different name',
      name: 'messageEnterDifferentName',
      desc: '',
      args: [],
    );
  }

  /// `Unknown file extension`
  String get messageUnknownFileExtension {
    return Intl.message(
      'Unknown file extension',
      name: 'messageUnknownFileExtension',
      desc: '',
      args: [],
    );
  }

  /// `Not apps can perform this action`
  String get messageNoAppsForThisAction {
    return Intl.message(
      'Not apps can perform this action',
      name: 'messageNoAppsForThisAction',
      desc: '',
      args: [],
    );
  }

  /// `We couldn’t start the file preview`
  String get messageFilePreviewFailed {
    return Intl.message(
      'We couldn’t start the file preview',
      name: 'messageFilePreviewFailed',
      desc: '',
      args: [],
    );
  }

  /// `Previewing file {path} failed`
  String messagePreviewingFileFailed(Object path) {
    return Intl.message(
      'Previewing file $path failed',
      name: 'messagePreviewingFileFailed',
      desc: '',
      args: [path],
    );
  }

  /// `File download canceled`
  String get messageDownloadFileCanceled {
    return Intl.message(
      'File download canceled',
      name: 'messageDownloadFileCanceled',
      desc: '',
      args: [],
    );
  }

  /// `File downloaded to {path}`
  String messageDownloadFileLocation(Object path) {
    return Intl.message(
      'File downloaded to $path',
      name: 'messageDownloadFileLocation',
      desc: '',
      args: [path],
    );
  }

  /// `Copied to the clipboard.`
  String get messageCopiedToClipboard {
    return Intl.message(
      'Copied to the clipboard.',
      name: 'messageCopiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Peer added`
  String get messagePeerAdded {
    return Intl.message(
      'Peer added',
      name: 'messagePeerAdded',
      desc: '',
      args: [],
    );
  }

  /// `Peer removed`
  String get messagePeerRemoved {
    return Intl.message(
      'Peer removed',
      name: 'messagePeerRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Use cache servers`
  String get messageUseCacheServers {
    return Intl.message(
      'Use cache servers',
      name: 'messageUseCacheServers',
      desc: '',
      args: [],
    );
  }

  /// `Reset local secret`
  String get messageResetLocalSecret {
    return Intl.message(
      'Reset local secret',
      name: 'messageResetLocalSecret',
      desc: '',
      args: [],
    );
  }

  /// `Sort by: {name}`
  String messageSortBy(Object name) {
    return Intl.message(
      'Sort by: $name',
      name: 'messageSortBy',
      desc: '',
      args: [name],
    );
  }

  /// `Error: {error}`
  String messageErrorDetail(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'messageErrorDetail',
      desc: '',
      args: [error],
    );
  }

  /// `Awaiting result...`
  String get messageAwaitingResult {
    return Intl.message(
      'Awaiting result...',
      name: 'messageAwaitingResult',
      desc: '',
      args: [],
    );
  }

  /// `Authenticate`
  String get messageAuthenticate {
    return Intl.message(
      'Authenticate',
      name: 'messageAuthenticate',
      desc: '',
      args: [],
    );
  }

  /// `Dokan`
  String get messageDokan {
    return Intl.message(
      'Dokan',
      name: 'messageDokan',
      desc: '',
      args: [],
    );
  }

  /// `Ouisync uses`
  String get messageInstallDokanForOuisyncP1 {
    return Intl.message(
      'Ouisync uses',
      name: 'messageInstallDokanForOuisyncP1',
      desc: '',
      args: [],
    );
  }

  /// `to access repositories via the File Explorer.\nPlease install Dokan to enhance your Ouisync experience.`
  String get messageInstallDokanForOuisyncP2 {
    return Intl.message(
      'to access repositories via the File Explorer.\nPlease install Dokan to enhance your Ouisync experience.',
      name: 'messageInstallDokanForOuisyncP2',
      desc: '',
      args: [],
    );
  }

  /// `The installed`
  String get messageDokanDifferentMayorP1 {
    return Intl.message(
      'The installed',
      name: 'messageDokanDifferentMayorP1',
      desc: '',
      args: [],
    );
  }

  /// `is out of date. Please update it to the latest version.`
  String get messageDokanDifferentMayorP2 {
    return Intl.message(
      'is out of date. Please update it to the latest version.',
      name: 'messageDokanDifferentMayorP2',
      desc: '',
      args: [],
    );
  }

  /// `is out of date.\n\nPlease uninstall the existing version of Dokan, reboot the system and run Ouisync again.`
  String get messageDokanOlderVersionP2 {
    return Intl.message(
      'is out of date.\n\nPlease uninstall the existing version of Dokan, reboot the system and run Ouisync again.',
      name: 'messageDokanOlderVersionP2',
      desc: '',
      args: [],
    );
  }

  /// `The Dokan installation failed.`
  String get messageDokanInstallationFailed {
    return Intl.message(
      'The Dokan installation failed.',
      name: 'messageDokanInstallationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Copy password`
  String get popupMenuItemCopyPassword {
    return Intl.message(
      'Copy password',
      name: 'popupMenuItemCopyPassword',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get popupMenuItemChangePassword {
    return Intl.message(
      'Change password',
      name: 'popupMenuItemChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Repository`
  String get menuItemRepository {
    return Intl.message(
      'Repository',
      name: 'menuItemRepository',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get menuItemNetwork {
    return Intl.message(
      'Network',
      name: 'menuItemNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get menuItemLogs {
    return Intl.message(
      'Logs',
      name: 'menuItemLogs',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get menuItemAbout {
    return Intl.message(
      'About',
      name: 'menuItemAbout',
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

  /// `{changes}`
  String replacementChanges(Object changes) {
    return Intl.message(
      '$changes',
      name: 'replacementChanges',
      desc: '',
      args: [changes],
    );
  }

  /// `{error}`
  String replacementError(Object error) {
    return Intl.message(
      '$error',
      name: 'replacementError',
      desc: '',
      args: [error],
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

  /// `Create a new repository`
  String get iconCreateRepository {
    return Intl.message(
      'Create a new repository',
      name: 'iconCreateRepository',
      desc: '',
      args: [],
    );
  }

  /// `Import a repository`
  String get iconAddExistingRepository {
    return Intl.message(
      'Import a repository',
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

  /// `Create Repository`
  String get actionCreateRepository {
    return Intl.message(
      'Create Repository',
      name: 'actionCreateRepository',
      desc: '',
      args: [],
    );
  }

  /// `Import a Repository`
  String get actionAddRepository {
    return Intl.message(
      'Import a Repository',
      name: 'actionAddRepository',
      desc: '',
      args: [],
    );
  }

  /// `Import Repository`
  String get actionAddRepositoryWithToken {
    return Intl.message(
      'Import Repository',
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

  /// `Import repository`
  String get actionImportRepo {
    return Intl.message(
      'Import repository',
      name: 'actionImportRepo',
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

  /// `Remove repository`
  String get actionRemoveRepo {
    return Intl.message(
      'Remove repository',
      name: 'actionRemoveRepo',
      desc: '',
      args: [],
    );
  }

  /// `Folder`
  String get actionNewFolder {
    return Intl.message(
      'Folder',
      name: 'actionNewFolder',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get actionNewFile {
    return Intl.message(
      'File',
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

  /// `Eject`
  String get actionEject {
    return Intl.message(
      'Eject',
      name: 'actionEject',
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

  /// `Discard`
  String get actionDiscard {
    return Intl.message(
      'Discard',
      name: 'actionDiscard',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get actionClear {
    return Intl.message(
      'Clear',
      name: 'actionClear',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get actionSaveChanges {
    return Intl.message(
      'Save changes',
      name: 'actionSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Go to settings`
  String get actionGoToSettings {
    return Intl.message(
      'Go to settings',
      name: 'actionGoToSettings',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get actionUndo {
    return Intl.message(
      'Undo',
      name: 'actionUndo',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get actionBack {
    return Intl.message(
      'Back',
      name: 'actionBack',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get actionImport {
    return Intl.message(
      'Import',
      name: 'actionImport',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get actionYes {
    return Intl.message(
      'Yes',
      name: 'actionYes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get actionNo {
    return Intl.message(
      'No',
      name: 'actionNo',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get actionSkip {
    return Intl.message(
      'Skip',
      name: 'actionSkip',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get actionDone {
    return Intl.message(
      'Done',
      name: 'actionDone',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get actionNext {
    return Intl.message(
      'Next',
      name: 'actionNext',
      desc: '',
      args: [],
    );
  }

  /// `I agree`
  String get actionIAgree {
    return Intl.message(
      'I agree',
      name: 'actionIAgree',
      desc: '',
      args: [],
    );
  }

  /// `I don’t agree`
  String get actionIDontAgree {
    return Intl.message(
      'I don’t agree',
      name: 'actionIDontAgree',
      desc: '',
      args: [],
    );
  }

  /// `Remove local password`
  String get actionRemoveLocalPassword {
    return Intl.message(
      'Remove local password',
      name: 'actionRemoveLocalPassword',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get actionUpdate {
    return Intl.message(
      'Update',
      name: 'actionUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Media`
  String get actionNewMediaFile {
    return Intl.message(
      'Media',
      name: 'actionNewMediaFile',
      desc: '',
      args: [],
    );
  }

  /// `Install Dokan`
  String get actionInstallDokan {
    return Intl.message(
      'Install Dokan',
      name: 'actionInstallDokan',
      desc: '',
      args: [],
    );
  }

  /// `Update Dokan`
  String get actionUpdateDokan {
    return Intl.message(
      'Update Dokan',
      name: 'actionUpdateDokan',
      desc: '',
      args: [],
    );
  }

  /// `Locate repository`
  String get actionLocateRepo {
    return Intl.message(
      'Locate repository',
      name: 'actionLocateRepo',
      desc: '',
      args: [],
    );
  }

  /// `Accessing repositories via File Explorer is not available: {reason}`
  String messageFailedToMount(Object reason) {
    return Intl.message(
      'Accessing repositories via File Explorer is not available: $reason',
      name: 'messageFailedToMount',
      desc: '',
      args: [reason],
    );
  }

  /// `Dokan is missing.{dokanUrl}`
  String messageErrorDokanNotInstalled(Object dokanUrl) {
    return Intl.message(
      'Dokan is missing.$dokanUrl',
      name: 'messageErrorDokanNotInstalled',
      desc: '',
      args: [dokanUrl],
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
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'my'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
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
