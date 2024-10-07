import 'package:path/path.dart' as p;
import 'dart:io' as io;

// Information about a repository that we can deduce without opening it.
class RepoLocation implements Comparable<RepoLocation> {
  static const defaultExtension = "ouisyncdb";
  static const legacyExtension = "db";

  final String _dir;
  final String _name; // Repo name (file name without the extension)
  final String _ext;

  RepoLocation._(this._dir, this._name, this._ext);

  static RepoLocation fromDbPath(String pathToDbFile) {
    return RepoLocation._(
      p.dirname(pathToDbFile),
      p.basenameWithoutExtension(pathToDbFile),
      _trimLeadingDot(p.extension(pathToDbFile)),
    );
  }

  static RepoLocation fromParts({
    required io.Directory dir,
    required String name,
    String? extension,
  }) =>
      RepoLocation._(dir.path, name, extension ?? defaultExtension);

  String get name => _name;
  String get path => _addExtension(p.join(_dir, _name), _ext);

  io.Directory get dir => io.Directory(_dir);

  RepoLocation rename(String newName) => RepoLocation._(_dir, newName, _ext);

  RepoLocation move(io.Directory newDir) =>
      RepoLocation._(newDir.path, _name, _ext);

  RepoLocation clone() => RepoLocation._(_dir, _name, _ext);

  @override
  bool operator ==(Object other) =>
      other is RepoLocation && p.equals(path, other.path);

  @override
  int get hashCode => p.hash(path);

  /// Comparing by name first.
  @override
  int compareTo(RepoLocation other) {
    final byName = _name.compareTo(other._name);
    if (byName != 0) {
      return byName;
    }

    final byExt = _ext.compareTo(other._ext);
    if (byExt != 0) {
      return byExt;
    }

    return _dir.compareTo(other._dir);
  }

  @override
  String toString() => path;
}

String _trimLeadingDot(String s) => s.startsWith('.') ? s.substring(1) : s;

String _addExtension(String path, String ext) =>
    ext.isNotEmpty ? '$path.$ext' : path;
