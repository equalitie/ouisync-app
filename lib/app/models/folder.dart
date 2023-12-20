import 'dart:async';

import 'package:equatable/equatable.dart';

import '../cubits/cubits.dart';
import '../utils/utils.dart';
import 'item.dart';

class FolderState extends Equatable {
  final String path;
  final List<BaseItem> content;
  final SortBy sortBy;
  final SortDirection sortDirection;

  const FolderState(
      {this.path = Strings.root,
      this.content = const [],
      this.sortBy = SortBy.name,
      this.sortDirection = SortDirection.desc});

  bool get isRoot => path == Strings.root;
  String get parent => getDirname(path);

  @override
  List<Object?> get props => [path, content, sortBy, sortDirection];
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
    repo.updateNavigation(isFolder: true);
  }

  void goTo(String path) {
    if (path != state.path) {
      state = FolderState(path: path);
      repo.updateNavigation(isFolder: true);
    }
  }

  // Returns true if the directory existed.
  Future<bool> refresh({SortBy? sortBy, SortDirection? sortDirection}) =>
      _refresher.refresh(sortBy: sortBy, sortDirection: sortDirection);
}

// This class helps piling up of too many calls to refresh. It does so by first
// starting a refresh operation, and if there are other N that are requested
// before the first one finishes, only one is scheduled to be done afterwards.
class _Refresher {
  late final Folder folder;

  bool _running = false;
  bool _hasNextJob = false;

  List<Completer> _completers = <Completer>[];

  Future<bool> refresh({SortBy? sortBy, SortDirection? sortDirection}) async {
    final completer = Completer<bool>();
    final future = completer.future;
    _completers.add(completer);

    _hasNextJob = true;

    if (!_running) {
      _running = true;
      _runner(
          sortBy: sortBy, sortDirection: sortDirection); // Spawn, don't await
    }

    return future;
  }

  void _runner({SortBy? sortBy, SortDirection? sortDirection}) async {
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

          switch (sortBy) {
            case SortBy.name:
              content.sort(_sortByName(sortDirection ?? SortDirection.asc));
              break;
            case SortBy.size:
              content.sort(_sortBySize(sortDirection ?? SortDirection.asc));
              break;
            case SortBy.type:
              content.sort(_sortByType(sortDirection ?? SortDirection.asc));
              break;
            default:
              content.sort(_sortByType(sortDirection ?? SortDirection.asc));
          }

          if (path == folder.state.path) {
            folder.state = FolderState(
                path: folder.state.path,
                content: content,
                sortBy: folder.state.sortBy,
                sortDirection: folder.state.sortDirection);
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

  int Function(BaseItem, BaseItem)? _sortByName(SortDirection direction) {
    return direction == SortDirection.asc
        ? (a, b) => _nameComparator(a, b)
        : (b, a) => _nameComparator(a, b);
  }

  int _nameComparator(BaseItem a, BaseItem b) => a.name.compareTo(b.name);

  int Function(BaseItem, BaseItem)? _sortBySize(SortDirection direction) {
    return direction == SortDirection.asc
        ? (a, b) => _sizeComparator(a, b)
        : (b, a) => _sizeComparator(a, b);
  }

  int _sizeComparator(BaseItem a, BaseItem b) =>
      (a.size ?? 0).compareTo(b.size ?? 0);

  int Function(BaseItem, BaseItem)? _sortByType(SortDirection direction) {
    return direction == SortDirection.asc
        ? (a, b) => _typeComparator(_typeId(a), _typeId(b))
        : (b, a) => _typeComparator(_typeId(a), _typeId(b));
  }

  int _typeComparator(int a, int b) => a.compareTo(b);

  int _typeId(BaseItem item) {
    if (item is FolderItem) return 0;
    if (item is FileItem) return 1;
    assert(false);
    return -1;
  }
}
