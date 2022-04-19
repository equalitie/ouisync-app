import 'dart:convert';
import 'dart:io' as io;
import 'package:ouisync_app/app/utils/loggers/ouisync_app_logger.dart';
import 'package:path/path.dart' as p;

import 'package:ouisync_plugin/ouisync_plugin.dart';

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

    final repositoryFiles = io.Directory(location)
    .listSync();

    if (!justNames) {
      return repositoryFiles;
    }

    return repositoryFiles
    .map((e) {
      loggyInstance.loggy.app('localRepositoriesFiles - basenameWithoutExtension: ${p.basenameWithoutExtension(e.path)}');
      return p.basenameWithoutExtension(e.path);
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

  static Future<void> setRepoBitTorrentDHTStatus(Repository repository, String name) async {
    if (_dhtStatus == null) {
      await _getDhtStatus();
    }

    if (_dhtStatus!.containsKey(name)) {
      _dhtStatus![name]! ? repository.enableDht() : repository.disableDht();

      loggyInstance.loggy.app('DHT status: $_dhtStatus');
      return;  
    }

    final status = await repository.isDhtEnabled();
    _dhtStatus!.addAll({ name: status});

    _saveDHTStatusForRepo(_dhtStatus!);

    loggyInstance.loggy.app('DHT status: $_dhtStatus');
  }

  static Future<void> updateBitTorrentDHTForRepoStatus(String name, bool status) async {
    if (_dhtStatus == null) {
      await _getDhtStatus();
    }

    _dhtStatus!.update(name, (value) => status, ifAbsent: () => status);
    _saveDHTStatusForRepo(_dhtStatus!);
  }

  static Future<bool?> removeBitTorrentDHTStatusForRepo(String name) async {
    if (_dhtStatus == null) {
      await _getDhtStatus();
    }

    if (_dhtStatus!.containsKey(name)) {
      final removed = _dhtStatus!.remove(name);
      if (removed ?? false) {
        _saveDHTStatusForRepo(_dhtStatus!); 
       return true;
      }
    }

    return false;
  }

  static Future<void> _getDhtStatus() async {
    final encodedDhtStatus = await Settings.readSetting(Constants.bitTorrentDHTStatusKey);
    _dhtStatus = encodedDhtStatus == null 
    ? Map<String, bool>()
    : Map<String, bool>.from(json.decode(encodedDhtStatus));
  }

  static void _saveDHTStatusForRepo(Map<String, bool> dhtStatus) async {
    final encodedDhtStatus = json.encode(dhtStatus);
    loggyInstance.loggy.app('DHT status: $encodedDhtStatus');

    await Settings.saveSetting(Constants.bitTorrentDHTStatusKey, encodedDhtStatus);
  }
}