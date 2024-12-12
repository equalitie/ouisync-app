import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoCubit;
import '../models/models.dart'
    show
        AuthModeBlindOrManual,
        AuthModeKeyStoredOnDevice,
        AuthModePasswordStoredOnDevice,
        RepoLocation;
import '../pages/pages.dart' show RepoSecurityPage;
import '../utils/platform/platform.dart' show PlatformValues;
import '../utils/utils.dart'
    show
        AccessModeLocalizedExtension,
        AppThemeExtension,
        Dialogs,
        Dimensions,
        LocalAuth,
        MasterKey,
        PasswordHasher,
        Settings,
        ThemeGetter,
        showSnackBar;
import '../widgets/widgets.dart'
    show
        ActionsDialog,
        DeleteRepoDialog,
        RenameRepository,
        ShareRepository,
        UnlockDialog,
        UnlockRepository,
        UnlockRepositoryResult;

mixin RepositoryActionsMixin on LoggyType {
  Future<String> renameRepository(
    BuildContext context, {
    required RepoCubit repoCubit,
    required RepoLocation location,
    required Future<void> Function(RepoLocation, String) renameRepoFuture,
  }) async {
    final newName = await _getRepositoryNewName(
      context,
      repoCubit: repoCubit,
    );

    if (newName.isNotEmpty) {
      await Dialogs.executeFutureWithLoadingDialog(
        null,
        renameRepoFuture(location, newName),
      );

      return newName;
    }

    return '';
  }

  Future<String> _getRepositoryNewName(
    BuildContext context, {
    required RepoCubit repoCubit,
  }) async {
    final newName = await showDialog<String>(
          context: context,
          builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(repoCubit),
          ),
        ) ??
        '';

    return newName;
  }

  Future<dynamic> shareRepository(BuildContext context,
      {required RepoCubit repository}) {
    final accessMode = repository.state.accessMode;
    final accessModes = accessMode == AccessMode.write
        ? [AccessMode.blind, AccessMode.read, AccessMode.write]
        : accessMode == AccessMode.read
            ? [AccessMode.blind, AccessMode.read]
            : [AccessMode.blind];

    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: Dimensions.borderBottomSheetTop,
      constraints: BoxConstraints(maxHeight: 390.0),
      builder: (_) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ShareRepository(
            repository: repository,
            availableAccessModes: accessModes,
          ),
        ),
      ),
    );
  }

  Future<void> navigateToRepositorySecurity(
    BuildContext context, {
    required Settings settings,
    required RepoCubit repoCubit,
    required PasswordHasher passwordHasher,
    required void Function() popDialog,
  }) async {
    LocalSecret secret;

    switch (repoCubit.state.authMode) {
      case (AuthModeBlindOrManual()):
        final password = await _getManualPassword(context, repoCubit);
        if (password.isEmpty) return;
        secret = LocalPassword(password);
        break;
      case (AuthModeKeyStoredOnDevice()):
      case (AuthModePasswordStoredOnDevice()):
        if (!await LocalAuth.authenticateIfPossible(
          context,
          S.current.messageAccessingSecureStorage,
        )) return;

        secret = (await repoCubit.getLocalSecret(settings.masterKey))!;
        break;
    }

    popDialog();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepoSecurityPage(
          settings: settings,
          repo: repoCubit,
          currentLocalSecret: secret,
          passwordHasher: passwordHasher,
        ),
      ),
    );
  }

  Future<String> _getManualPassword(
    BuildContext context,
    RepoCubit repoCubit,
  ) async {
    final password = await showDialog<String>(
          context: context,
          builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageValidateLocalPassword,
            body: UnlockDialog(repoCubit),
          ),
        ) ??
        '';

    return password;
  }

  Future<void> locateRepository(
    BuildContext context, {
    required RepoLocation repoLocation,
    required bool windows,
  }) async {
    final uri = Uri.directory(repoLocation.dir.path, windows: windows);
    if (PlatformValues.isDesktopDevice) {
      await launcher.launchUrl(uri);
      return;
    }

    final dbFile = p.basename(repoLocation.path);
    final segments = p.split(repoLocation.dir.path);

    final breadcrumbs = BreadCrumb.builder(
      itemCount: segments.length,
      divider: const Icon(Icons.chevron_right_rounded),
      builder: (index) {
        final crumb = Text(segments[index]);
        return BreadCrumbItem(content: crumb);
      },
    );

    await _showRepoLocationDialog(
      context,
      dbFile: dbFile,
      breadcrumbs: breadcrumbs,
    );
  }

  Future<void> _showRepoLocationDialog(
    BuildContext context, {
    required String dbFile,
    required BreadCrumb breadcrumbs,
  }) async =>
      Dialogs.alertDialogWithActions(
        context,
        title: S.current.actionLocateRepo,
        body: [
          Text(
            dbFile,
            style: context.theme.appTextStyle.bodyMedium
                .copyWith(fontWeight: FontWeight.w400),
          ),
          Dimensions.spacingVerticalDouble,
          breadcrumbs,
        ],
        actions: [
          TextButton(
            child: Text(S.current.actionCloseCapital),
            onPressed: () async => await Navigator.of(context).maybePop(false),
          ),
        ],
      );

  /// delete => ReposCubit.deleteRepository
  Future<bool> deleteRepository(
    BuildContext context, {
    required String repoName,
    required Future deleteRepoFuture,
  }) async {
    final delete = await _getDeleteRepoConfirmation(
      context,
      repoName: repoName,
    );

    if (delete == true) {
      await Dialogs.executeFutureWithLoadingDialog(
        null,
        deleteRepoFuture,
      );

      return true;
    }

    return false;
  }

  Future<bool> _getDeleteRepoConfirmation(
    BuildContext context, {
    required String repoName,
  }) async {
    final delete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => ActionsDialog(
              title: S.current.messageRenameRepository,
              body: DeleteRepoDialog(repoName: repoName)),
        ) ??
        false;

    return delete;
  }

  Future<void> unlockRepository(
    BuildContext context,
    RepoCubit repoCubit,
    MasterKey masterKey,
    PasswordHasher passwordHasher,
  ) async {
    final authMode = repoCubit.state.authMode;
    String? errorMessage;

    switch (authMode) {
      case (AuthModeBlindOrManual()):
        // First try to unlock it without a password.
        await repoCubit.unlock(null);
        final accessMode = repoCubit.accessMode;
        if (accessMode != AccessMode.blind) {
          showSnackBar(S.current.messageUnlockRepoOk(accessMode.localized));
          return;
        }

        // If it didn't work, try to unlock using a password from the user.
        final unlockResult = await _unlockRepositoryManually(
          context,
          repoCubit,
          masterKey,
          passwordHasher,
        );
        if (unlockResult == null) return;

        showSnackBar(unlockResult.message);

        return;
      case AuthModeKeyStoredOnDevice(secureWithBiometrics: true):
      case AuthModePasswordStoredOnDevice(secureWithBiometrics: true):
        if (!await LocalAuth.authenticateIfPossible(
          context,
          S.current.messageAccessingSecureStorage,
        )) return;

        errorMessage = S.current.messageBiometricUnlockRepositoryFailed;
      case AuthModeKeyStoredOnDevice():
      case AuthModePasswordStoredOnDevice():
        errorMessage = S.current.messageAutomaticUnlockRepositoryFailed;
    }

    final secret = await repoCubit.getLocalSecret(masterKey);

    if (secret == null) {
      showSnackBar(errorMessage);
      return;
    }

    await repoCubit.unlock(secret);
    final accessMode = repoCubit.accessMode;

    final message = (accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.localized)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(message);
  }

  Future<UnlockRepositoryResult?> _unlockRepositoryManually(
    BuildContext context,
    RepoCubit repoCubit,
    MasterKey masterKey,
    PasswordHasher passwordHasher,
  ) async {
    final isBiometricsAvailable = await LocalAuth.canAuthenticate();

    final result = await showDialog<UnlockRepositoryResult?>(
      context: context,
      builder: (BuildContext context) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ActionsDialog(
            title: S.current.messageUnlockRepository(repoCubit.name),
            body: UnlockRepository(
              repoCubit: repoCubit,
              masterKey: masterKey,
              passwordHasher: passwordHasher,
              isBiometricsAvailable: isBiometricsAvailable,
            ),
          ),
        ),
      ),
    );

    return result;
  }
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
