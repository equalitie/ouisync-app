import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../models/models.dart';
import '../pages/pages.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

typedef CheckForBiometricsFunction = Future<bool?> Function();

mixin RepositoryActionsMixin {
  /// rename => ReposCubit.renameRepository
  Future<void> renameRepository(BuildContext context,
      {required RepoCubit repository,
      required Future<void> Function(String, String, Uint8List) rename,
      void Function()? popDialog}) async {
    final currentName = repository.name;

    final newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(
                context: context,
                formKey: formKey,
                repositoryName: currentName),
          );
        });

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
      required CheckForBiometricsFunction checkForBiometrics,
      required void Function() popDialog}) async {
    String? password;
    ShareToken? shareToken;

    AuthMode authenticationMode = repository.state.authenticationMode;

    if (authenticationMode == AuthMode.noLocalPassword &&
        (Platform.isAndroid || Platform.isIOS)) {
      final auth = LocalAuthentication();
      final isSupported = await auth.isDeviceSupported();

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
      if (isSupported) {
        final authorized = await auth.authenticate(
            localizedReason: S.current.messageAccessingSecureStorage);

        if (authorized == false) {
          return null;
        }
      }
    }

    final securePassword = await tryGetSecurePassword(
        context: context,
        databaseId: repository.databaseId,
        authenticationMode: authenticationMode);

    if (securePassword != null && securePassword.isNotEmpty) {
      password = securePassword;
      shareToken = await Dialogs.executeFutureWithLoadingDialog<ShareToken>(
          context,
          f: repository.createShareToken(AccessMode.write, password: password));
    } else {
      authenticationMode = AuthMode.manual;

      final unlockResult = await manualUnlock(context, repository);

      if (unlockResult == null) return null;

      password = unlockResult.password;
      shareToken = unlockResult.shareToken;
    }

    final accessMode = await shareToken.mode;

    if (accessMode == AccessMode.blind) {
      showSnackBar(context, message: S.current.messageUnlockRepoFailed);

      return null;
    }

    popDialog();

    final isBiometricsAvailable = await checkForBiometrics() ?? false;

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

  /// getAuthenticationMode => Settings.getAuthenticationMode
  /// delete => ReposCubit.deleteRepository
  Future<void> deleteRepository(BuildContext context,
      {required String repositoryName,
      required RepoMetaInfo repositoryMetaInfo,
      required AuthMode? Function(String) getAuthenticationMode,
      required Future<void> Function(RepoMetaInfo, AuthMode) delete,
      void Function()? popDialog}) async {
    final deleteRepo = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.titleDeleteRepository),
        content: SingleChildScrollView(
          child: ListBody(
            children: [Text(S.current.messageConfirmRepositoryDeletion)],
          ),
        ),
        actions: [
          TextButton(
            child: Text(S.current.actionCloseCapital),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DangerButton(
            text: S.current.actionDeleteCapital,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (deleteRepo ?? false) {
      final authMode =
          getAuthenticationMode(repositoryName) ?? AuthMode.version1;

      await Dialogs.executeFutureWithLoadingDialog(context,
          f: delete(repositoryMetaInfo, authMode));

      if (popDialog != null) {
        popDialog();
      }
    }
  }

  /// checkForBiometrics => main_page._checkForBiometricsCallback
  /// getAuthenticationMode => Settings.getAuthenticationMode
  /// setAuthenticationMode => Settings.setAuthenticationMode
  /// cubitUnlockRepository => ReposCubit.unlockRepository
  Future<void> unlockRepository(BuildContext context,
      {required String databaseId,
      required String repositoryName,
      required CheckForBiometricsFunction checkForBiometrics,
      required AuthMode? Function(String) getAuthenticationMode,
      required Future<void> Function(String, AuthMode?) setAuthenticationMode,
      required Future<AccessMode?> Function(String repositoryName,
              {required String password})
          cubitUnlockRepository}) async {
    AuthMode? authenticationMode = getAuthenticationMode(repositoryName);

    /// Runs once per repository (if needed): before adding to the app the
    /// possibility to create a repository without a local password, any entry
    /// to the secure storage (biometric_storage) required biometric validation
    /// (authenticationRequired=true, by default).
    ///
    /// With the option of not having a local password, we now save the password,
    /// for both this option and biometrics, in the secure storage, and only in
    /// the latest case we require biometric validation, using the Dart package
    /// local_auth, instead of the biometric_storage built in validation.
    ///
    /// Any repo that doesn't have this setting is considered from a version
    /// before this implementation, and we need to determine the value for this
    /// setting right after the update, on the first unlocking.
    ///
    /// Trying to get the password from the secure storage using the built in
    /// biometric validation can tell us this:
    ///
    /// IF securePassword != null
    ///   The repo password exist and it was secured using biometrics. (version1)
    /// ELSE
    ///   The repo password doesn't exist and it was manually input by the user.
    ///
    /// (If the password is empty, something wrong happened in the previous
    /// version of the app saving its value and it is considered non existent
    /// in the secure storage, this is, not secured with biometrics).
    if (authenticationMode == null || authenticationMode == AuthMode.version1) {
      final securedPassword = await getPasswordAndUnlock(context,
          databaseId: databaseId,
          repositoryName: repositoryName,
          authenticationMode: AuthMode.version1,
          cubitUnlockRepository: cubitUnlockRepository);

      if (securedPassword == null) {
        return;
      }

      /// IF password.isEmpty => The password doesn't exist in the secure
      /// storage.
      authenticationMode =
          securedPassword.isEmpty ? AuthMode.manual : AuthMode.version1;

      await setAuthenticationMode(repositoryName, authenticationMode);

      if (authenticationMode == AuthMode.version1) {
        final upgraded = await upgradeBiometricEntryToVersion2(
            databaseId: databaseId, password: securedPassword);

        if (upgraded == null) {
          print('Upgrading repo $repositoryName to AUTH_MODE version2 failed.');

          return;
        }

        if (upgraded == false) {
          print('Removing the old entry (version1) for $repositoryName in the '
              'secure storage failed, but the creating the new entry (version2) '
              'was successful.');
        }

        await setAuthenticationMode(repositoryName, AuthMode.version2);

        return;
      }
    }

    if (authenticationMode == AuthMode.manual) {
      final unlockResult = await getManualPasswordAndUnlock(context,
          databaseId: databaseId,
          repositoryName: repositoryName,
          checkForBiometrics: checkForBiometrics,
          cubitUnlockRepository: cubitUnlockRepository,
          setAuthenticationMode: setAuthenticationMode);

      if (unlockResult == null) return;

      showSnackBar(context, message: unlockResult.message);

      return;
    }

    await getPasswordAndUnlock(context,
        databaseId: databaseId,
        repositoryName: repositoryName,
        authenticationMode: authenticationMode,
        cubitUnlockRepository: cubitUnlockRepository);
  }

  /// cubitUnlockRepository => ReposCubit.unlockRepository
  Future<String?> getPasswordAndUnlock(BuildContext context,
      {required String databaseId,
      required String repositoryName,
      required AuthMode authenticationMode,
      required Future<AccessMode?> Function(String repositoryName,
              {required String password})
          cubitUnlockRepository}) async {
    if (authenticationMode == AuthMode.manual) {
      return null;
    }

    final securePassword = await tryGetSecurePassword(
        context: context,
        databaseId: databaseId,
        authenticationMode: authenticationMode);

    if (securePassword == null) {
      /// There was an exception getting the value from the secure storage.
      return null;
    }

    if (securePassword.isEmpty) {
      return '';
    }

    final accessMode =
        await cubitUnlockRepository(repositoryName, password: securePassword);

    final message = (accessMode != null && accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.name)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(context, message: message);

    return securePassword;
  }

  Future<String?> tryGetSecurePassword(
      {required BuildContext context,
      required String databaseId,
      required AuthMode authenticationMode}) async {
    if (authenticationMode == AuthMode.manual) {
      return null;
    }

    if (authenticationMode == AuthMode.version2) {
      final auth = LocalAuthentication();

      final authorized = await auth.authenticate(
          localizedReason: S.current.messageAccessingSecureStorage);

      if (authorized == false) {
        return null;
      }
    }

    final value = await readSecureStorage(
        databaseId: databaseId, authMode: authenticationMode);

    return value;
  }

  Future<String?> readSecureStorage(
      {required String databaseId, required AuthMode authMode}) async {
    final secureStorageResult = await SecureStorage.getRepositoryPassword(
        databaseId: databaseId, authMode: authMode);

    if (secureStorageResult.exception != null) {
      print(secureStorageResult.exception);

      return null;
    }

    return secureStorageResult.value ?? '';
  }

  Future<bool?> upgradeBiometricEntryToVersion2(
      {required String databaseId, required String password}) async {
    final addTempResult = await SecureStorage.addRepositoryPassword(
        databaseId: databaseId,
        password: password,
        authMode: AuthMode.version2);

    if (addTempResult.exception != null) {
      print(addTempResult.exception);

      return null;
    }

    final deleteOldResult = await SecureStorage.deleteRepositoryPassword(
        databaseId: databaseId,
        authMode: AuthMode.version1,
        authenticationRequired: false);

    if (deleteOldResult.exception != null) {
      print(deleteOldResult.exception);

      return false;
    }

    return true;
  }

  /// cubitUnlockRepository => ReposCubit.unlockRepository
  /// setAuthenticationMode => Settings.setAuthenticationMode
  Future<UnlockRepositoryResult?> getManualPasswordAndUnlock(
      BuildContext context,
      {required String databaseId,
      required String repositoryName,
      required CheckForBiometricsFunction checkForBiometrics,
      required Future<void> Function(String repoName, AuthMode? value)
          setAuthenticationMode,
      required Future<AccessMode?> Function(String repositoryName,
              {required String password})
          cubitUnlockRepository}) async {
    final isBiometricsAvailable = await checkForBiometrics() ?? false;

    final unlockResult = await showDialog<UnlockRepositoryResult?>(
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
                        setAuthenticationModeCallback: setAuthenticationMode,
                        unlockRepositoryCallback: cubitUnlockRepository),
                  ));
            }))));

    return unlockResult;
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
          Text(message)
        ],
        actions: [
          TextButton(
              child: Text(positiveButtonText),
              onPressed: () => Navigator.of(context).pop(true)),
          TextButton(
              child: Text(S.current.actionCancel),
              onPressed: () => Navigator.of(context).pop(false))
        ]);

    return saveChanges;
  }
}
