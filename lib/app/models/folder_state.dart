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

  String get parent => getParentSection(path);

  void goUp() {
    path = parent;
  }

  void goTo(String path) {
    if (path != this.path) {
      content.clear();
      this.path = path;
    }
  }

  // Returns true if the directory existed.
  Future<bool> refresh() => _refresher.refresh();
}

// This class helps piling up of too many calls to refresh. It does so by first
// starting a refresh operation, and if there are other N that are requested
// before the first one finishes, only one is scheduled to be done afterwards.
class _Refresher {
  late final FolderState folder;

  bool _running = false;
  bool _hasNextJob = false;

  List<Completer> _completers = <Completer>[];

  Future<bool> refresh() async {
    final completer = Completer<bool>();
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

        // Remember which path we're getting the content for to avoid claiming
        // another folder has that content.
        final path = folder.path;

        bool success = true;

        try {
          final content = await folder.repo.getFolderContents(path);
          content.sort((a, b) => a.type.index.compareTo(b.type.index));

          if (path == folder.path) {
            folder.content = content;
          }
        } catch(_) {
          if (path == folder.path) {
            folder.content.clear();
          }
          success = false;
        }

        for (var completer in completers) {
          completer.complete(success);
        }
      }
    } finally {
      _running = false;
    }
  }
}