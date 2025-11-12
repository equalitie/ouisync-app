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
import '../utils/stage.dart';
import '../utils/utils.dart'
    show
        AppThemeExtension,
        Dimensions,
        Fields,
        LocalAuth,
        PasswordHasher,
        Settings,
        ThemeGetter;
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
  Future<String?> renameRepository({
    required Stage stage,
    required ReposCubit reposCubit,
    required RepoLocation location,
  }) async {
    final newName = await _getRepositoryNewName(stage, location);

    if (newName.isNotEmpty) {
      await stage.loading(reposCubit.renameRepository(location, newName));

      return newName;
    }

    return null;
  }

  Future<String> _getRepositoryNewName(
    Stage stage,
    RepoLocation location,
  ) async {
    final newName =
        await stage.showDialog<String>(
          builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(stage, location),
          ),
        ) ??
        '';

    return newName;
  }

  Future<dynamic> shareRepository({
    required RepoCubit repository,
    required Stage stage,
  }) {
    final accessMode = repository.state.accessMode;
    final accessModes = accessMode == AccessMode.write
        ? [AccessMode.blind, AccessMode.read, AccessMode.write]
        : accessMode == AccessMode.read
        ? [AccessMode.blind, AccessMode.read]
        : [AccessMode.blind];

    return stage.showModalBottomSheet(
      isScrollControlled: true,
      shape: Dimensions.borderBottomSheetTop,
      constraints: BoxConstraints(maxHeight: 390.0),
      builder: (_) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ShareRepository(
            repository: repository,
            availableAccessModes: accessModes,
            stage: stage,
          ),
        ),
      ),
    );
  }

  Future<void> navigateToRepositorySecurity({
    required Stage stage,
    required Settings settings,
    required Session session,
    required RepoCubit repoCubit,
    required PasswordHasher passwordHasher,
  }) async {
    //LocalSecret secret;
    final authMode = repoCubit.state.authMode;
    final encryptedSecret = authMode.storedLocalSecret;

    final Access? access;

    if (encryptedSecret == null) {
      // TODO: Check if the repo can be unlocked without a secret and if so,
      // proceed with `authenticateIfPossible`.

      access = await GetPasswordAccessDialog.show(
        stage,
        settings,
        session,
        repoCubit,
      );
    } else {
      if (!await LocalAuth.authenticateIfPossible(
        stage,
        S.current.messageAccessingSecureStorage,
      )) {
        return;
      }

      // TODO: Tell the user when the decryption fails.
      final secret = (await encryptedSecret.decrypt(settings.masterKey))!;
      access = await repoCubit.getAccessOf(secret);
    }

    await stage.maybePop();

    final UnlockedAccess? unlockedAccess = access?.asUnlocked;

    if (unlockedAccess == null) {
      return;
    }

    await stage.push(
      MaterialPageRoute(
        builder: (context) => RepoSecurityPage(
          settings: settings,
          session: session,
          repo: repoCubit,
          originalAccess: unlockedAccess,
          passwordHasher: passwordHasher,
          stage: stage,
        ),
      ),
    );
  }

  Future<void> showRepositoryStoreDialog({
    required RepoCubit repoCubit,
    required StoreDirsCubit storeDirsCubit,
    required Stage stage,
  }) => stage.showDialog<void>(
    builder: (context) => StoreDirDialog(
      storeDirsCubit: storeDirsCubit,
      repoCubit: repoCubit,
      stage: stage,
    ),
  );

  Future<bool> showDeleteRepositoryDialog({
    required Stage stage,
    required ReposCubit reposCubit,
    required RepoLocation repoLocation,
  }) async {
    final deleteRepo = await stage.showDialog<bool>(
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
      await stage.loading(reposCubit.deleteRepository(repoLocation));
      return true;
    }

    return false;
  }

  Future<void> unlockRepository({
    required BuildContext context,
    required Settings settings,
    required Session session,
    required RepoCubit repoCubit,
    required PasswordHasher passwordHasher,
    required Stage stage,
  }) async {
    final authMode = repoCubit.state.authMode;
    final LocalSecret? secret;
    String? errorMessage;

    final encryptedSecret = authMode.storedLocalSecret;

    if (encryptedSecret == null) {
      // First try to unlock it without a password.
      await repoCubit.unlock(null);
      final accessMode = repoCubit.accessMode;
      if (accessMode != AccessMode.blind) {
        stage.showSnackBar(S.current.messageUnlockRepoOk(accessMode.localized));
        return;
      }

      // If it didn't work, try to unlock using a password from the user.
      final access = await GetPasswordAccessDialog.show(
        stage,
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
          stage,
          S.current.messageAccessingSecureStorage,
        )) {
          return;
        }
      }

      secret = await encryptedSecret.decrypt(settings.masterKey);
    }

    if (secret == null) {
      if (errorMessage != null) {
        stage.showSnackBar(errorMessage);
      }
      return;
    }

    await repoCubit.unlock(secret);
    final accessMode = repoCubit.accessMode;

    final message = (accessMode != AccessMode.blind)
        ? S.current.messageUnlockRepoOk(accessMode.localized)
        : S.current.messageUnlockRepoFailed;

    stage.showSnackBar(message);
  }
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
