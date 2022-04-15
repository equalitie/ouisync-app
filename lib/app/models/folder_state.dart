import './repo_state.dart';
import './item/base_item.dart';
import '../utils/strings.dart';
import '../utils/actions.dart';

class FolderState {
  late final RepoState repo;
  String path = Strings.root;

  List<BaseItem> content = <BaseItem>[];

  FolderState();

  void goUp() {
    path = getParentSection(path);
  }
}
