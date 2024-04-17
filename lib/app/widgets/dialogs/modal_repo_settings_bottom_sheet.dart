import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../utils/utils.dart';
import '../repo_status.dart';
import '../widgets.dart';

class RepositorySettings extends StatefulWidget {
  const RepositorySettings({
    required this.context,
    required this.settings,
    required this.repoCubit,
    required this.reposCubit,
  });

  final BuildContext context;
  final Settings settings;
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
        builder: (context, state) => SingleChildScrollView(
            child: Container(
                padding: Dimensions.paddingBottomSheet,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Fields.bottomSheetHandle(context),
                      Row(
                        children: [
                          Fields.bottomSheetTitle(
                            widget.repoCubit.name,
                            style: context.theme.appTextStyle.titleMedium,
                          ),
                          Spacer(),
                          _Progress(widget.repoCubit),
                        ],
                      ),
                      _SwitchItem(
                        title: S.current.labelBitTorrentDHT,
                        icon: Icons.hub,
                        value: state.isDhtEnabled,
                        onChanged: (value) =>
                            widget.repoCubit.setDhtEnabled(value),
                      ),
                      _SwitchItem(
                        title: S.current.messagePeerExchange,
                        icon: Icons.group_add,
                        value: state.isPexEnabled,
                        onChanged: (value) =>
                            widget.repoCubit.setPexEnabled(value),
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
                          iconData: Icons.edit,
                          title: S.current.actionRename,
                          dense: true,
                          onTap: () async => await renameRepository(context,
                              repository: widget.repoCubit,
                              reposCubit: widget.reposCubit,
                              popDialog: () => Navigator.of(context).pop())),
                      EntryActionItem(
                          iconData: Icons.share,
                          title: S.current.actionShare,
                          dense: true,
                          onTap: () async {
                            Navigator.of(context).pop();
                            await shareRepository(context,
                                repository: widget.repoCubit);
                          }),
                      EntryActionItem(
                          iconData: Icons.password,
                          title: S.current.titleSecurity,
                          dense: true,
                          onTap: () async => await navigateToRepositorySecurity(
                                context,
                                settings: widget.settings,
                                repoCubit: widget.repoCubit,
                                passwordHasher:
                                    widget.reposCubit.passwordHasher,
                                popDialog: () => Navigator.of(context).pop(),
                              )),
                      //// TODO: Removed the eject button for now until the
                      //// next release and after team discussion on where to
                      //// best put it and how to explain the use case to the
                      //// user.
                      ///
                      //// Only allow forgetting/ejecting a repository if the app
                      //// is not storing the secret for the user.
                      //if (!widget.cubit.repoSettings.hasLocalSecret())
                      //  EntryActionItem(
                      //      iconData: Icons.eject,
                      //      title: S.current.actionEject,
                      //      dense: true,
                      //      onTap: () async {
                      //        await widget.reposCubit
                      //            .ejectRepository(widget.cubit.location);
                      //        Navigator.of(context).pop();
                      //      }),
                      EntryActionItem(
                          iconData: Icons.delete,
                          title: S.current.actionDelete,
                          dense: true,
                          isDanger: true,
                          onTap: () async => await deleteRepository(context,
                              repoLocation: widget.repoCubit.location,
                              reposCubit: widget.reposCubit,
                              popDialog: () => Navigator.of(context).pop()))
                    ]))),
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
        contentPadding: EdgeInsets.zero,
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
          'Synced: ${_formatProgress(progress)}',
        ),
      );
}

String _formatProgress(Progress progress) {
  final value =
      (progress.fraction * 100.0).truncateToDouble().toStringAsFixed(0);
  return '$value%';
}
