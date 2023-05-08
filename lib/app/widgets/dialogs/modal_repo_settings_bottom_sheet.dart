import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/repo_actions_mixin.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class RepositorySettings extends StatefulWidget {
  const RepositorySettings(
      {required this.context,
      required this.cubit,
      required this.data,
      required this.checkForBiometrics,
      required this.getAuthenticationMode,
      required this.renameRepository,
      required this.deleteRepository});

  final BuildContext context;
  final RepoCubit cubit;
  final RepoItem data;

  final Future<bool?> Function() checkForBiometrics;
  final String? Function(String repoName) getAuthenticationMode;
  final Future<void> Function(
      String oldName, String newName, Uint8List reopenToken) renameRepository;
  final Future<void> Function(RepoMetaInfo info, String authMode)
      deleteRepository;

  @override
  State<RepositorySettings> createState() => _RepositorySettingsState();
}

class _RepositorySettingsState extends State<RepositorySettings>
    with RepositoryActionsMixin {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      child: Container(
          padding: Dimensions.paddingBottomSheet,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Fields.bottomSheetHandle(context),
                Fields.bottomSheetTitle(widget.cubit.name),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Fields.actionListTile(S.current.actionRename,
                            textFontSize: Dimensions.fontAverage,
                            textOverflow: TextOverflow.ellipsis,
                            textSoftWrap: false,
                            onTap: () async => await renameRepository(
                                widget.context,
                                repository: widget.cubit,
                                rename: widget.renameRepository,
                                popDialog: () => Navigator.of(context).pop()),
                            icon: Icons.edit,
                            iconSize: Dimensions.sizeIconMicro,
                            iconColor: Colors.black87,
                            textColor: Colors.black87,
                            dense: true,
                            visualDensity: VisualDensity.compact)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Fields.actionListTile(S.current.actionShare,
                            textFontSize: Dimensions.fontAverage,
                            textOverflow: TextOverflow.ellipsis,
                            textSoftWrap: false, onTap: () async {
                      Navigator.of(context).pop();
                      await shareRepository(context, repository: widget.cubit);
                    },
                            icon: Icons.share,
                            iconSize: Dimensions.sizeIconMicro,
                            iconColor: Colors.black87,
                            textColor: Colors.black87,
                            dense: true,
                            visualDensity: VisualDensity.compact)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Fields.actionListTile(S.current.titleSecurity,
                            textFontSize: Dimensions.fontAverage,
                            textOverflow: TextOverflow.ellipsis,
                            textSoftWrap: false,
                            onTap: () async =>
                                await navigateToRepositorySecurity(
                                  context,
                                  repository: widget.cubit,
                                  checkForBiometrics: widget.checkForBiometrics,
                                  getAuthenticationMode:
                                      widget.getAuthenticationMode,
                                  popDialog: () => Navigator.of(context).pop(),
                                ),
                            icon: Icons.password,
                            iconSize: Dimensions.sizeIconMicro,
                            iconColor: Colors.black87,
                            textColor: Colors.black87,
                            dense: true,
                            visualDensity: VisualDensity.compact)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Fields.actionListTile(S.current.actionDelete,
                            textFontSize: Dimensions.fontAverage,
                            textOverflow: TextOverflow.ellipsis,
                            textSoftWrap: false,
                            onTap: () async => await deleteRepository(context,
                                repositoryName: widget.cubit.name,
                                repositoryMetaInfo: widget.cubit.metaInfo,
                                getAuthenticationMode:
                                    widget.getAuthenticationMode,
                                delete: widget.deleteRepository,
                                popDialog: () => Navigator.of(context).pop()),
                            icon: Icons.delete,
                            iconSize: Dimensions.sizeIconMicro,
                            iconColor: Constants.dangerColor,
                            textColor: Constants.dangerColor,
                            dense: true,
                            visualDensity: VisualDensity.compact)),
                  ],
                )
              ])));
}
