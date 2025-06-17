import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show ReposCubit;
import '../../models/repo_entry.dart';
import '../../utils/utils.dart' show AppLogger, Dimensions, Fields;

class RepoListActions extends StatelessWidget with AppLogger {
  RepoListActions({
    required this.context,
    required this.reposCubit,
    required this.onCreateRepoPressed,
    required this.onImportRepoPressed,
  });

  final BuildContext context;
  final ReposCubit reposCubit;

  final Future<RepoEntry?> Function() onCreateRepoPressed;
  final Future<List<RepoEntry>> Function() onImportRepoPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Fields.bottomSheetHandle(context),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAction(
                name: S.current.actionNewRepo,
                icon: Icons.archive_outlined,
                action: () async {
                  final location = await onCreateRepoPressed();

                  if (location == null) {
                    return;
                  }

                  await Navigator.of(context).maybePop();
                },
              ),
              _buildAction(
                name: S.current.actionImportRepo,
                icon: Icons.unarchive_outlined,
                action: () async {
                  final locations = await onImportRepoPressed();

                  if (locations.isEmpty) {
                    return;
                  }

                  await Navigator.of(context).maybePop();
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildAction({name, icon, action}) => Padding(
    padding: Dimensions.paddingBottomSheetActions,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: action,
      child: Column(
        children: [
          Icon(icon, size: Dimensions.sizeIconBig),
          Dimensions.spacingVertical,
          Text(name),
        ],
      ),
    ),
  );
}
