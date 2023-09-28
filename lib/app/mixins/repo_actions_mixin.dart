import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../pages/pages.dart';
import '../storage/storage.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

typedef CheckForBiometricsFunction = Future<bool?> Function();

mixin RepositoryActionsMixin on AppLogger {
  /// rename => ReposCubit.renameRepository
  Future<void> renameRepository(BuildContext context,
      {required RepoCubit repository,
      required Future<void> Function(String, String, Uint8List) rename,
      void Function()? popDialog}) async {
    final currentName = repository.name;

    final newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(
                parentContext: context, oldName: currentName)));

    if (newName == null || newName.isEmpty) {
      return;
    }

    final reopenToken = await repository.handle.createReopenToken();

    await Dialogs.executeFutureWithLoadingDialog(context,
        f: rename(currentName, newName, reopenToken));

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
  Future<String?> navigateToRepositorySecurity(BuildContext context,
      {required RepoCubit repository,
      required Settings settings,
      required void Function() popDialog}) async {
    String? password;
    ShareToken? shareToken;

    AuthMode authenticationMode = repository.state.authenticationMode;

    if (authenticationMode == AuthMode.noLocalPassword) {
      final authorized = await authorizeNavigationToSettings();
      if (authorized == null || authorized == false) return null;
    }

    if (authenticationMode == AuthMode.manual) {
      final unlockResult = await manualUnlock(context, repository);

      if (unlockResult == null) return null;

      password = unlockResult.password;
      shareToken = unlockResult.shareToken;
    } else {
      final databaseId = repository.databaseId;
      final securePassword = await SecureStorage(databaseId: databaseId)
          .tryGetPassword(authMode: authenticationMode);

      if (securePassword == null || securePassword.isEmpty) return null;

      password = securePassword;
      shareToken = await Dialogs.executeFutureWithLoadingDialog<ShareToken>(
          context,
          f: repository.createShareToken(AccessMode.write, password: password));
    }

    final accessMode = await shareToken.mode;

    if (accessMode == AccessMode.blind) {
      showSnackBar(context, message: S.current.messageUnlockRepoFailed);

      return null;
    }

    popDialog();

    final isBiometricsAvailable =
        await SecurityValidations.canCheckBiometrics() ?? false;

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RepositorySecurity(
              repo: repository,
              password: password!,
              shareToken: shareToken!,
              isBiometricsAvailable: isBiometricsAvailable,
              authenticationMode: authenticationMode),
        ));

    return password;
  }

  Future<UnlockResult?> manualUnlock(
      BuildContext context, RepoCubit repository) async {
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

  Future<Result<UnlockResult, String?>> manualUnlockDialog(BuildContext context,
      {required RepoCubit repository}) async {
    final result = await showDialog<UnlockResult>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageValidateLocalPassword,
            body: UnlockDialog<UnlockResult>(
                context: context,
                repository: repository,
                manualUnlockCallback: getShareTokenAtUnlock)));

    if (result == null) {
      // User cancelled
      return Failure(null);
    }

    final accessMode = await result.shareToken.mode;
    if (accessMode == AccessMode.blind) {
      return Failure(S.current.messageUnlockRepoFailed);
    }

    return Success(result);
  }

  Future<UnlockResult> getShareTokenAtUnlock(repository,
      {required String password}) async {
    final token =
        await repository.createShareToken(AccessMode.write, password: password);

    return UnlockResult(password: password, shareToken: token);
  }

  /// delete => ReposCubit.deleteRepository
  Future<void> deleteRepository(BuildContext context,
      {required String repositoryName,
      required RepoMetaInfo repositoryMetaInfo,
      required Settings settings,
      required Future<void> Function(RepoMetaInfo, AuthMode) delete,
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
                text: S.current.actionCloseCapital,
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
      final authMode = settings.getAuthenticationMode(repositoryName);

      await Dialogs.executeFutureWithLoadingDialog(context,
          f: delete(repositoryMetaInfo, authMode));

      if (popDialog != null) {
        popDialog();
      }
    }
  }

  /// setAuthenticationMode => Settings.setAuthenticationMode
  /// cubitUnlockRepository => ReposCubit.unlockRepository
  Future<void> unlockRepository(BuildContext context,
      {required String databaseId,
      required String repositoryName,
      required AuthMode authenticationMode,
      required Settings settings,
      required Future<AccessMode?> Function(String repositoryName,
              {required String password})
          cubitUnlockRepository}) async {
    if (authenticationMode == AuthMode.manual) {
      final isBiometricsAvailable =
          await SecurityValidations.canCheckBiometrics() ?? false;

      final unlockResult = await unlockRepositoryManually(context,
          databaseId: databaseId,
          repositoryName: repositoryName,
          isBiometricsAvailable: isBiometricsAvailable,
          settings: settings,
          cubitUnlockRepository: cubitUnlockRepository);

      if (unlockResult == null) return;

      showSnackBar(context, message: unlockResult.message);

      return;
    }

    final securePassword = await SecureStorage(databaseId: databaseId)
        .tryGetPassword(authMode: authenticationMode);

    if (securePassword == null || securePassword.isEmpty) {
      final message = authenticationMode == AuthMode.noLocalPassword
          ? S.current.messageAutomaticUnlockRepositoryFailed
          : S.current.messageBiometricUnlockRepositoryFailed;
      showSnackBar(context, message: message);
      return;
    }

    final accessMode =
        await cubitUnlockRepository(repositoryName, password: securePassword);

    final message = (accessMode != null && accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.name)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(context, message: message);
  }

  /// cubitUnlockRepository => ReposCubit.unlockRepository
  /// setAuthenticationMode => Settings.setAuthenticationMode
  Future<UnlockRepositoryResult?> unlockRepositoryManually(BuildContext context,
          {required String databaseId,
          required String repositoryName,
          required bool isBiometricsAvailable,
          required Settings settings,
          required Future<AccessMode?> Function(String repositoryName,
                  {required String password})
              cubitUnlockRepository}) async =>
      await showDialog<UnlockRepositoryResult?>(
          context: context,
          builder: (BuildContext context) =>
              ScaffoldMessenger(child: Builder(builder: ((context) {
                return Scaffold(
                    backgroundColor: Colors.transparent,
                    body: ActionsDialog(
                      title: S.current.messageUnlockRepository,
                      body: UnlockRepository(
                          parentContext: context,
                          databaseId: databaseId,
                          repositoryName: repositoryName,
                          isPasswordValidation: false,
                          isBiometricsAvailable: isBiometricsAvailable,
                          settings: settings,
                          unlockRepositoryCallback: cubitUnlockRepository),
                    ));
              }))));

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

Future<bool?> authorizeNavigationToSettings() async {
  /// local_auth doesn't support Linux. If the repository has a local password,
  /// then we use it for validation; otherwise we just return true.
  if (Platform.isLinux) {
    return true;
  }

  final isSupported = Platform.isLinux
      ? false
      : await SecurityValidations.isBiometricSupported();

  /// LocalAuthentication can tell us three (3) things:
  ///
  /// - canCheck: If the device has biometrics capabilities, maybe even just
  ///   PIN, pattern or password protection, it returns TRUE. Basically, it
  ///   always returns TRUE.
  ///
  ///   NOTE: This needs to be confirmed on a phone without any biometric
  ///   capability
  ///
  /// - available: The list of enrolled biometrics.
  ///   If the user has PIN (Password, pattern, even?), but no biometric
  ///   method in use, it returns an empty list.
  ///   If the user has a biometric method in use, it returns a list with
  ///   BiometricType.WEAK (PIN, password, pattern), and any biometric method
  ///   used by the user (Fingerprint, face, etc.) as BiometricType.STRONG.
  ///
  /// - isSupported: Only if the user doesn't use any screen lock method
  ///   (Pattern, PIN, password), which also means it doesn't use any
  ///   biometric method, it returns FALSE.
  ///
  /// We don't use isBiometricsAvailable here because it only validates that
  /// the user has at least one biometric method enrolled
  /// (BiometricType.STRONG); if the user only uses weak methods
  /// (BiometricType.WEAK) like PIN, password, pattern; it returns FALSE.
  var authorized = false;
  if (isSupported) {
    authorized = await SecurityValidations.validateBiometrics(
        localizedReason: S.current.messageAccessingSecureStorage);

    if (authorized == false) {
      return null;
    }
  }

  return authorized;
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
