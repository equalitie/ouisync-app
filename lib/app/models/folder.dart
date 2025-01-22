import 'dart:async';

import 'package:equatable/equatable.dart';

import '../cubits/cubits.dart' show RepoCubit, SortBy, SortDirection;
import '../utils/repo_path.dart' as repo_path;
import '../utils/utils.dart' show Strings;

class FolderState extends Equatable {
  final String path;
  final List<FileSystemEntry> content;
  final SortBy sortBy;
  final SortDirection sortDirection;

  const FolderState({
    this.path = Strings.root,
    this.content = const [],
    this.sortBy = SortBy.name,
    this.sortDirection = SortDirection.asc,
  });

  bool get isRoot => path == Strings.root;
  String get parent => repo_path.dirname(path);

  @override
  List<Object?> get props => [path, content, sortBy, sortDirection];
}

sealed class FileSystemEntry extends Equatable {
  const FileSystemEntry({required this.path});

  final String path;

  String get name => repo_path.basename(path);
}

class FileEntry extends FileSystemEntry {
  const FileEntry({required super.path, required this.size});

  // null means size unknown due to the file not being downloaded yet.
  final int? size;

  @override
  List<Object?> get props => [path, size];
}

class DirectoryEntry extends FileSystemEntry {
  const DirectoryEntry({required super.path});

  @override
  List<Object?> get props => [path];
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
      unawaited(_runner(
        sortBy: sortBy,
        sortDirection: sortDirection,
      ));
    }

    return future;
  }

  Future<void> _runner({SortBy? sortBy, SortDirection? sortDirection}) async {
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
              content.sort(_sortByName(sortDirection ?? SortDirection.asc));
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

  int Function(FileSystemEntry, FileSystemEntry)? _sortByName(
    SortDirection direction,
  ) {
    return direction == SortDirection.asc
        ? (a, b) => _nameComparator(a, b)
        : (b, a) => _nameComparator(a, b);
  }

  int _nameComparator(FileSystemEntry a, FileSystemEntry b) {
    final nameResult = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (nameResult != 0) {
      if (a is FileEntry && b is DirectoryEntry) return 1;
      if (a is DirectoryEntry && b is FileEntry) return -1;
    }

    return nameResult;
  }

  int Function(FileSystemEntry, FileSystemEntry)? _sortBySize(
      SortDirection direction) {
    return direction == SortDirection.asc
        ? (a, b) => _sizeComparator(a, b)
        : (b, a) => _sizeComparator(a, b);
  }

  int _sizeComparator(FileSystemEntry a, FileSystemEntry b) => switch ((a, b)) {
        (FileEntry(size: final sa), FileEntry(size: final sb)) =>
          _sizeNameComparator((sa ?? 0).compareTo(sb ?? 0), a, b),
        (FileEntry(), DirectoryEntry()) => 1,
        (DirectoryEntry(), FileEntry()) => -1,
        (DirectoryEntry(), DirectoryEntry()) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };

  int _sizeNameComparator(
          int sizeResult, FileSystemEntry a, FileSystemEntry b) =>
      sizeResult == 0
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : sizeResult;

  int Function(FileSystemEntry, FileSystemEntry)? _sortByType(
      SortDirection direction) {
    return direction == SortDirection.asc
        ? (a, b) => _typeComparator(a, b)
        : (b, a) => _typeComparator(a, b);
  }

  int _typeComparator(FileSystemEntry a, FileSystemEntry b) => switch ((a, b)) {
        (FileEntry(), FileEntry()) ||
        (DirectoryEntry(), DirectoryEntry()) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        (DirectoryEntry(), FileEntry()) => -1,
        (FileEntry(), DirectoryEntry()) => 1,
      };
}
