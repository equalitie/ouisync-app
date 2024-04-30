import 'package:path/path.dart' as p;
import 'dart:io' as io;

// Information about a repository that we can deduce without opening it.
class RepoLocation implements Comparable<RepoLocation> {
  static const defaultExtension = ".ouisyncdb";
  static const defaultExtensionWithoutDot = "ouisyncdb";
  static const legacyExtensionWithoutDot = "db";

  final String _dir;
  final String _name; // Repo name (file name without the extension)
  final String _ext;

  RepoLocation._(this._dir, this._name, this._ext);

  static RepoLocation fromDbPath(String pathToDbFile) {
    return RepoLocation._(p.dirname(pathToDbFile),
        p.basenameWithoutExtension(pathToDbFile), p.extension(pathToDbFile));
  }

  static RepoLocation fromDirAndName(io.Directory dir, String repoName) {
    return RepoLocation._(dir.path, repoName, defaultExtension);
  }

  String get name => _name;
  String get path => p.join(_dir, "$_name$_ext");
  String get pathWithoutExtension => p.join(_dir, _name);

  io.Directory get dir => io.Directory(_dir);

  RepoLocation rename(String newName) => RepoLocation._(_dir, newName, _ext);

  RepoLocation move(io.Directory newDir) =>
      RepoLocation._(newDir.path, _name, _ext);

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
}
