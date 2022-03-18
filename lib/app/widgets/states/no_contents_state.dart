import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../utils/utils.dart';

class NoContentsState extends StatelessWidget {
  const NoContentsState({
    Key? key,
    required this.repository,
    required this.path,
  }) : super(key: key);

  final Repository repository;
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
                ? Strings.messageEmptyRepo
                : Strings.messageEmptyFolder,
              ),
            ),
            Dimensions.spacingVertical,
            Align(
              alignment: Alignment.center,
              child: Fields.inPageSecondaryMessage(
                repository.accessMode == AccessMode.write
                ? Strings.messageCreateAddNewItem
                : Strings.messageReadOnlyContents,
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
