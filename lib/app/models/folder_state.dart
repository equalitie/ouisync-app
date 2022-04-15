import 'dart:async';

import './repo_state.dart';
import './item/base_item.dart';
import '../utils/strings.dart';
import '../utils/actions.dart';

import 'package:collection/collection.dart';

class FolderState {
  late final RepoState repo;
  String path = Strings.root;

  List<BaseItem> content = <BaseItem>[];
  _Refresher _refresher = _Refresher();

  FolderState() {
    _refresher.folder = this;
  }

  bool isRoot() {
    return path == Strings.root;
  }

  void goUp() {
    path = getParentSection(path);
  }

  void goTo(String path) {
    this.path = path;
  }

  Future<void> refresh() => _refresher.refresh();
}

// This class helps piling up of too many calls to refresh. It does so by first
// starting a refresh operation, and if there are other N that are requested
// before the first one finishes, only one is scheduled to be done afterwards.
class _Refresher {
  late final FolderState folder;

  bool _running = false;
  bool _hasNextJob = false;

  List<Completer> _completers = <Completer>[];

  Future<void> refresh() async {
    final completer = Completer<void>();
    final future = completer.future;
    _completers.add(completer);

    _hasNextJob = true;

    if (!_running) {
      _running = true;
      _runner(); // Spawn, don't await
    }

    return future;
  }

  void _runner() async {
    try {
      while (_hasNextJob) {
        _hasNextJob = false;

        final completers = _completers;
        _completers = <Completer>[];

        final content = await folder.repo.getFolderContents(folder.path);
        content.sort((a, b) => a.type.index.compareTo(b.type.index));
        folder.content = content;

        for (var completer in completers) {
          completer.complete();
        }
      }
    } finally {
      _running = false;
    }
  }
}
