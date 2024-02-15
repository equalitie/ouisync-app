import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';

class RepoListActions extends StatelessWidget with AppLogger {
  RepoListActions(
      {required this.context,
      required this.reposCubit,
      required this.onNewRepositoryPressed,
      required this.onImportRepositoryPressed});

  final BuildContext context;
  final ReposCubit reposCubit;

  final Future<RepoLocation?> Function() onNewRepositoryPressed;
  final Future<RepoLocation?> Function() onImportRepositoryPressed;

  @override
  Widget build(BuildContext context) => Column(
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
                    final newRepoLocation = await onNewRepositoryPressed.call();

                    if (newRepoLocation == null) {
                      return;
                    }

                    Navigator.of(context).pop();
                  }),
              _buildAction(
                  name: S.current.actionImportRepo,
                  icon: Icons.unarchive_outlined,
                  action: () async {
                    final importedRepoLocation =
                        await onImportRepositoryPressed.call();

                    if (importedRepoLocation == null) {
                      return;
                    }

                    Navigator.of(context).pop();
                  })
            ]),
          ]);

  Widget _buildAction({name, icon, action}) => Padding(
      padding: Dimensions.paddingBottomSheetActions,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action,
          child: Column(children: [
            Icon(icon, size: Dimensions.sizeIconBig),
            Dimensions.spacingVertical,
            Text(name)
          ])));
}
