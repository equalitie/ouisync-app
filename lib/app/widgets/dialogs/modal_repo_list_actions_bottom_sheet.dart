import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class RepoListActions extends StatelessWidget with OuiSyncAppLogger {
  const RepoListActions(
      {required this.context,
      required this.reposCubit,
      required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed});

  final BuildContext context;
  final ReposCubit reposCubit;

  final Future<String?> Function() onNewRepositoryPressed;
  final Future<String?> Function() onImportRepositoryPressed;

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
                name: S.current.actionNewRepo,
                icon: Icons.archive_outlined,
                action: () async {
                  final newRepoName = await onNewRepositoryPressed.call();

                  if (newRepoName == null) {
                    return;
                  }

                  Navigator.of(context).pop();
                }),
            _buildAction(
                name: S.current.actionImportRepo,
                icon: Icons.unarchive_outlined,
                action: () async {
                  final importedRepoName =
                      await onImportRepositoryPressed.call();

                  if (importedRepoName == null) {
                    return;
                  }

                  Navigator.of(context).pop();
                })
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
}
