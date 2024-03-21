import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../pages/pages.dart';
import '../utils/master_key.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

mixin RepositoryActionsMixin on LoggyType {
  /// rename => ReposCubit.renameRepository
  Future<void> renameRepository(
    BuildContext context, {
    required RepoCubit repository,
    required ReposCubit reposCubit,
    void Function()? popDialog,
  }) async {
    final newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(
                parentContext: context, oldName: repository.name)));

    if (newName == null || newName.isEmpty) {
      return;
    }

    await Dialogs.executeFutureWithLoadingDialog(context,
        f: reposCubit.renameRepository(repository.location, newName));

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
    final passwordMode = repoCubit.state.authMode.passwordMode;

    LocalSecret secret;

    if (passwordMode == PasswordMode.manual) {
      final password = await manualUnlock(context, repoCubit);
      if (password == null || password.isEmpty) return;
      secret = LocalPassword(password);
    } else {
      if (!await LocalAuth.authenticateIfPossible(
        context,
        S.current.messageAccessingSecureStorage,
      )) return;

      secret = (await repoCubit.getLocalSecret(settings.masterKey))!;
    }

    popDialog();

    final securityPage = await RepositorySecurityPage.create(
      settings: settings,
      repo: repoCubit,
      currentSecret: secret,
      passwordHasher: passwordHasher,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => securityPage),
    );
  }

  Future<String?> manualUnlock(
    BuildContext context,
    RepoCubit repository,
  ) async {
    final result = await manualUnlockDialog(context, repository: repository);

    if (result.isFailure) {
      final message = result.failure;

      if (message != null) {
        showSnackBar(message);
      }

      return null;
    }

    return result.success;
  }

  Future<Result<String, String?>> manualUnlockDialog(
    BuildContext context, {
    required RepoCubit repository,
  }) async {
    final password = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => ActionsDialog(
        title: S.current.messageValidateLocalPassword,
        body: UnlockDialog<String>(
          context: context,
          repository: repository,
        ),
      ),
    );

    if (password == null) {
      // User cancelled
      return Failure(null);
    }

    return switch (await repository.getPasswordAccessMode(password)) {
      AccessMode.write || AccessMode.read => Success(password),
      AccessMode.blind => Failure(S.current.messageUnlockRepoFailed),
    };
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
                onPressed: () => Navigator.of(context).pop(false),
                buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
            PositiveButton(
              text: S.current.actionDeleteCapital,
              onPressed: () => Navigator.of(context).pop(true),
              buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
              isDangerButton: true,
            )
          ])
        ],
      ),
    );

    if (deleteRepo ?? false) {
      await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: reposCubit.deleteRepository(repoLocation),
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
    final passwordMode = repoCubit.state.authMode.passwordMode;

    if (passwordMode == PasswordMode.manual) {
      final unlockResult = await unlockRepositoryManually(
        context,
        repoCubit,
        masterKey,
        passwordHasher,
      );
      if (unlockResult == null) return;

      showSnackBar(unlockResult.message);

      return;
    }

    if (passwordMode == PasswordMode.bio) {
      if (!await LocalAuth.authenticateIfPossible(
        context,
        S.current.messageAccessingSecureStorage,
      )) return;
    }

    final secret = await repoCubit.getLocalSecret(masterKey);

    if (secret == null) {
      final message = passwordMode == PasswordMode.none
          ? S.current.messageAutomaticUnlockRepositoryFailed
          : S.current.messageBiometricUnlockRepositoryFailed;
      showSnackBar(message);
      return;
    }

    await repoCubit.unlock(secret);
    final accessMode = repoCubit.accessMode;

    final message = (accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.name)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(message);
  }

  /// cubitUnlockRepository => ReposCubit.unlockRepository
  /// setAuthenticationMode => Settings.setAuthenticationMode
  Future<UnlockRepositoryResult?> unlockRepositoryManually(
    BuildContext context,
    RepoCubit repoCubit,
    MasterKey masterKey,
    PasswordHasher passwordHasher,
  ) async {
    final isBiometricsAvailable = await LocalAuth.canAuthenticate();

    return await showDialog<UnlockRepositoryResult?>(
        context: context,
        builder: (BuildContext context) =>
            ScaffoldMessenger(child: Builder(builder: ((context) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                    title: S.current.messageUnlockRepository,
                    body: UnlockRepository(
                      parentContext: context,
                      repoCubit: repoCubit,
                      masterKey: masterKey,
                      passwordHasher: passwordHasher,
                      isPasswordValidation: false,
                      isBiometricsAvailable: isBiometricsAvailable,
                    ),
                  ));
            }))));
  }
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
