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

class Job {
  int soFar;
  int total;
  bool cancel = false;
  Job(this.soFar, this.total);
}

class RepoCubit extends cubits.WatchSelf<RepoCubit> with OuiSyncAppLogger {
  bool isLoading = false;
  final Map<String, cubits.Watch<Job>> uploads = HashMap();
  final Map<String, cubits.Watch<Job>> downloads = HashMap();
  final List<String> messages = <String>[];

  final Folder _currentFolder = Folder();
  final String _name;
  final oui.Repository _handle;

  RepoCubit(this._name, this._handle) {
    _currentFolder.repo = this;
  }

  oui.Repository get handle => _handle;
  String get name => _name;
  Folder get currentFolder => _currentFolder;

  bool isDhtEnabled() => handle.isDhtEnabled();
  void enableDht() => handle.enableDht();
  void disableDht() => handle.disableDht();

  Future<oui.Directory> openDirectory(String path) async {
    return await oui.Directory.open(handle, path);
  }

  // This operator is required for the DropdownMenuButton to show entries properly.
  @override
  bool operator==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoCubit && id == other.id;
  }

  oui.AccessMode get accessMode => handle.accessMode;
  String get id => handle.lowHexId();
  bool get canRead => accessMode != oui.AccessMode.blind;
  bool get canWrite => accessMode == oui.AccessMode.write;

  Future<oui.ShareToken> createShareToken(oui.AccessMode accessMode) async {
    return await handle.createShareToken(accessMode: accessMode, name: _name);
  }

  Future<bool> exists(String path) async {
    return await handle.exists(path);
  }

  Future<oui.EntryType?> type(String path) => handle.type(path);

  Future<oui.Progress> syncProgress() async {
    return await handle.syncProgress();
  }

  // Get the state monitor of this particular repository. That is 'root >
  // Repositories > this repository ID'.
  StateMonitor stateMonitor() {
    return handle.stateMonitor()!;
  }

  Future<void> navigateTo(String destination) async {
    update((state) { state.isLoading = true; });
    _currentFolder.goTo(destination);
    await _refreshFolder();
    update((state) { state.isLoading = false; });
  }

  Future<bool> createFolder(String folderPath) async {
    update((state) { state.isLoading = true; });

    try{
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
    update((state) { state.isLoading = true; });

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
      required String newFilePath,
      required String fileName,
      required int length,
      required Stream<List<int>> fileByteStream,
  }) async {
    if (uploads.containsKey(newFilePath)) {
      showMessage("File is already being uploaded");
      return;
    }

    final file = await _createFile(newFilePath);

    if (file == null) {
      showMessage(S.current.messageNewFileError(newFilePath));
      return;
    }

    final job = cubits.Watch(Job(0, length));
    update((repo) { repo.uploads[newFilePath] = job; });

    await _refreshFolder();

    // TODO: We should try to remove the file in case of exception or user cancellation.

    try {
      int offset = 0;
      final stream = fileByteStream.takeWhile((_) => job.state.cancel == false);

      await for (final buffer in stream) {
        await file.write(offset, buffer);
        offset += buffer.length;
        job.update((job) { job.soFar = offset; });
      }
    } catch (e) {
      showMessage(S.current.messageWritingFileError(newFilePath));
      return;
    } finally {
      await file.close();
      update((repo) { repo.uploads.remove(newFilePath); });
    }

    if (job.state.cancel) {
      showMessage(S.current.messageWritingFileCanceled(newFilePath));
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
        final entryType = iterator.current.type;
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
    } finally {
      directory.close();
    }

    if (error != null) {
      throw error;
    }

    return content;
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

    file.close();

    return length;
  }

  Future<void> downloadFile({ required String sourcePath, required String destinationPath }) async {
    if (downloads.containsKey(sourcePath)) {
      showMessage("File is already being downloaded");
      return;
    }

    final ouisyncFile = await oui.File.open(handle, sourcePath);
    final length = await ouisyncFile.length;

    final newFile = io.File(destinationPath);
    int offset = 0;

    final job = cubits.Watch(Job(0, length));
    update((repo) { repo.downloads[sourcePath] = job; });

    try {
      while (job.state.cancel == false) {
        final chunk = await ouisyncFile.read(offset, Constants.bufferSize);
        offset += chunk.length;

        await newFile.writeAsBytes(chunk, mode: io.FileMode.writeOnlyAppend);

        if (chunk.length < Constants.bufferSize) {
          update((repo) { repo.downloads.remove(sourcePath); });
          break;
        }

        job.update((job) { job.soFar = offset; });
      }
    } catch (e, st) {
      loggy.app('Download file $sourcePath exception', e, st);
      showMessage(S.current.messageDownloadingFileError(sourcePath));
    } finally {
      update((repo) { repo.downloads.remove(sourcePath); });
      await ouisyncFile.close();
    }
  }

  Future<bool> moveEntry({ required String source, required String destination }) async {
    update((state) { state.isLoading = true; });

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
    update((state) { state.isLoading = true; });

    try{
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
      while (canRead) {
        bool success = await _currentFolder.refresh();

        if (success) break;
        if (_currentFolder.isRoot()) break;

        _currentFolder.goUp();

        if (!errorShown) {
          errorShown = true;
          showMessage(S.current.messageErrorCurrentPathMissing(path));
        }
      }
    }
    catch (e) {
      showMessage(e.toString());
    }

    update((state) { state.isLoading = false; });
  }

  void showMessage(String message) {
    update((state) { state.messages.add(message); });
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
  int get hashCode => super.hashCode;

}
