import './repo_state.dart';
import './item/base_item.dart';
import '../utils/strings.dart';
import '../utils/actions.dart';

import 'package:collection/collection.dart';

class FolderState {
  late final RepoState repo;
  String path = Strings.root;

  List<BaseItem> content = <BaseItem>[];

  FolderState();

  bool isRoot() {
    return path == Strings.root;
  }

  void goUp() {
    path = getParentSection(path);
  }

  void goTo(String path) {
    this.path = path;
  }

  Future<void> refresh() async {
    content = await repo.getFolderContents(path);
    content.sort((a, b) => a.type.index.compareTo(b.type.index));
  }
}
