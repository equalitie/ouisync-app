import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositorySettings extends StatefulWidget {
  const RepositorySettings(
      {required this.context,
      required this.cubit,
      required this.reposCubit,
      required this.settings});

  final BuildContext context;
  final RepoCubit cubit;
  final ReposCubit reposCubit;

  final Settings settings;

  @override
  State<RepositorySettings> createState() => _RepositorySettingsState();
}

class _RepositorySettingsState extends State<RepositorySettings>
    with AppLogger, RepositoryActionsMixin {
  @override
  Widget build(BuildContext context) => BlocBuilder<RepoCubit, RepoState>(
        bloc: widget.cubit,
        builder: (context, state) => SingleChildScrollView(
            child: Container(
                padding: Dimensions.paddingBottomSheet,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Fields.bottomSheetHandle(context),
                      Fields.bottomSheetTitle(widget.cubit.name,
                          style: context.theme.appTextStyle.titleMedium),
                      Row(children: [
                        Expanded(
                            child: SwitchListTile.adaptive(
                          title: Text(S.current.labelBitTorrentDHT,
                              style: context.theme.appTextStyle.bodyMedium),
                          secondary: const Icon(
                            Icons.hub,
                            size: Dimensions.sizeIconMicro,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity(horizontal: -4.0),
                          value: state.isDhtEnabled,
                          onChanged: (value) =>
                              widget.cubit.setDhtEnabled(value),
                        )),
                      ]),
                      Row(children: [
                        Expanded(
                            child: SwitchListTile.adaptive(
                          title: Text(S.current.messagePeerExchange,
                              style: context.theme.appTextStyle.bodyMedium),
                          secondary: const Icon(
                            Icons.group_add,
                            size: Dimensions.sizeIconMicro,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity(horizontal: -4.0),
                          value: state.isPexEnabled,
                          onChanged: (value) =>
                              widget.cubit.setPexEnabled(value),
                        ))
                      ]),
                      EntryActionItem(
                          iconData: Icons.edit,
                          title: S.current.actionRename,
                          dense: true,
                          onTap: () async => await renameRepository(
                              widget.context,
                              repository: widget.cubit,
                              reposCubit: widget.reposCubit,
                              popDialog: () => Navigator.of(context).pop())),
                      EntryActionItem(
                          iconData: Icons.share,
                          title: S.current.actionShare,
                          dense: true,
                          onTap: () async {
                            Navigator.of(context).pop();
                            await shareRepository(context,
                                repository: widget.cubit);
                          }),
                      EntryActionItem(
                          iconData: Icons.password,
                          title: S.current.titleSecurity,
                          dense: true,
                          onTap: () async => await navigateToRepositorySecurity(
                                context,
                                repository: widget.cubit,
                                settings: widget.settings,
                                popDialog: () => Navigator.of(context).pop(),
                              )),
                      EntryActionItem(
                          iconData: Icons.delete,
                          title: S.current.actionDelete,
                          dense: true,
                          isDanger: true,
                          onTap: () async => await deleteRepository(context,
                              repositoryLocation: widget.cubit.location,
                              settings: widget.settings,
                              reposCubit: widget.reposCubit,
                              popDialog: () => Navigator.of(context).pop()))
                    ]))),
      );
}
