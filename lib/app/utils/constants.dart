import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PasswordAction { add, change, remove, biometrics }

// enum DokanResult { ok, mayorOld, mayorMissing, notFound }
enum DokanResult {
  notFound,
  differentMayor,
  sameVersion,
  olderVersionMayor,
  newerVersionMayor
}

String? dokanResultToString(DokanResult value) {
  return switch (value) {
    DokanResult.notFound => 'not_found',
    DokanResult.differentMayor => 'found_different_mayor',
    DokanResult.sameVersion => 'found_same_version',
    DokanResult.olderVersionMayor => 'found_older_version_mayor',
    DokanResult.newerVersionMayor => 'found_newer_version_mayor',
  };
}

DokanResult? dokanResultFromString(String value) {
  return switch (value) {
    'not_found' => DokanResult.notFound,
    'found_different_mayor' => DokanResult.differentMayor,
    'found_same_version' => DokanResult.sameVersion,
    'found_older_version_mayor' => DokanResult.olderVersionMayor,
    'found_newer_version_mayor' => DokanResult.newerVersionMayor,
    _ => null,
  };
}

class Constants {
  Constants._();

  static const String launchAtStartupArg = 'auto';

  static const Color devColor = Colors.grey;

  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color dangerColor = Colors.red;

  static const String logFileName = 'ouisync.log';

  static const int bufferSize = 64000;

  static const String fileServerAuthority = 'localhost';
  static const String fileServerPreviewPath = 'preview';
  static const String fileServerHandleQuery = 'handle';

  static const int maxCharacterRepoTokenForDisplay = 8;
  static const String ouisyncUrl = 'https://ouisync.net';
  static const String issueTrackerUrl =
      'https://github.com/equalitie/ouisync-app/issues';
  static const String supportEmail = 'support@ouisync.net';
  static const String faqUrl = 'https://ouisync.net/support/';
  static const String eqPrivacyPolicy = 'https://ouisync.net/privacy/';
  static const eqValuesUrl = 'https://equalit.ie/values/';

  static const billHumanRightsUrl =
      'http://www.ohchr.org/Documents/Publications/Compilation1.1en.pdf';

  static const eqDeclarationDOS =
      'https://equalit.ie/declaration-distributed-online-services/';

  static const canadaPrivacyAct =
      'https://laws-lois.justice.gc.ca/ENG/ACTS/P-21/index.html';

  static const pipedaUrl =
      'https://www.priv.gc.ca/en/privacy-topics/privacy-laws-in-canada/the-personal-information-protection-and-electronic-documents-act-pipeda/';

  static const pexWikipediaUrl = 'https://en.wikipedia.org/wiki/Peer_exchange';

  static const natWikipediaUrl =
      'https://en.wikipedia.org/wiki/Network_address_translation';

  static Color primaryColor(context) => Theme.of(context).primaryColorDark;

  static const double repositoryBarHeight = 58.0;

  static const int modalTransitionDurationMs = 800;
  static const int notAvailableActionMessageDuration = 4;

  static const double statePlaceholderImageHeightFactor = 0.15;

  /// In-line text style names

  static const String inlineTextBold = 'bold';
  static const String inlineTextSize = 'size';
  static const String inlineTextColor = 'color';
  static const String inlineTextIcon = 'icon';

  /// Hero tags

  static const String heroTagMainPageActions = 'MAIN_PAGE_ACTIONS';
  static const String heroTagRepoListActions = 'REPO_LIST_ACTIONS';

  static const IconData iconVisibilityOn = Icons.visibility;
  static const IconData iconVisibilityOff = Icons.visibility_off;

  static const Color progressBarBackgroundColor =
      Color.fromRGBO(238, 238, 238, 1);
  static const Color modalBottomSheetBackgroundColor = Color(0xFFEAEEFF);
  static const Color folderIconColor = Color.fromARGB(255, 86, 86, 86);
  static const Color inputBackgroundColor = Color.fromARGB(255, 224, 224, 224);
  static const Color inputLabelForeColor = Color.fromARGB(255, 117, 117, 117);

  static const String ouisyncLogoFull = 'assets/OuisyncFull.png';
  static const String eQLogo = 'assets/eq_logo.png';

  static const String onboardingShareImage =
      '01_onboarding_send_receive_files.png';
  static const String onboardingPermissionsImage =
      '02_onboarding_permissions_collaborate.png';
  static const String onboardingAccessImage =
      '03_onboarding_access_multiple_devices.png';

  static const String appIcon = 'assets/ouisync_icon.png';
  static const String windowsAppIcon = './assets/favicon.ico';

  static const String eventLeftMouseUp = 'leftMouseUp';
  static const String eventRightMouseUp = 'rightMouseUp';

  static const String assetPathNothingHereYet = 'assets/nothing_here_yet.png';
  static const String assetPathAddWithQR = 'assets/add_with_qr.png';
  static const String assetLockedRepository = 'assets/locked_repo.png';
  static const String assetEmptyFolder = 'assets/empty_folder.png';

  static const String dokanUrl = "https://dokan-dev.github.io";

  // List of available cache servers.
  static List<String> get cacheServers => _cacheServers[appFlavor] ?? [];

  static const Map<String, List<String>> _cacheServers = {
    'production': ['server-ca.ouisync.net'],
    'unofficial': ['server-ca.ouisync.net'],
    'nightly': ['server-ca.ouisync.net:22443'],
  };

  static const int android12SDK = 32;

  static const String dokanMayorRequired = '2';
  static const String dokanMinimumVersion = '2.1.0.1000';
}
