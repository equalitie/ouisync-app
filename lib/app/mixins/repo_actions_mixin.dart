import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../pages/pages.dart';
import '../utils/master_key.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

mixin RepositoryActionsMixin on LoggyType {
  /// rename => ReposCubit.renameRepository
  Future<void> renameRepository(
    BuildContext context, {
    required RepoCubit repoCubit,
    required ReposCubit reposCubit,
    void Function()? popDialog,
  }) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => ActionsDialog(
        title: S.current.messageRenameRepository,
        body: RenameRepository(repoCubit),
      ),
    );

    if (newName == null || newName.isEmpty) {
      return;
    }

    await Dialogs.executeFutureWithLoadingDialog(
      context,
      reposCubit.renameRepository(repoCubit.location, newName),
    );

    if (popDialog != null) {
      popDialog();
    }
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
        final password = await manualUnlock(context, repoCubit);
        if (password == null || password.isEmpty) return;
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

  Future<String?> manualUnlock(
    BuildContext context,
    RepoCubit repoCubit,
  ) =>
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
          title: S.current.messageValidateLocalPassword,
          body: UnlockDialog(repoCubit),
        ),
      );

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

    await _showRepoLocationDialog(context, repoLocation);
  }

  Future<void> _showRepoLocationDialog(
    BuildContext context,
    RepoLocation repoLocation,
  ) async {
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

    await Dialogs.alertDialogWithActions(
      context: context,
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
  }

  /// delete => ReposCubit.deleteRepository
  Future<void> deleteRepository(
    BuildContext context, {
    required ReposCubit reposCubit,
    required RepoLocation repoLocation,
    void Function()? popDialog,
  }) async {
    final deleteRepo = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Flex(direction: Axis.horizontal, children: [
          Fields.constrainedText(
            S.current.titleDeleteRepository,
            style: context.theme.appTextStyle.titleMedium,
            maxLines: 2,
          )
        ]),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                S.current.messageConfirmRepositoryDeletion,
                style: context.theme.appTextStyle.bodyMedium,
              )
            ],
          ),
        ),
        actions: [
          Fields.dialogActions(context, buttons: [
            NegativeButton(
                text: S.current.actionCancelCapital,
                onPressed: () async =>
                    await Navigator.of(context).maybePop(false),
                buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
            PositiveButton(
              text: S.current.actionDeleteCapital,
              onPressed: () async => await Navigator.of(context).maybePop(true),
              buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
              isDangerButton: true,
            )
          ])
        ],
      ),
    );

    if (deleteRepo ?? false) {
      await Dialogs.executeFutureWithLoadingDialog(
        null,
        reposCubit.deleteRepository(repoLocation),
      );

      if (popDialog != null) {
        popDialog();
      }
    }
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
          showSnackBar(S.current.messageUnlockRepoOk(accessMode.name));
          return;
        }

        // If it didn't work, try to unlock using a password from the user.
        final unlockResult = await unlockRepositoryManually(
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
        ? S.current.messageUnlockRepoOk(accessMode.name)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(message);
  }

  Future<UnlockRepositoryResult?> unlockRepositoryManually(
    BuildContext context,
    RepoCubit repoCubit,
    MasterKey masterKey,
    PasswordHasher passwordHasher,
  ) async {
    final isBiometricsAvailable = await LocalAuth.canAuthenticate();

    return await showDialog<UnlockRepositoryResult?>(
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
  }
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
