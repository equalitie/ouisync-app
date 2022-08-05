import 'dart:io' as io;
import 'package:ouisync_app/app/utils/loggers/ouisync_app_logger.dart';
import 'package:path/path.dart' as p;


import 'utils.dart';

class RepositoryHelper {
  RepositoryHelper._();

  static Map<String, bool>? _dhtStatus;

  static final loggyInstance = OuiSyncAppLogger();

  static List<dynamic> localRepositoriesFiles(String location, {
    bool justNames = true
  }) { 
    if (!io.Directory(location).existsSync()) {
      return <String>[];
    }

    final repositoryFiles = io.Directory(location).listSync();

    if (!justNames) {
      return repositoryFiles;
    }

    return repositoryFiles.map((e) => p.basenameWithoutExtension(e.path)).toSet().toList();
  }

  static Future<String> latestRepositoryOrDefault(List<String> localRepositories) async {
    if (localRepositories.isEmpty) {
      return '';
    }

    final defaultRepository = localRepositories.first;
    final latestRepository = await Settings.getDefaultRepo();

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
      p.join(repositoriesDir, '$oldName.db'),
      p.join(repositoriesDir, '$oldName.db-wal'),
      p.join(repositoriesDir, '$oldName.db-shm'),
    ];

    final repositoryFilesIterator = io.Directory(repositoriesDir)
    .listSync()
    .where((element) => 
      repositoryFiles.contains(element.path)
    );

    try {
      for (var entity in repositoryFilesIterator) {
        final oldPath = entity.path;
        final renamed = p.extension(entity.path) == '.db-shm'
        ? await entity.rename(p.join(repositoriesDir, '$newName.db-shm'))
        : p.extension(entity.path) == '.db-wal'
        ? await entity.rename(p.join(repositoriesDir, '$newName.db-wal'))
        : await entity.rename(p.join(repositoriesDir, '$newName.db'));

        loggyInstance.loggy.app('File renamed: ${renamed.path} ($oldPath)');
      }  
    } catch (e, st) {
      loggyInstance.loggy.app('Exception when renaming repo $oldName files ($newName)', e, st);
      return false;
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
      p.join(repositoriesDir, '$repositoryName.db'),
      p.join(repositoriesDir, '$repositoryName.db-wal'),
      p.join(repositoriesDir, '$repositoryName.db-shm'),
    ];

    try {
      io.Directory(repositoriesDir)
      .listSync()
      .where((element) => repositoryFiles.contains(element.path))
      .forEach((element) {
        final path = element.path;
        element.deleteSync();
        
        loggyInstance.loggy.app('File deleted: $path');
      });  
    } catch (e, st) {
      loggyInstance.loggy.app('Exception when deleting repo $repositoryName files', e, st);
      return false;
    }
    
    return true;
  }
}
