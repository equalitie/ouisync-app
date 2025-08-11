import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show RepoCubit, ReposCubit, RepoState;
import '../../mixins/mixins.dart' show RepositoryActionsMixin;
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
import '../widgets.dart' show EntryActionItem, RepoProgressBuilder;

class RepositorySettings extends StatefulWidget {
  const RepositorySettings({
    required this.settings,
    required this.session,
    required this.repoCubit,
    required this.reposCubit,
  });

  final Settings settings;
  final Session session;
  final RepoCubit repoCubit;
  final ReposCubit reposCubit;

  @override
  State<RepositorySettings> createState() => _RepositorySettingsState();
}

class _RepositorySettingsState extends State<RepositorySettings>
    with AppLogger, RepositoryActionsMixin {
  @override
  Widget build(BuildContext context) => BlocBuilder<RepoCubit, RepoState>(
    bloc: widget.repoCubit,
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
                      widget.repoCubit.name,
                      style: context.theme.appTextStyle.titleMedium,
                    ),
                  ),
                  _Progress(widget.repoCubit),
                ],
              ),
              _SwitchItem(
                title: S.current.labelBitTorrentDHT,
                icon: Icons.hub_outlined,
                value: state.isDhtEnabled,
                onChanged: (value) => widget.repoCubit.setDhtEnabled(value),
              ),
              _SwitchItem(
                title: S.current.messagePeerExchange,
                icon: Icons.group_add_outlined,
                value: state.isPexEnabled,
                onChanged: (value) => widget.repoCubit.setPexEnabled(value),
              ),
              if (state.accessMode == AccessMode.write)
                _SwitchItem(
                  title: S.current.messageUseCacheServers,
                  icon: Icons.cloud_outlined,
                  value: state.isCacheServersEnabled,
                  onChanged: (value) =>
                      widget.repoCubit.setCacheServersEnabled(value),
                ),
              EntryActionItem(
                iconData: Icons.edit_outlined,
                title: S.current.actionRename,
                dense: true,
                onTap: () async {
                  final newName = await renameRepository(
                    context,
                    reposCubit: widget.reposCubit,
                    location: widget.repoCubit.location,
                  );

                  if (newName.isNotEmpty) {
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
                  await shareRepository(context, repository: widget.repoCubit);
                },
              ),
              EntryActionItem(
                iconData: Icons.password_outlined,
                title: S.current.titleSecurity,
                dense: true,
                onTap: () async => await navigateToRepositorySecurity(
                  context,
                  settings: widget.settings,
                  session: widget.session,
                  repoCubit: widget.repoCubit,
                  passwordHasher: widget.reposCubit.passwordHasher,
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
              EntryActionItem(
                iconData: Icons.snippet_folder_outlined,
                title: S.current.actionLocateRepo,
                dense: true,
                onTap: () async => await locateRepository(
                  context,
                  repoLocation: widget.repoCubit.location,
                  windows: Platform.isWindows,
                ),
              ),
              EntryActionItem(
                iconData: Icons.delete_outline,
                title: S.current.actionDelete,
                dense: true,
                isDanger: true,
                onTap: () async {
                  final repoName = widget.repoCubit.name;
                  final location = widget.repoCubit.location;

                  final deleted = await showDeleteRepositoryDialog(
                    context,
                    reposCubit: widget.reposCubit,
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
