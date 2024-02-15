import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'dart:io' as io;

// Information about a repository that we can deduce without opening it.
class RepoLocation extends Equatable implements Comparable<RepoLocation> {
  static const defaultExtension = ".ouisyncdb";

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

  String path() {
    return p.join(_dir, "$_name$_ext");
  }

  String pathWithoutExt() {
    return p.join(_dir, _name);
  }

  String get name => _name;

  io.Directory get dir => io.Directory(_dir);

  RepoLocation rename(String newName) => RepoLocation._(_dir, newName, _ext);

  @override
  List<Object> get props => [
        _dir,
        _name,
        _ext,
      ];

  // Comparing by name first.
  @override
  int compareTo(RepoLocation other) =>
      "$_name$_ext$_dir".compareTo("${other._name}${other._ext}${other._dir}");
}
