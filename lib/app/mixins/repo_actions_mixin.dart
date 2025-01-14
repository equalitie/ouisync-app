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
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

mixin RepositoryActionsMixin on LoggyType {
  /// rename => ReposCubit.renameRepository
  Future<void> renameRepository(
    BuildContext context, {
    required RepoCubit repoCubit,
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
      null,
      repoCubit.move(newName),
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
    required Session session,
    required RepoCubit repoCubit,
    required PasswordHasher passwordHasher,
    required void Function() popDialog,
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
      )) { return; }

      // TODO: Tell the user when the decryption fails.
      final secret = (await encryptedSecret.decrypt(settings.masterKey))!;
      access = await repoCubit.getAccessOf(secret);
    }

    popDialog();

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
          Fields.dialogActions(buttons: [
            NegativeButton(
              text: S.current.actionCancelCapital,
              onPressed: () async =>
                  await Navigator.of(context).maybePop(false),
            ),
            PositiveButton(
              text: S.current.actionDeleteCapital,
              onPressed: () async => await Navigator.of(context).maybePop(true),
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
            context, S.current.messageAccessingSecureStorage)) {
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
