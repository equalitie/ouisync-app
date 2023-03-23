import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../dialogs/unlock_dialog.dart';
import '../widgets.dart';

class SettingsContainer extends StatefulWidget {
  const SettingsContainer(
      {required this.reposCubit,
      required this.settings,
      required this.panicCounter,
      required this.natDetection,
      required this.isBiometricsAvailable,
      required this.onShareRepository,
      required this.onTryGetSecurePassword});

  final ReposCubit reposCubit;
  final Settings settings;
  final StateMonitorIntCubit panicCounter;
  final Future<NatDetection> natDetection;
  final bool isBiometricsAvailable;

  final void Function(RepoCubit) onShareRepository;
  final Future<String?> Function(BuildContext, String, String)
      onTryGetSecurePassword;

  @override
  State<SettingsContainer> createState() => _SettingsContainerState();
}

class _SettingsContainerState extends State<SettingsContainer>
    with OuiSyncAppLogger {
  SettingItem? _selected;

  @override
  void initState() {
    final defaultSetting = settingsItems
        .firstWhereOrNull((element) => element.setting == Setting.repository);
    setState(() => _selected = defaultSetting);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => PlatformValues.isMobileDevice
      ? _buildMobileLayout()
      : _buildDesktopLayout();

  Widget _buildMobileLayout() =>
      SettingsList(platform: PlatformUtils.detectPlatform(context), sections: [
        RepositorySectionMobile(
            repos: widget.reposCubit,
            isBiometricsAvailable: widget.isBiometricsAvailable,
            onRenameRepository: _renameRepo,
            onShareRepository: widget.onShareRepository,
            onRepositorySecurity: _activateOrNavigateRepositorySecurity,
            onDeleteRepository: _deleteRepository),
        NetworkSectionMobile(widget.natDetection),
        LogsSectionMobile(
            settings: widget.settings,
            repos: widget.reposCubit,
            panicCounter: widget.panicCounter,
            natDetection: widget.natDetection),
        AboutSectionMobile(repos: widget.reposCubit)
      ]);

  Widget _buildDesktopLayout() => Row(children: [
        Flexible(
            flex: 1,
            child: SettingsDesktopList(
                onItemTap: (setting) => setState(() => _selected = setting),
                selectedItem: _selected)),
        Flexible(
            flex: 4,
            child: SettingsDesktopDetail(
                item: _selected,
                reposCubit: widget.reposCubit,
                settings: widget.settings,
                panicCounter: widget.panicCounter,
                natDetection: widget.natDetection,
                isBiometricsAvailable: widget.isBiometricsAvailable,
                onRenameRepository: _renameRepo,
                onShareRepository: widget.onShareRepository,
                onRepositorySecurity: _activateOrNavigateRepositorySecurity,
                onDeleteRepository: _deleteRepository))
      ]);

  Future<void> _renameRepo(context) async {
    final currentRepo = widget.reposCubit.currentRepo;
    final repository = currentRepo is OpenRepoEntry ? currentRepo.cubit : null;

    if (currentRepo == null) {
      return;
    }

    if (repository == null) {
      return;
    }

    final currentRepoName = repository.name;

    final newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(
                context: context,
                formKey: formKey,
                repositoryName: currentRepoName),
          );
        });

    if (newName == null || newName.isEmpty) {
      return;
    }

    final reopenToken =
        await currentRepo.maybeCubit?.handle.createReopenToken();

    if (reopenToken == null) {
      loggy.app('Failed creating reopen token for repo $currentRepoName.');
      return;
    }

    await widget.reposCubit
        .renameRepository(currentRepoName, newName, reopenToken);
  }

  Future<String?> _activateOrNavigateRepositorySecurity(parentContext) async {
    final repoEntry = widget.reposCubit.currentRepo;

    if (repoEntry == null) {
      showSnackBar(context, message: S.current.messageNoRepoIsSelected);
      return null;
    }

    if (repoEntry is! OpenRepoEntry) {
      showSnackBar(context, message: S.current.messageRepositoryIsNotOpen);
      return null;
    }

    /// We don't have yet the UI for the security item in the repo settings
    /// on desktop; so for now we just navigate to the security page, like
    /// we do on mobile.
    /// TODO: Implement the security flow specific to desktop
    final repository = repoEntry.cubit;
    return await _navigateToRepositorySecurity(parentContext, repository);
    // if (PlatformValues.isDesktopDevice) {
    //   return (await _getPasswordFromUser(parentContext, repository))
    //           ?.password;
    // }

    // return await _navigateToRepositorySecurity(parentContext, repository);
  }

  Future<String?> _navigateToRepositorySecurity(
      BuildContext parentContext, RepoCubit repository) async {
    String? password;
    ShareToken? shareToken;

    final authenticationMode =
        widget.settings.getAuthenticationMode(repository.name) ??
            Constants.authModeVersion1;

    if (authenticationMode == Constants.authModeNoLocalPassword) {
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
        final localizedReason = 'Authentication required';
        final authorized =
            await auth.authenticate(localizedReason: localizedReason);

        if (authorized == false) {
          return null;
        }
      }
    }

    final securePassword = await widget.onTryGetSecurePassword
        .call(context, repository.databaseId, authenticationMode);

    if (securePassword != null && securePassword.isNotEmpty) {
      password = securePassword;
      shareToken = await _loadShareToken(context, repository, password);
    } else {
      final unlockResult =
          await _getPasswordFromUser(parentContext, repository);

      if (unlockResult == null) return null;

      password = unlockResult.password;
      shareToken = unlockResult.shareToken;
    }

    final accessMode = await shareToken.mode;

    if (accessMode == AccessMode.blind) {
      showSnackBar(context, message: S.current.messageUnlockRepoFailed);

      return null;
    }

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RepositorySecurity(
              repo: repository,
              password: password!,
              shareToken: shareToken!,
              isBiometricsAvailable: widget.isBiometricsAvailable,
              usesBiometrics: false),
        ));

    return password;
  }

  Future<UnlockResult?> _getPasswordFromUser(
      BuildContext parentContext, RepoCubit repo) async {
    final result = await _validateManualPassword(parentContext, repo: repo);

    if (result.isFailure) {
      final message = result.failure;

      if (message != null) {
        showSnackBar(context, message: message);
      }

      return null;
    }

    return result.success;
  }

  Future<Result<UnlockResult, String?>> _validateManualPassword(
      BuildContext context,
      {required RepoCubit repo}) async {
    final result = await showDialog<UnlockResult>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageUnlockRepository,
            body: UnlockDialog<UnlockResult>(
                context: context,
                repo: repo,
                unlockCallback: (repo, {required String password}) =>
                    _unlockShareToken(context, repo, password))));

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

  Future<ShareToken> _loadShareToken(
          BuildContext context, RepoCubit repo, String password) =>
      Dialogs.executeFutureWithLoadingDialog(context,
          f: repo.createShareToken(AccessMode.write, password: password));

  Future<UnlockResult> _unlockShareToken(
      BuildContext context, RepoCubit repo, String password) async {
    final token = await _loadShareToken(context, repo, password);
    return UnlockResult(password: password, shareToken: token);
  }

  Future<void> _deleteRepository(context) async {
    final currentRepo = widget.reposCubit.currentRepo;
    final repository = currentRepo is OpenRepoEntry ? currentRepo.cubit : null;

    if (repository == null) {
      return;
    }

    final delete = await showDialog<bool>(
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

    if (delete ?? false) {
      final authMode = widget.settings.getAuthenticationMode(repository.name) ??
          Constants.authModeVersion1;

      await widget.reposCubit.deleteRepository(repository.metaInfo, authMode);
    }
  }
}
