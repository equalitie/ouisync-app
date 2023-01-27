import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_entry.dart';
import '../../pages/pages.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../../widgets/dialogs/unlock_dialog.dart';
import 'navigation_tile.dart';
import 'repository_selector.dart';

class RepositorySection extends AbstractSettingsSection with OuiSyncAppLogger {
  final ReposCubit repos;
  final bool isBiometricsAvailable;
  final void Function(RepoCubit) onShareRepository;

  RepositorySection(
      {required this.repos,
      required this.isBiometricsAvailable,
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
      SettingsTile.switchTile(
        initialValue: repo.isDhtEnabled,
        title: Text(S.current.labelBitTorrentDHT),
        leading: Icon(Icons.hub),
        onToggle: (value) {
          repo.setDhtEnabled(value);
        },
      );

  Widget _buildPexSwitch(
    BuildContext context,
    RepoCubit repo,
  ) =>
      SettingsTile.switchTile(
        initialValue: repo.isPexEnabled,
        title: Text(S.current.messagePeerExchange),
        leading: Icon(Icons.group_add),
        onToggle: (value) {
          repo.setPexEnabled(value);
        },
      );

  Widget _buildRenameTile(BuildContext context, RepoCubit repo) =>
      NavigationTile(
          title: Text(S.current.actionRename),
          leading: Icon(Icons.edit),
          onPressed: (context) async {
            final newName = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  final formKey = GlobalKey<FormState>();

                  return ActionsDialog(
                    title: S.current.messageRenameRepository,
                    body: RenameRepository(
                        context: context,
                        formKey: formKey,
                        repositoryName: repo.name),
                  );
                });

            if (newName == null || newName.isEmpty) {
              return;
            }

            repos.renameRepository(repo.name, newName);
          });

  Widget _buildShareTile(BuildContext context, RepoCubit repo) =>
      NavigationTile(
        title: Text(S.current.actionShare),
        leading: Icon(Icons.share),
        onPressed: (context) {
          onShareRepository(repo);
        },
      );

  Widget _buildSecurityTile(BuildContext parentContext, RepoCubit repo) =>
      NavigationTile(
          title: Text(S.current.titleSecurity),
          leading: Icon(Icons.password),
          onPressed: (context) async {
            final repo = repos.currentRepo;

            if (repo == null) {
              showSnackBar(context, message: S.current.messageNoRepoIsSelected);
              return;
            }

            if (repo is! OpenRepoEntry) {
              showSnackBar(context,
                  message: S.current.messageRepositoryIsNotOpen);
              return;
            }

            if (isBiometricsAvailable) {
              final biometricsResult = await _tryGetBiometricPassword(context,
                  databaseId: repo.databaseId);

              if (biometricsResult == null || biometricResult.value == null)
                return;

              final password = biometricResult.value;

              final shareToken = await repo.createShareToken(AccessMode.write,
                  password: password);

              if (shareToken.mode == AccessMode.blind) return;

              if (biometricsResult.value?.isNotEmpty ?? false) {
                await _pushRepositorySecurityPage(context,
                    repo: repo.cubit,
                    databaseId: repo.databaseId,
                    repositoryName: repo.name,
                    password: password,
                    shareToken: shareToken,
                    isBiometricsAvailable: true,
                    usesBiometrics: true);

                return;
              }
            }

            final passwordAndToken =
                await _validateManualPassword(parentContext, repo: repo.cubit);

            if (passwordAndToken == null) return;

            await _pushRepositorySecurityPage(parentContext,
                repo: repo.cubit,
                databaseId: repo.databaseId,
                repositoryName: repo.name,
                password: passwordAndToken.password,
                shareToken: passwordAntToken.shareToken,
                isBiometricsAvailable: isBiometricsAvailable,
                usesBiometrics: false);
          });

  Future<BiometricsResult?> _tryGetBiometricPassword(BuildContext context,
      {required String databaseId}) async {
    final biometricsResult = await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: Biometrics.getRepositoryPassword(databaseId: databaseId));

    if (biometricsResult.exception != null) {
      loggy.app(biometricsResult.exception);
      return null;
    }

    return biometricsResult;
  }

  Future<String?> _validateManualPassword(BuildContext context,
      {required RepoCubit repo}) async {
    final result = await showDialog<UnlockResult>(
        context: context,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.messageUnlockRepository,
            body: UnlockDialog<UnlockResult>(
                context: context,
                repo: repo,
                unlockCallback: _unlockShareToken)));

    if (result == null) {
      return null;
    }

    if (result.shareToken.mode == AccessMode.blind) {
      return null;
    }

    return result.password;
  }

  Future<UnlockResult> _unlockShareToken(RepoCubit repo,
      {required String password}) async {
    final token =
        await repo.createShareToken(AccessMode.write, password: password);
    return UnlockResult(password: password, shareToken: token);
  }

  Future<void> _pushRepositorySecurityPage(BuildContext context,
      {required RepoCubit repo,
      required String databaseId,
      required String repositoryName,
      required String password,
      required String shareToken,
      required bool isBiometricsAvailable,
      required bool usesBiometrics}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RepositorySecurity(
              databaseId: databaseId,
              repositoryName: repositoryName,
              repo: repo,
              password: password,
              shareToken: shareToken,
              isBiometricsAvailable: isBiometricsAvailable,
              usesBiometrics: usesBiometrics),
        ));
  }

  Widget _buildDeleteTile(BuildContext context, RepoCubit repo) =>
      NavigationTile(
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
