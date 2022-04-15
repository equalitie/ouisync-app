import './repo_state.dart';
import './item/base_item.dart';
import '../utils/strings.dart';

class FolderState {
  late RepoState repo;
  String path = Strings.root;
  List<BaseItem> content = <BaseItem>[];

  FolderState();
}
