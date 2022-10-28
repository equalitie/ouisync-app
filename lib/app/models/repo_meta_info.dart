import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'dart:io' as io;

// Information about a repository that we can deduce without opening it.
class RepoMetaInfo extends Equatable {
  final String _dir;
  final String _name; // Repo name (without the '.db' extension)

  RepoMetaInfo._(this._dir, this._name);

  static RepoMetaInfo fromDbPath(String pathToDbFile) {
    return RepoMetaInfo._(
        p.dirname(pathToDbFile), p.basenameWithoutExtension(pathToDbFile));
  }

  static RepoMetaInfo fromDirAndName(io.Directory dir, String repoName) {
    return RepoMetaInfo._(dir.path, repoName);
  }

  String path({ext = "db"}) {
    return p.join(_dir, "$_name.$ext");
  }

  String get name => _name;

  io.Directory get dir => io.Directory(_dir);

  @override
  List<Object> get props => [
        _dir,
        _name,
      ];
}
