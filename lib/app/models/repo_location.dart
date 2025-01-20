import 'package:path/path.dart' as p;

// Information about a repository that we can deduce without opening it.
class RepoLocation implements Comparable<RepoLocation> {
  static const defaultExtension = "ouisyncdb";
  static const legacyExtension = "db";

  final String dir;
  final String name; // Repo name (file name without the extension)
  final String ext;

  RepoLocation({
    required this.dir,
    required this.name,
    this.ext = defaultExtension,
  });

  static RepoLocation fromDbPath(String pathToDbFile) => RepoLocation(
        dir: p.dirname(pathToDbFile),
        name: p.basenameWithoutExtension(pathToDbFile),
        ext: _trimLeadingDot(p.extension(pathToDbFile)),
      );

  String get path => _addExtension(p.join(dir, name), ext);

  RepoLocation rename(String newName) =>
      RepoLocation(dir: dir, name: newName, ext: ext);

  @override
  bool operator ==(Object other) =>
      other is RepoLocation && p.equals(path, other.path);

  @override
  int get hashCode => p.hash(path);

  /// Comparing by name first.
  @override
  int compareTo(RepoLocation other) {
    final byName = name.compareTo(other.name);
    if (byName != 0) {
      return byName;
    }

    final byExt = ext.compareTo(other.ext);
    if (byExt != 0) {
      return byExt;
    }

    return dir.compareTo(other.dir);
  }

  @override
  String toString() => path;
}

String _trimLeadingDot(String s) => s.startsWith('.') ? s.substring(1) : s;

String _addExtension(String path, String ext) =>
    ext.isNotEmpty ? '$path.$ext' : path;
