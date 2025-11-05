import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show RepoCubit, ReposCubit, RepoState;
import '../../cubits/store_dirs.dart';
import '../../mixins/mixins.dart' show RepositoryActionsMixin;
import '../../utils/themes/app_typography.dart' show AppTypography;
import '../../utils/utils.dart'
    show
        AppLogger,
        AppThemeExtension,
        Dimensions,
        Fields,
        ProgressExtension,
        Settings,
        showSnackBar,
        ThemeGetter;
import '../store_dir.dart';
import '../widgets.dart' show EntryActionItem, RepoProgressBuilder;

class RepositorySettings extends StatelessWidget
    with AppLogger, RepositoryActionsMixin {
  const RepositorySettings({
    required this.settings,
    required this.session,
    required this.repoCubit,
    required this.reposCubit,
    required this.storeDirsCubit,
  });

  final Settings settings;
  final Session session;
  final RepoCubit repoCubit;
  final ReposCubit reposCubit;
  final StoreDirsCubit storeDirsCubit;

  @override
  Widget build(BuildContext context) => BlocBuilder<RepoCubit, RepoState>(
    bloc: repoCubit,
    builder: (c, state) => SingleChildScrollView(
      child: Container(
        padding: Dimensions.paddingBottomSheet,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Fields.bottomSheetHandle(context),
              Row(
                children: [
                  Expanded(
                    child: Fields.bottomSheetTitle(
                      repoCubit.name,
                      style: context.theme.appTextStyle.titleMedium,
                    ),
                  ),
                  _Progress(repoCubit),
                ],
              ),
              _SwitchItem(
                title: S.current.labelBitTorrentDHT,
                icon: Icons.hub_outlined,
                value: state.isDhtEnabled,
                onChanged: (value) => repoCubit.setDhtEnabled(value),
              ),
              _SwitchItem(
                title: S.current.messagePeerExchange,
                icon: Icons.group_add_outlined,
                value: state.isPexEnabled,
                onChanged: (value) => repoCubit.setPexEnabled(value),
              ),
              if (state.accessMode == AccessMode.write)
                _SwitchItem(
                  title: S.current.messageUseCacheServers,
                  icon: Icons.cloud_outlined,
                  value: state.isCacheServersEnabled,
                  onChanged: (value) => repoCubit.setCacheServersEnabled(value),
                ),
              EntryActionItem(
                iconData: Icons.edit_outlined,
                title: S.current.actionRename,
                dense: true,
                onTap: () async {
                  final newName = await renameRepository(
                    context,
                    reposCubit: reposCubit,
                    location: repoCubit.location,
                  );

                  if (newName != null) {
                    Navigator.of(context).pop();
                    showSnackBar(S.current.messageRepositoryRenamed(newName));
                  }
                },
              ),
              EntryActionItem(
                iconData: Icons.share_outlined,
                title: S.current.actionShare,
                dense: true,
                onTap: () async {
                  await Navigator.of(context).maybePop();
                  await shareRepository(context, repository: repoCubit);
                },
              ),
              EntryActionItem(
                iconData: Icons.password_outlined,
                title: S.current.titleSecurity,
                dense: true,
                onTap: () async => await navigateToRepositorySecurity(
                  context,
                  settings: settings,
                  session: session,
                  repoCubit: repoCubit,
                  passwordHasher: reposCubit.passwordHasher,
                  popDialog: () => Navigator.of(context).pop(),
                ),
              ),

              //// TODO: Removed the eject button for now until the
              //// next release and after team discussion on where to
              //// best put it and how to explain the use case to the
              //// user.
              ///
              //// Only allow forgetting/ejecting a repository if the app
              //// is not storing the secret for the user.
              //if (!widget.cubit.repoSettings.hasLocalSecret())
              //  EntryActionItem(
              //      iconData: Icons.eject_outlined,
              //      title: S.current.actionEject,
              //      dense: true,
              //      onTap: () async {
              //        await widget.reposCubit
              //            .ejectRepository(widget.cubit.location);
              //        Navigator.of(context).pop();
              //      }),
              BlocBuilder<StoreDirsCubit, List<StoreDir>>(
                bloc: storeDirsCubit,
                builder: (context, storeDirs) {
                  final dir = storeDirs.firstWhereOrNull(
                    (dir) => dir.path == state.location.dir,
                  );

                  if (dir != null) {
                    return ListTile(
                      leading: Icon(dir.volume.icon),
                      title: Text(
                        S.current.messageStorage,
                        style: AppTypography.bodyMedium,
                      ),
                      subtitle: Text(dir.volume.description),
                      onTap: () => showRepositoryStoreDialog(
                        context,
                        repoCubit: repoCubit,
                        storeDirsCubit: storeDirsCubit,
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),

              EntryActionItem(
                iconData: Icons.delete_outline,
                title: S.current.actionDelete,
                dense: true,
                isDanger: true,
                onTap: () async {
                  final repoName = repoCubit.name;
                  final location = repoCubit.location;

                  final deleted = await showDeleteRepositoryDialog(
                    context,
                    reposCubit: reposCubit,
                    repoLocation: location,
                  );

                  if (deleted == true) {
                    Navigator.of(context).pop();
                    showSnackBar(S.current.messageRepositoryDeleted(repoName));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SwitchItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final Function(bool) onChanged;

  _SwitchItem({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    title: Text(title, style: context.theme.appTextStyle.bodyMedium),
    secondary: Icon(
      icon,
      size: Dimensions.sizeIconMicro,
      color: Colors.black87,
    ),
    contentPadding: EdgeInsetsDirectional.zero,
    dense: true,
    visualDensity: VisualDensity(horizontal: -4.0),
    value: value,
    onChanged: onChanged,
  );
}

class _Progress extends StatelessWidget {
  _Progress(this.repoCubit);

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => RepoProgressBuilder(
    repoCubit: repoCubit,
    builder: (context, progress) => Fields.bottomSheetTitle(
      '${S.current.labelSynced}: ${_formatProgress(progress)}',
    ),
  );
}

String _formatProgress(Progress progress) {
  final value = (progress.fraction * 100.0).truncateToDouble().toStringAsFixed(
    0,
  );
  return '$value%';
}
