import 'package:ouisync_plugin/ouisync_plugin.dart';

class RepositoriesService {
  static final RepositoriesService _instance = RepositoriesService._internal();

  Map<String, Repository>? _repositories;
  RepositoriesService._internal() {
    _repositories = <String, Repository>{};
  }

  factory RepositoriesService() => _instance;

  Map<String, Repository> get repositories => _repositories ?? <String, Repository>{};
  
  put(String name, Repository repository) => {
    _repositories?.putIfAbsent(name, () => repository) ?? <String, Repository>{}
  };
    
}