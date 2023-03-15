import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class RepoListActions extends StatelessWidget with OuiSyncAppLogger {
  const RepoListActions(
      {required this.context,
      required this.reposCubit,
      required this.onNewRepositoryPressed,
      required this.onAddRepositoryPressed});

  final BuildContext context;
  final ReposCubit reposCubit;

  final Future<String?> Function() onNewRepositoryPressed;
  final Future<String?> Function() onAddRepositoryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(context),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildAction(
                name: 'Create repository',
                icon: Icons.archive_outlined,
                action: () async =>
                    await _addRepoAndNavigate(context, onNewRepositoryPressed)),
            _buildAction(
                name: 'Import repository',
                icon: Icons.unarchive_outlined,
                action: () async =>
                    await _addRepoAndNavigate(context, onAddRepositoryPressed))
          ]),
        ]);
  }

  Widget _buildAction({name, icon, action}) => Padding(
      padding: Dimensions.paddingBottomSheetActions,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action,
          child: Column(children: [
            Icon(icon, size: Dimensions.sizeIconBig),
            Dimensions.spacingVertical,
            Text(name, style: const TextStyle(fontSize: Dimensions.fontSmall))
          ])));

  Future<void> _addRepoAndNavigate(
      BuildContext context, Future<String?> Function() repoFunction) async {
    final newRepoName = await repoFunction.call();

    if (newRepoName == null || newRepoName.isEmpty) {
      return;
    }

    Navigator.of(context).pop(newRepoName);

    await reposCubit.setCurrentByName(newRepoName);
    reposCubit.pushRepoList(false);
  }
}
