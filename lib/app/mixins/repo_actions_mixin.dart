import 'dart:async' show FutureOr;

import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show ReposCubit, RepoCubit;
import '../cubits/store_dirs.dart';
import '../models/models.dart'
    show
        Access,
        AccessModeLocalizedExtension,
        BlindAccess,
        ReadAccess,
        RepoLocation,
        UnlockedAccess,
        WriteAccess;
import '../pages/pages.dart' show RepoSecurityPage;
import '../utils/utils.dart'
    show
        AppThemeExtension,
        Dialogs,
        Dimensions,
        Fields,
        LocalAuth,
        PasswordHasher,
        Settings,
        ThemeGetter,
        showSnackBar;
import '../widgets/store_dir.dart' show StoreDirDialog;
import '../widgets/widgets.dart'
    show
        ActionsDialog,
        GetPasswordAccessDialog,
        NegativeButton,
        PositiveButton,
        RenameRepository,
        ShareRepository;

mixin RepositoryActionsMixin on LoggyType {
  Future<String?> renameRepository(
    BuildContext context, {
    required ReposCubit reposCubit,
    required RepoLocation location,
  }) async {
    final newName = await _getRepositoryNewName(context, location);

    if (newName.isNotEmpty) {
      await Dialogs.executeFutureWithLoadingDialog(
        context,
        reposCubit.renameRepository(location, newName),
      );

      return newName;
    }

    return null;
  }

  Future<String> _getRepositoryNewName(
    BuildContext context,
    RepoLocation location,
  ) async {
    final newName =
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(location),
          ),
        ) ??
        '';

    return newName;
  }

  Future<dynamic> shareRepository(
    BuildContext context, {
    required RepoCubit repository,
  }) {
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
    required Session session,
    required RepoCubit repoCubit,
    required PasswordHasher passwordHasher,
    required FutureOr<void> Function() popDialog,
  }) async {
    //LocalSecret secret;
    final authMode = repoCubit.state.authMode;
    final encryptedSecret = authMode.storedLocalSecret;

    final Access? access;

    if (encryptedSecret == null) {
      // TODO: Check if the repo can be unlocked without a secret and if so,
      // proceed with `authenticateIfPossible`.

      access = await GetPasswordAccessDialog.show(
        context,
        settings,
        session,
        repoCubit,
      );
    } else {
      if (!await LocalAuth.authenticateIfPossible(
        context,
        S.current.messageAccessingSecureStorage,
      )) {
        return;
      }

      // TODO: Tell the user when the decryption fails.
      final secret = (await encryptedSecret.decrypt(settings.masterKey))!;
      access = await repoCubit.getAccessOf(secret);
    }

    await popDialog();

    final UnlockedAccess? unlockedAccess = access?.asUnlocked;

    if (unlockedAccess == null) {
      return;
    }

    await RepoSecurityPage.show(
      context,
      settings,
      session,
      repoCubit,
      unlockedAccess,
      passwordHasher,
    );
  }

  Future<void> showRepositoryStoreDialog(
    BuildContext context, {
    required RepoCubit repoCubit,
    required StoreDirsCubit storeDirsCubit,
  }) => showDialog<void>(
    context: context,
    builder: (context) =>
        StoreDirDialog(storeDirsCubit: storeDirsCubit, repoCubit: repoCubit),
  );

  Future<bool> showDeleteRepositoryDialog(
    BuildContext context, {
    required ReposCubit reposCubit,
    required RepoLocation repoLocation,
  }) async {
    final deleteRepo = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Flex(
          direction: Axis.horizontal,
          children: [
            Fields.constrainedText(
              S.current.titleDeleteRepository,
              style: context.theme.appTextStyle.titleMedium,
              maxLines: 2,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                S.current.messageConfirmRepositoryDeletion,
                style: context.theme.appTextStyle.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          NegativeButton(
            text: S.current.actionCancelCapital,
            onPressed: () async => await Navigator.of(context).maybePop(false),
          ),
          PositiveButton(
            text: S.current.actionDeleteCapital,
            onPressed: () async => await Navigator.of(context).maybePop(true),
            isDangerButton: true,
          ),
        ],
      ),
    );

    if (deleteRepo == true) {
      await Dialogs.executeFutureWithLoadingDialog(
        context,
        reposCubit.deleteRepository(repoLocation),
      );

      return true;
    }

    return false;
  }

  Future<void> unlockRepository(
    BuildContext context,
    Settings settings,
    Session session,
    RepoCubit repoCubit,
    PasswordHasher passwordHasher,
  ) async {
    final authMode = repoCubit.state.authMode;
    final LocalSecret? secret;
    String? errorMessage;

    final encryptedSecret = authMode.storedLocalSecret;

    if (encryptedSecret == null) {
      // First try to unlock it without a password.
      await repoCubit.unlock(null);
      final accessMode = repoCubit.accessMode;
      if (accessMode != AccessMode.blind) {
        showSnackBar(S.current.messageUnlockRepoOk(accessMode.localized));
        return;
      }

      // If it didn't work, try to unlock using a password from the user.
      final access = await GetPasswordAccessDialog.show(
        context,
        settings,
        session,
        repoCubit,
      );

      switch (access) {
        case null:
        case BlindAccess():
          return;
        case ReadAccess():
          secret = access.localSecret;
        case WriteAccess():
          secret = access.localSecret;
      }
    } else {
      final bio = authMode.isSecuredWithBiometrics;

      errorMessage = bio
          ? S.current.messageBiometricUnlockRepositoryFailed
          : S.current.messageAutomaticUnlockRepositoryFailed;

      if (bio) {
        if (!await LocalAuth.authenticateIfPossible(
          context,
          S.current.messageAccessingSecureStorage,
        )) {
          return;
        }
      }

      secret = await encryptedSecret.decrypt(settings.masterKey);
    }

    if (secret == null) {
      if (errorMessage != null) {
        showSnackBar(errorMessage);
      }
      return;
    }

    await repoCubit.unlock(secret);
    final accessMode = repoCubit.accessMode;

    final message = (accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.localized)
        : S.current.messageUnlockRepoFailed;

    showSnackBar(message);
  }
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
