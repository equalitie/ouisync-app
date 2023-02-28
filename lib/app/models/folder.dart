import 'dart:async';

import 'package:equatable/equatable.dart';

import 'item.dart';
import '../utils/strings.dart';
import '../utils/actions.dart';
import '../cubits/repo.dart';

class FolderState extends Equatable {
  final String path;
  final List<BaseItem> content;

  const FolderState({this.path = Strings.root, this.content = const []});

  bool get isRoot => path == Strings.root;
  String get parent => getDirname(path);

  @override
  List<Object?> get props => [path, content];
}

class Folder {
  FolderState state = FolderState();
  late final RepoCubit repo;
  final _Refresher _refresher = _Refresher();

  Folder() {
    _refresher.folder = this;
  }

  void goUp() {
    state = FolderState(path: state.parent, content: state.content);
  }

  void goTo(String path) {
    if (path != state.path) {
      state = FolderState(path: path);
    }
  }

  // Returns true if the directory existed.
  Future<bool> refresh() => _refresher.refresh();
}

// This class helps piling up of too many calls to refresh. It does so by first
// starting a refresh operation, and if there are other N that are requested
// before the first one finishes, only one is scheduled to be done afterwards.
class _Refresher {
  late final Folder folder;

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
        final path = folder.state.path;

        bool success = true;

        try {
          final content = await folder.repo.getFolderContents(path);
          content.sort((a, b) => _typeId(a).compareTo(_typeId(b)));

          if (path == folder.state.path) {
            folder.state =
                FolderState(path: folder.state.path, content: content);
          }
        } catch (_) {
          if (path == folder.state.path) {
            folder.state = FolderState(path: folder.state.path);
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

  int _typeId(BaseItem item) {
    if (item is FolderItem) return 0;
    if (item is FileItem) return 1;
    assert(false);
    return -1;
  }
}
