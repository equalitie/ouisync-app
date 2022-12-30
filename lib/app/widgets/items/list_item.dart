import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    required this.repository,
    required this.itemData,
    required this.mainAction,
    required this.folderDotsAction,
  });

  final RepoCubit repository;
  final BaseItem itemData;
  final Function mainAction;
  final Function folderDotsAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
          onTap: () => mainAction.call(),
          splashColor: Colors.blue,
          child: Container(
            padding: Dimensions.paddingListItem,
            child: _buildItem(),
          )),
      color: Colors.white,
    );
  }

  Widget _buildItem() {
    final data = itemData;

    if (data is FileItem) {
      return _buildFileItem(data);
    }

    if (data is FolderItem) {
      return _buildFolderItem(data);
    }

    assert(false, "Item must be either FileItem or FolderItem");
    return SizedBox.shrink();
  }

  Widget _buildFileItem(FileItem fileData) {
    final uploadJob = repository.uploads[fileData.path];
    final downloadJob = repository.downloads[fileData.path];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(flex: 1, child: FileIconAnimated(downloadJob)),
        Expanded(
            flex: 9,
            child: Padding(
                padding: Dimensions.paddingItem,
                child: FileDescription(repository, fileData, uploadJob))),
        _getVerticalMenuAction(),
      ],
    );
  }

  Widget _buildFolderItem(FolderItem folderItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Expanded(
            flex: 1,
            child: Icon(Icons.folder_rounded,
                size: Dimensions.sizeIconAverage,
                color: Constants.folderIconColor)),
        Expanded(
            flex: 9,
            child: Padding(
                padding: Dimensions.paddingItem,
                child: FolderDescription(folderData: itemData))),
        _getVerticalMenuAction(),
      ],
    );
  }

  Widget _getVerticalMenuAction() {
    return IconButton(
        icon:
            const Icon(Icons.more_vert_rounded, size: Dimensions.sizeIconSmall),
        onPressed: () async => await folderDotsAction());
  }
}
