import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_entry.dart';
import '../../pages/pages.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../../widgets/dialogs/unlock_dialog.dart';
import '../../widgets/widgets.dart';
import 'navigation_tile_mobile.dart';
import 'repository_selector.dart';

class RepositorySectionMobile extends AbstractSettingsSection
    with OuiSyncAppLogger {
  final ReposCubit repos;
  final bool isBiometricsAvailable;
  final Future<void> Function(BuildContext) onRenameRepository;
  final void Function(RepoCubit) onShareRepository;

  RepositorySectionMobile(
      {required this.repos,
      required this.isBiometricsAvailable,
      required this.onRenameRepository,
      required this.onShareRepository});

  @override
  Widget build(BuildContext context) => repos.builder(
        (repos) => SettingsSection(
          title: Text(S.current.titleRepository),
          tiles: [
            SettingsTile(title: RepositorySelector(repos)),
            _buildCurrentTile(context, _buildDhtSwitch),
            _buildCurrentTile(context, _buildPexSwitch),
            _buildCurrentTile(context, _buildRenameTile),
            _buildCurrentTile(context, _buildShareTile),
            _buildCurrentTile(context, _buildSecurityTile),
            _buildCurrentTile(context, _buildDeleteTile),
          ],
        ),
      );

  AbstractSettingsTile _buildCurrentTile(
      BuildContext context, Widget Function(BuildContext, RepoCubit) builder) {
    final currentRepo = repos.currentRepo;
    final widget = currentRepo is OpenRepoEntry
        ? currentRepo.cubit.builder((repo) => builder(context, repo))
        : SizedBox.shrink();

    return CustomSettingsTile(child: widget);
  }

  Widget _buildDhtSwitch(
    BuildContext context,
    RepoCubit repo,
  ) =>
      PlatformSwitch(
          repository: repo,
          title: S.current.labelBitTorrentDHT,
          icon: Icons.hub,
          onToggle: (value) => repo.setDhtEnabled(value));

  Widget _buildPexSwitch(
    BuildContext context,
    RepoCubit repo,
  ) =>
      PlatformSwitch(
          repository: repo,
          title: S.current.messagePeerExchange,
          icon: Icons.group_add,
          onToggle: (value) => repo.setPexEnabled(value));

  Widget _buildRenameTile(BuildContext context, RepoCubit repo) =>
      PlatformTappableTile(
          reposCubit: repos,
          repoName: repo.name,
          title: S.current.actionRename,
          icon: Icons.edit,
          onTap: (context) async => await onRenameRepository(context));

  Widget _buildShareTile(BuildContext context, RepoCubit repo) =>
      NavigationTileMobile(
        title: Text(S.current.actionShare),
        leading: Icon(Icons.share),
        onPressed: (context) {
          onShareRepository(repo);
        },
      );

  Widget _buildSecurityTile(BuildContext parentContext, RepoCubit repo) =>
      NavigationTileMobile(
          title: Text(S.current.titleSecurity),
          leading: Icon(Icons.password),
          onPressed: (context) async {
            final repoEntry = repos.currentRepo;

            if (repoEntry == null) {
              showSnackBar(context, message: S.current.messageNoRepoIsSelected);
              return;
            }

            if (repoEntry is! OpenRepoEntry) {
              showSnackBar(context,
                  message: S.current.messageRepositoryIsNotOpen);
              return;
            }

            final repo = repoEntry.cubit;

            if (isBiometricsAvailable) {
              final password = await _tryGetBiometricPassword(context, repo);

              if (password != null) {
                final shareToken =
                    await _loadShareToken(context, repo, password);

                if (shareToken.mode == AccessMode.blind) {
                  showSnackBar(context,
                      message: S.current.messageUnlockRepoFailed);
                  return;
                }

                await _pushRepositorySecurityPage(context,
                    repo: repo,
                    password: password,
                    shareToken: shareToken,
                    isBiometricsAvailable: true,
                    usesBiometrics: true);

                return;
              }
            }

            final result =
                await _validateManualPassword(parentContext, repo: repo);

            if (result.isFailure) {
              final message = result.failure;

              if (message != null) {
                showSnackBar(context, message: message);
              }
              return;
            }

            final password = result.success.password;
            final shareToken = result.success.shareToken;

            await _pushRepositorySecurityPage(parentContext,
                repo: repo,
                password: password,
                shareToken: shareToken,
                isBiometricsAvailable: isBiometricsAvailable,
                usesBiometrics: false);
          });

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

  Widget _buildDeleteTile(BuildContext context, RepoCubit repo) =>
      NavigationTileMobile(
        title: Text(S.current.actionDelete,
            style: const TextStyle(color: Constants.dangerColor)),
        leading: Icon(Icons.delete, color: Constants.dangerColor),
        onPressed: (context) async {
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
            repos.deleteRepository(repo.metaInfo);
          }
        },
      );
}

class UnlockResult {
  UnlockResult({required this.password, required this.shareToken});

  final String password;
  final ShareToken shareToken;
}
