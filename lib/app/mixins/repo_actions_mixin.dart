import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../pages/pages.dart';
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

  /// checkForBiometrics => main_page._checkForBiometricsCallback
  /// getAuthenticationMode => Settings.getAuthenticationMode
  Future<void> navigateToRepositorySecurity(
    BuildContext context, {
    required RepoCubit repository,
    required void Function() popDialog,
  }) async {
    final repoSettings = repository.repoSettings;
    final passwordMode = repoSettings.passwordMode;

    LocalSecret? secret;

    if (passwordMode == PasswordMode.manual) {
      final password = await manualUnlock(context, repository);
      if (password == null || password.isEmpty) return;
      secret = LocalPassword(password);
    } else {
      if (!await LocalAuth.authenticateIfPossible(
          context, S.current.messageAccessingSecureStorage)) return;

      secret = await repoSettings.getLocalSecret();
    }

    popDialog();

    final isBiometricsAvailable = await LocalAuth.canAuthenticate();

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RepositorySecurity(
            repo: repository,
            currentSecret: secret!,
            isBiometricsAvailable: isBiometricsAvailable,
          ),
        ));
  }

  Future<String?> manualUnlock(
    BuildContext context,
    RepoCubit repository,
  ) async {
    final result = await manualUnlockDialog(context, repository: repository);

    if (result.isFailure) {
      final message = result.failure;

      if (message != null) {
        showSnackBar(context, message: message);
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
  Future<void> deleteRepository(BuildContext context,
      {required RepoLocation repositoryLocation,
      required ReposCubit reposCubit,
      void Function()? popDialog}) async {
    final deleteRepo = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Flex(direction: Axis.horizontal, children: [
          Fields.constrainedText(S.current.titleDeleteRepository,
              style: context.theme.appTextStyle.titleMedium, maxLines: 2)
        ]),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(S.current.messageConfirmRepositoryDeletion,
                  style: context.theme.appTextStyle.bodyMedium)
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
      await Dialogs.executeFutureWithLoadingDialog(context,
          f: reposCubit.deleteRepository(repositoryLocation));

      if (popDialog != null) {
        popDialog();
      }
    }
  }

  /// setAuthenticationMode => Settings.setAuthenticationMode
  /// cubitUnlockRepository => ReposCubit.unlockRepository
  Future<void> unlockRepository(BuildContext context, ReposCubit reposCubit,
      {required DatabaseId databaseId,
      required RepoLocation repoLocation}) async {
    final repoSettings = reposCubit.settings.repoSettingsById(databaseId)!;
    final passwordMode = repoSettings.passwordMode;

    if (passwordMode == PasswordMode.manual) {
      final unlockResult = await unlockRepositoryManually(context, reposCubit,
          databaseId: databaseId, repoLocation: repoLocation);

      if (unlockResult == null) return;
      showSnackBar(context, message: unlockResult.message);
      return;
    }

    if (passwordMode == PasswordMode.bio) {
      if (!await LocalAuth.authenticateIfPossible(
          context, S.current.messageAccessingSecureStorage)) return;
    }

    final secret = await repoSettings.getLocalSecret();

    if (secret == null) {
      final message = passwordMode == PasswordMode.none
          ? S.current.messageAutomaticUnlockRepositoryFailed
          : S.current.messageBiometricUnlockRepositoryFailed;
      showSnackBar(context, message: message);
      return;
    }

    final repoCubit = await reposCubit.unlockRepository(repoLocation, secret);

    final accessMode = repoCubit?.accessMode;

    final message = (accessMode != null && accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.name)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(context, message: message);
  }

  /// cubitUnlockRepository => ReposCubit.unlockRepository
  /// setAuthenticationMode => Settings.setAuthenticationMode
  Future<UnlockRepositoryResult?> unlockRepositoryManually(
      BuildContext context, ReposCubit reposCubit,
      {required DatabaseId databaseId,
      required RepoLocation repoLocation}) async {
    final isBiometricsAvailable = await LocalAuth.canAuthenticate();

    return await showDialog<UnlockRepositoryResult?>(
        context: context,
        builder: (BuildContext context) =>
            ScaffoldMessenger(child: Builder(builder: ((context) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                    title: S.current.messageUnlockRepository,
                    body: UnlockRepository(reposCubit,
                        parentContext: context,
                        databaseId: databaseId,
                        repoLocation: repoLocation,
                        isPasswordValidation: false,
                        isBiometricsAvailable: isBiometricsAvailable),
                  ));
            }))));
  }

  String? validatePassword(String password,
      {required GlobalKey<FormFieldState> passwordInputKey,
      required GlobalKey<FormFieldState> retypePasswordInputKey}) {
    final isPasswordOk = passwordInputKey.currentState?.validate() ?? false;
    final isRetypePasswordOk =
        retypePasswordInputKey.currentState?.validate() ?? false;

    if (!(isPasswordOk && isRetypePasswordOk)) return null;

    passwordInputKey.currentState!.save();
    retypePasswordInputKey.currentState!.save();

    return password;
  }

  Future<bool?> confirmSaveChanges(
      BuildContext context, String positiveButtonText, String message) async {
    final saveChanges = await Dialogs.alertDialogWithActions(
        context: context,
        title: S.current.titleSaveChanges,
        body: [
          Text(message, style: context.theme.appTextStyle.bodyMedium)
        ],
        actions: [
          TextButton(
              child: Text(S.current.actionCancel.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(false)),
          TextButton(
              child: Text(positiveButtonText.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(true))
        ]);

    return saveChanges;
  }
}

Future<void> lockRepository(
    RepoEntry repositoryEntry, ReposCubit reposCubit) async {
  if (repositoryEntry.accessMode == AccessMode.blind) return;

  if (repositoryEntry is OpenRepoEntry) {
    await reposCubit.lockRepository(repositoryEntry.repoSettings);
  }
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
