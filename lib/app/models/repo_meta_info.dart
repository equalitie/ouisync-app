import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

// Information about a repository that we can deduce without opening it.
class RepoMetaInfo extends Equatable {
  final String _dir;
  final String _name; // Repo name (without the '.db' extension)

  RepoMetaInfo(String pathToDbFile) :
    _dir = p.dirname(pathToDbFile),
    _name = p.basenameWithoutExtension(pathToDbFile);

  String path({ ext = "db" }) {
    return p.join(_dir, "$_name.$ext");
  }

  String get name => _name;

  @override
  List<Object> get props => [
    _dir,
    _name,
  ];
}
