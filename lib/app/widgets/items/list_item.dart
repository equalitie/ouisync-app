import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FileListItem extends StatelessWidget {
  FileListItem({
    super.key,
    required this.entry,
    required this.repoCubit,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final FileEntry entry;
  final RepoCubit repoCubit;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  @override
  Widget build(BuildContext context) {
    // TODO: should this be inside of a BlockBuilder of fileItem.repoCubit?

    final uploadJob = repoCubit.state.uploads[entry.path];
    final downloadJob = repoCubit.state.downloads[entry.path];

    return _ListItemContainer(
      mainAction: mainAction,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FileIconAnimated(downloadJob),
          Expanded(
            child: Container(
              padding: Dimensions.paddingItem,
              child: FileDescription(repoCubit, entry, uploadJob),
            ),
          ),
          _VerticalDotsButton(uploadJob == null ? verticalDotsAction : null),
        ],
      ),
    );
  }
}

class DirectoryListItem extends StatelessWidget {
  DirectoryListItem({
    super.key,
    required this.entry,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final DirectoryEntry entry;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  @override
  Widget build(BuildContext context) => _ListItemContainer(
        mainAction: mainAction,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_rounded,
              size: Dimensions.sizeIconAverage,
              color: Constants.folderIconColor,
            ),
            Expanded(
              child: Container(
                padding: Dimensions.paddingItem,
                child: ScrollableTextWidget(child: Text(entry.name)),
              ),
            ),
            _VerticalDotsButton(verticalDotsAction),
          ],
        ),
      );
}

class RepoListItem extends StatelessWidget {
  RepoListItem({
    super.key,
    required this.repoCubit,
    required this.isDefault,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final RepoCubit repoCubit;
  final bool isDefault;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  @override
  Widget build(BuildContext context) => _ListItemContainer(
        mainAction: mainAction,
        child: BlocBuilder<RepoCubit, RepoState>(
          bloc: repoCubit,
          builder: (context, state) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                key: Key('access-mode-button'),
                icon: Icon(
                  Fields.accessModeIcon(state.accessMode),
                  size: Dimensions.sizeIconAverage,
                ),
                color: Constants.folderIconColor,
                padding: EdgeInsets.all(0.0),
                onPressed: () => repoCubit.lock(),
              ),
              Expanded(
                child: Container(
                  padding: Dimensions.paddingItem,
                  child: RepoDescription(
                    state,
                    isDefault: isDefault,
                  ),
                ),
              ),
              RepoStatus(repoCubit),
              _VerticalDotsButton(verticalDotsAction),
            ],
          ),
        ),
      );
}

class MissingRepoListItem extends StatelessWidget {
  MissingRepoListItem({
    super.key,
    required this.location,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final RepoLocation location;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  @override
  Widget build(BuildContext context) => _ListItemContainer(
        mainAction: mainAction,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Icon(
                Icons.error_outline_rounded,
                size: Dimensions.sizeIconAverage,
                color: Constants.folderIconColor,
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: Dimensions.paddingItem,
                child: MissingRepoDescription(location.name),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                size: Dimensions.sizeIconMicro,
                color: Constants.dangerColor,
              ),
              onPressed: () => verticalDotsAction(),
            )
          ],
        ),
      );
}

class _ListItemContainer extends StatelessWidget {
  _ListItemContainer({
    required this.child,
    required this.mainAction,
  });

  final Widget child;
  final Function mainAction;

  @override
  Widget build(BuildContext context) => Material(
        child: InkWell(
            onTap: () => mainAction.call(),
            splashColor: Colors.blue,
            child: Container(
              padding: Dimensions.paddingListItem,
              child: child,
            )),
        color: Colors.white,
      );
}

class _VerticalDotsButton extends StatelessWidget {
  _VerticalDotsButton(this.action);

  final void Function()? action;

  @override
  Widget build(BuildContext context) => IconButton(
        key: ValueKey('file_vert'),
        icon: const Icon(
          Icons.more_vert_rounded,
          size: Dimensions.sizeIconSmall,
        ),
        onPressed: action,
      );
}
