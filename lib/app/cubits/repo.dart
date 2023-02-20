// ignore_for_file: unnecessary_overrides

import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';

import '../../generated/l10n.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import 'cubits.dart' as cubits;
import 'job.dart';

class RepoCubit extends cubits.WatchSelf<RepoCubit> with OuiSyncAppLogger {
  bool isLoading = false;
  final Map<String, Job> uploads = HashMap();
  final Map<String, Job> downloads = HashMap();
  final List<String> messages = <String>[];

  final Folder _currentFolder = Folder();
  final SettingsRepoEntry _settingsRepoEntry;
  final oui.Repository _handle;
  final Settings _settings;

  RepoCubit({
    required SettingsRepoEntry settingsRepoEntry,
    required oui.Repository handle,
    required Settings settings,
  })  : _settingsRepoEntry = settingsRepoEntry,
        _handle = handle,
        _settings = settings {
    _currentFolder.repo = this;
  }

  oui.Repository get handle => _handle;
  String get databaseId => _settingsRepoEntry.databaseId;
  String get name => _settingsRepoEntry.name;
  RepoMetaInfo get metaInfo => _settingsRepoEntry.info;
  SettingsRepoEntry get settingsRepoEntry => _settingsRepoEntry;
  Folder get currentFolder => _currentFolder;

  void loadSettings() {
    if (_settings.getDhtEnabled(name) ?? true) {
      handle.enableDht();
    }

    if (_settings.getPexEnabled(name) ?? true) {
      handle.enablePex();
    }
  }

  Future<bool> get isDhtEnabled => handle.isDhtEnabled;

  Future<void> setDhtEnabled(bool value) async {
    if (await isDhtEnabled == value) {
      return;
    }

    if (value) {
      await handle.enableDht();
    } else {
      await handle.disableDht();
    }

    await _settings.setDhtEnabled(name, value);

    changed();
  }

  Future<bool> get isPexEnabled => handle.isPexEnabled;

  Future<void> setPexEnabled(bool value) async {
    if (await isPexEnabled == value) {
      return;
    }

    if (value) {
      await handle.enablePex();
    } else {
      await handle.disablePex();
    }

    await _settings.setPexEnabled(name, true);

    changed();
  }

  Future<oui.Directory> openDirectory(String path) async {
    return await oui.Directory.open(handle, path);
  }

  // This operator is required for the DropdownMenuButton to show entries properly.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoCubit && infoHash == other.infoHash;
  }

  Future<oui.AccessMode> get accessMode => handle.accessMode;
  Future<String> get infoHash => handle.infoHash;
  Future<bool> get canRead =>
      accessMode.then((mode) => mode != oui.AccessMode.blind);
  Future<bool> get canWrite =>
      accessMode.then((mode) => mode == oui.AccessMode.write);

  Future<oui.ShareToken> createShareToken(oui.AccessMode accessMode,
      {String? password}) async {
    return await handle.createShareToken(
        accessMode: accessMode, name: name, password: password);
  }

  Future<bool> exists(String path) async {
    return await handle.exists(path);
  }

  Future<oui.EntryType?> type(String path) => handle.type(path);

  Future<oui.Progress> get syncProgress => handle.syncProgress;

  // Get the state monitor of this particular repository. That is 'root >
  // Repositories > this repository ID'.
  StateMonitor get stateMonitor => handle.stateMonitor;

  Future<void> navigateTo(String destination) async {
    update((state) {
      state.isLoading = true;
    });
    _currentFolder.goTo(destination);
    await _refreshFolder();
    update((state) {
      state.isLoading = false;
    });
  }

  Future<bool> createFolder(String folderPath) async {
    update((state) {
      state.isLoading = true;
    });

    try {
      await oui.Directory.create(handle, folderPath);
      _currentFolder.goTo(folderPath);
      return true;
    } catch (e, st) {
      loggy.app('Directory $folderPath creation failed', e, st);
      return false;
    } finally {
      await _refreshFolder();
    }
  }

  Future<bool> deleteFolder(String path, bool recursive) async {
    update((state) {
      state.isLoading = true;
    });

    try {
      await oui.Directory.remove(handle, path, recursive: recursive);
      return true;
    } catch (e, st) {
      loggy.app('Directory $path deletion failed', e, st);
      return false;
    } finally {
      await _refreshFolder();
    }
  }

  Future<void> saveFile({
    required String filePath,
    required int length,
    required Stream<List<int>> fileByteStream,
  }) async {
    if (uploads.containsKey(filePath)) {
      showMessage(S.current.messageFileIsDownloading);
      return;
    }

    final file = await _createFile(filePath);

    if (file == null) {
      showMessage(S.current.messageNewFileError(filePath));
      return;
    }

    final job = Job(0, length);
    update((repo) {
      repo.uploads[filePath] = job;
    });

    await _refreshFolder();

    // TODO: We should try to remove the file in case of exception or user cancellation.

    try {
      int offset = 0;
      final stream = fileByteStream.takeWhile((_) => job.state.cancel == false);

      await for (final buffer in stream) {
        await file.write(offset, buffer);
        offset += buffer.length;
        job.update(offset);
      }
    } catch (e) {
      showMessage(S.current.messageWritingFileError(filePath));
      return;
    } finally {
      await file.close();
      await _refreshFolder();
      update((repo) {
        repo.uploads.remove(filePath);
      });
    }

    if (job.state.cancel) {
      showMessage(S.current.messageWritingFileCanceled(filePath));
    }
  }

  Future<List<BaseItem>> getFolderContents(String path) async {
    String? error;

    final content = <BaseItem>[];

    // If the directory does not exist, the following command will throw.
    final directory = await oui.Directory.open(handle, path);
    final iterator = directory.iterator;

    try {
      while (iterator.moveNext()) {
        var size = 0;
        final entryName = iterator.current.name;
        final entryType = iterator.current.entryType;
        final entryPath = buildDestinationPath(path, entryName);

        if (entryType == oui.EntryType.file) {
          size = await _getFileSize(entryPath);
          content.add(FileItem(name: entryName, path: entryPath, size: size));
        }

        if (entryType == oui.EntryType.directory) {
          content.add(FolderItem(name: entryName, path: entryPath));
        }
      }
    } catch (e, st) {
      loggy.app('Traversing directory $path exception', e, st);
      error = e.toString();
    }

    if (error != null) {
      throw error;
    }

    return content;
  }

  Future<bool> setReadWritePassword(RepoMetaInfo info, String oldPassword,
      String newPassword, oui.ShareToken? shareToken) async {
    final name = info.name;

    try {
      await _handle.setReadWriteAccess(
          oldPassword: oldPassword,
          newPassword: newPassword,
          shareToken: shareToken);
    } catch (e, st) {
      loggy.app('Password change for repository $name failed', e, st);
      return false;
    }

    return true;
  }

  Future<bool> setReadPassword(
      RepoMetaInfo info, String newPassword, oui.ShareToken? shareToken) async {
    final name = info.name;

    try {
      await _handle.setReadAccess(
          newPassword: newPassword, shareToken: shareToken);
    } catch (e, st) {
      loggy.app('Password change for repository $name failed', e, st);
      return false;
    }

    return true;
  }

  Future<int> _getFileSize(String path) async {
    oui.File file;
    var length = 0;

    try {
      file = await oui.File.open(handle, path);
    } catch (e, st) {
      loggy.app("Open file $path exception (getFileSize)", e, st);
      return length;
    }

    try {
      length = await file.length;
    } catch (e, st) {
      loggy.app("Get file size $path exception", e, st);
    }

    await file.close();

    return length;
  }

  Future<void> downloadFile(
      {required String sourcePath, required String destinationPath}) async {
    if (downloads.containsKey(sourcePath)) {
      showMessage(S.current.messageFileIsDownloading);
      return;
    }

    final ouisyncFile = await oui.File.open(handle, sourcePath);
    final length = await ouisyncFile.length;

    final newFile = io.File(destinationPath);

    // TODO: This fails if the file exists, we should ask the user to confirm if they want to overwrite
    // the existing file.
    final sink = newFile.openWrite();
    int offset = 0;

    final job = Job(0, length);
    update((repo) {
      repo.downloads[sourcePath] = job;
    });

    try {
      while (job.state.cancel == false) {
        late List<int> chunk;

        await Future.wait([
          ouisyncFile.read(offset, Constants.bufferSize).then((ch) {
            chunk = ch;
          }),
          sink.flush()
        ]);

        offset += chunk.length;

        sink.add(chunk);

        if (chunk.length < Constants.bufferSize) {
          break;
        }

        job.update(offset);
      }
    } catch (e, st) {
      loggy.app('Download file $sourcePath exception', e, st);
      showMessage(S.current.messageDownloadingFileError(sourcePath));
    } finally {
      update((repo) {
        repo.downloads.remove(sourcePath);
      });

      await Future.wait(
          [sink.flush().then((_) => sink.close()), ouisyncFile.close()]);
    }
  }

  Future<bool> moveEntry(
      {required String source, required String destination}) async {
    update((state) {
      state.isLoading = true;
    });

    try {
      await handle.move(source, destination);
      return true;
    } catch (e, st) {
      loggy.app('Move entry from $source to $destination failed', e, st);
      return false;
    } finally {
      await _refreshFolder();
    }
  }

  Future<bool> deleteFile(String filePath) async {
    update((state) {
      state.isLoading = true;
    });

    try {
      await oui.File.remove(handle, filePath);
      return true;
    } catch (e, st) {
      loggy.app('Delete file $filePath failed', e, st);
      return false;
    } finally {
      await _refreshFolder();
    }
  }

  Future<void> getContent() async {
    await _refreshFolder();
  }

  Future<void> _refreshFolder() async {
    final path = _currentFolder.path;
    bool errorShown = false;

    try {
      while (await canRead) {
        bool success = await _currentFolder.refresh();

        if (success) break;
        if (_currentFolder.isRoot()) break;

        _currentFolder.goUp();

        if (!errorShown) {
          errorShown = true;
          showMessage(S.current.messageErrorCurrentPathMissing(path));
        }
      }
    } catch (e) {
      showMessage(e.toString());
    }

    update((state) {
      state.isLoading = false;
    });
  }

  void showMessage(String message) {
    update((state) {
      state.messages.add(message);
    });
  }

  Future<oui.File?> _createFile(String newFilePath) async {
    oui.File? newFile;

    try {
      newFile = await oui.File.create(handle, newFilePath);
    } catch (e, st) {
      loggy.app('File creation $newFilePath failed', e, st);
    }

    return newFile;
  }

  Future<void> close() async {
    await handle.close();
  }

  @override
  // TODO: implement hashCode
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
