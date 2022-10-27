import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_entry.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

import 'repository_selector.dart';
import 'navigation_tile.dart';

class RepositorySection extends AbstractSettingsSection {
  final ReposCubit repos;
  final void Function(RepoCubit) onShareRepository;

  RepositorySection({required this.repos, required this.onShareRepository});

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
            _buildCurrentTile(context, _buildChangePasswordTile),
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
        title: Text('Peer Exchange'), // TODO: localize
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

  Widget _buildChangePasswordTile(BuildContext context, RepoCubit repo) =>
      NavigationTile(
        title: Text('Change password'), // TODO: localize
        leading: Icon(Icons.password),
        onPressed: (context) {
          // TODO
        },
        enabled: false,
      );

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
