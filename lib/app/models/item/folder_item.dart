import 'package:equatable/equatable.dart';

import '../models.dart';

class FolderItem extends BaseItem implements Equatable {
  FolderItem({
    required String name,
    required String path,
  }): super(name, path);

  @override
  ItemType get type => ItemType.folder;
}
