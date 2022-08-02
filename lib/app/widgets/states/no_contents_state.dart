import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../../cubits/repo/cubit.dart';

class NoContentsState extends StatelessWidget {
  const NoContentsState({
    Key? key,
    required this.repository,
    required this.path,
  }) : super(key: key);

  final RepoState repository;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        reverse: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Fields.inPageMainMessage(
                path.isEmpty
                  ? S.current.messageEmptyRepo
                  : S.current.messageEmptyFolder,
              ),
            ),
            Dimensions.spacingVertical,
            Align(
              alignment: Alignment.center,
              child: Fields.inPageSecondaryMessage(
                repository.accessMode == oui.AccessMode.write
                  ? S.current.messageCreateAddNewItem
                  : S.current.messageReadOnlyContents,
                tags: {
                  Constants.inlineTextBold: InlineTextStyles.bold,
                  Constants.inlineTextIcon: InlineTextStyles.icon(
                    Icons.add_circle,
                    size: Dimensions.sizeIconBig,
                    color: Theme.of(context).primaryColor
                  )
                }
              ),
            ),
          ],
        )
      )
    );
  }
}
