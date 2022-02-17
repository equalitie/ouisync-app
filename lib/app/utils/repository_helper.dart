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

  static Future<bool> renameRepositoryFiles(String repositoriesDir, {
    required String oldName,
    required String newName
  }) async {
    if (!io.Directory(repositoriesDir).existsSync()) {
      return false;
    }

    final repositoryFiles = [
      '$repositoriesDir/$oldName.db',
      '$repositoriesDir/$oldName.db-wal',
      '$repositoriesDir/$oldName.db-shm'
    ];

    final repositoryFilesIterator = io.Directory(repositoriesDir)
    .listSync()
    .where((element) => 
      repositoryFiles.contains(element.path)
    );

    for (var entity in repositoryFilesIterator) {
      entity.path.endsWith('.db-shm')
      ? entity.rename('$repositoriesDir/$newName.db-shm')
      : entity.path.endsWith('.db-wal')
      ? entity.rename('$repositoriesDir/$newName.db-wal')
      : entity.rename('$repositoriesDir/$newName.db');
    }

    return true;
  }

  static Future<bool> deleteRepositoryFiles(String repositoriesDir, {
    required String repositoryName
  }) async {
    if (!io.Directory(repositoriesDir).existsSync()) {
      return false;
    }

    final repositoryFiles = [
      '$repositoriesDir/$repositoryName.db',
      '$repositoriesDir/$repositoryName.db-wal',
      '$repositoriesDir/$repositoryName.db-shm'
    ];

    io.Directory(repositoriesDir)
    .listSync()
    .where((element) => repositoryFiles.contains(element.path))
    .forEach((element) => element.deleteSync());

    return true;
  }
}