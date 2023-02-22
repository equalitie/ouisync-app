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
      required this.onShareRepository});

  final ReposCubit reposCubit;
  final Settings settings;
  final StateMonitorIntValue panicCounter;
  final Future<NatDetection> natDetection;
  final bool isBiometricsAvailable;

  final void Function(RepoCubit) onShareRepository;

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
                onItemTap: (setting) {
                  setState(() => _selected = setting);

                  loggy.app('Selected item: ${_selected?.setting.name}');
                },
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

    if (repository == null) {
      return;
    }

    final newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(
                context: context,
                formKey: formKey,
                repositoryName: repository.name),
          );
        });

    if (newName == null || newName.isEmpty) {
      return;
    }

    widget.reposCubit.renameRepository(repository.name, newName);
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

    final repo = repoEntry.cubit;
    return PlatformValues.isMobileDevice
        ? await _navigateToRepositorySecurity(parentContext, repo)
        : await _activateRepositorySecurity(parentContext, repo);
  }

  Future<String?> _navigateToRepositorySecurity(
      BuildContext parentContext, RepoCubit repository) async {
    if (widget.isBiometricsAvailable) {
      final password = await _tryGetBiometricPassword(context, repository);

      if (password == null) return null;

      final shareToken = await _loadShareToken(context, repository, password);

      if (shareToken.mode == AccessMode.blind) {
        showSnackBar(context, message: S.current.messageUnlockRepoFailed);
        return null;
      }

      await _navigateToSecurity(
          parentContext, repository, password, shareToken);

      return password;
    }

    final passwordToken =
        await _validatePasswordManually(parentContext, repository);

    if (passwordToken == null) return null;

    await _navigateToSecurity(parentContext, repository, passwordToken.password,
        passwordToken.shareToken);

    return passwordToken.password;
  }

  Future<void> _navigateToSecurity(BuildContext parentContext,
      RepoCubit repository, String password, ShareToken shareToken) async {
    await _pushRepositorySecurityPage(parentContext,
        repo: repository,
        password: password,
        shareToken: shareToken,
        isBiometricsAvailable: widget.isBiometricsAvailable,
        usesBiometrics: false);
  }

  Future<String?> _activateRepositorySecurity(
      BuildContext parentContext, RepoCubit repository) async {
    final passwordToken =
        await _validatePasswordManually(parentContext, repository);

    if (passwordToken == null) return null;

    return passwordToken.password;
  }

  Future<RepositoryPasswordToken?> _validatePasswordManually(
      BuildContext parentContext, RepoCubit repo) async {
    final result = await _validateManualPassword(parentContext, repo: repo);

    if (result.isFailure) {
      final message = result.failure;

      if (message != null) {
        showSnackBar(context, message: message);
      }

      return null;
    }

    final password = result.success.password;
    final shareToken = result.success.shareToken;

    return RepositoryPasswordToken(password: password, shareToken: shareToken);
  }

  Future<String?> _tryGetBiometricPassword(
      BuildContext context, RepoCubit repo) async {
    final biometricsResult =
        await Biometrics.getRepositoryPassword(databaseId: repo.databaseId);

    if (biometricsResult.exception != null) {
      loggy.app(biometricsResult.exception);
      return null;
    }

    return biometricsResult.value;
  }

  Future<ShareToken> _loadShareToken(
          BuildContext context, RepoCubit repo, String password) =>
      Dialogs.executeFutureWithLoadingDialog(context,
          f: repo.createShareToken(AccessMode.write, password: password));

  Future<void> _pushRepositorySecurityPage(BuildContext context,
      {required RepoCubit repo,
      required String password,
      required ShareToken shareToken,
      required bool isBiometricsAvailable,
      required bool usesBiometrics}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RepositorySecurity(
              repo: repo,
              password: password,
              shareToken: shareToken,
              isBiometricsAvailable: isBiometricsAvailable,
              usesBiometrics: usesBiometrics),
        ));
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

    if (result.shareToken.mode == AccessMode.blind) {
      return Failure(S.current.messageUnlockRepoFailed);
    }

    return Success(result);
  }

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
      widget.reposCubit.deleteRepository(repository.metaInfo);
    }
  }
}

class RepositoryPasswordToken {
  RepositoryPasswordToken({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
