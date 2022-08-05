import 'package:equatable/equatable.dart';

import '../models.dart';

class FileItem extends BaseItem implements Equatable {
  FileItem({
    required String name,
    required String path,
    required this.size,
  }) : super(name, path);

  int size;

  @override
  ItemType get type => ItemType.file;
}
