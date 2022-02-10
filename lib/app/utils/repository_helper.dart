import 'dart:io' as io;

import 'utils.dart';

class RepositoryHelper {
  RepositoryHelper._();

  static List<dynamic> localRepositoriesFiles(String location, {
    bool justNames = true
  }) { 
    if (!io.Directory(location).existsSync()) {
      return <String>[];
    }

    final repositoryFiles = io.Directory(location)
    .listSync();

    if (!justNames) {
      return repositoryFiles;
    }

    return repositoryFiles
    .map((e) {
      final name = removeParentFromPath(e.path);
      return name.substring(0, name.lastIndexOf('.'));
    }).toSet().toList();
  }

  static Future<String> latestRepositoryOrDefault(List<String>? localRepositories) async {
    if (localRepositories == null) {
      final repositoriesDir = await Settings.readSetting(Constants.repositoriesDirKey);
      localRepositories = localRepositoriesFiles(repositoriesDir) as List<String>;
    }

    if (localRepositories.isEmpty) {
      return '';
    }

    final defaultRepository = localRepositories.first;
    final latestRepository = await Settings.readSetting(Constants.currentRepositoryKey);

    if (latestRepository == null) {
      return defaultRepository;
    }
    if (!localRepositories.contains(latestRepository)) {
      return defaultRepository;
    }

    return latestRepository;
  }
}