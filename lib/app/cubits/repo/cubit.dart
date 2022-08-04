import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:ouisync_plugin/state_monitor.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';
import '../../models/folder_state.dart';
import '../cubits.dart' as cubits;

part "state.dart";

class RepoCubit extends cubits.Watch<RepoState> with OuiSyncAppLogger {
  FolderState _currentFolder = FolderState();

  RepoCubit(RepoState state)
    : super(state) {
    _currentFolder.repo = this;
  }

  oui.Repository get handle => state.handle;
  String get id => state.id;
  String get name => state.name;
  RepoState get repo => state;
  FolderState get currentFolder => _currentFolder;

  oui.AccessMode get accessMode => state.accessMode;
  bool get canRead => state.accessMode != oui.AccessMode.blind;
  bool get canWrite => state.accessMode == oui.AccessMode.write;

  Future<oui.ShareToken> createShareToken(oui.AccessMode accessMode) async {
    return await handle.createShareToken(accessMode: accessMode, name: name);
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

  Future<void> createFolder(String folderPath) async {
    update((state) { state.isLoading = true; });

    try{
      final result = await _createFolder(folderPath);
      if (result.result) {
        _currentFolder.goTo(folderPath);
      } else {
        loggy.app('Directory $folderPath creation failed');
      }
    } catch (e, st) {
      loggy.app('Directory $folderPath creation exception', e, st);
    }

    await _refreshFolder();
  }

  Future<BasicResult> _createFolder(String path) async {
    BasicResult createFolderResult;
    String error = '';

    bool created = false;

    try {
      loggy.app('Create folder $path');

      await oui.Directory.create(handle, path);
      created = true;
    } catch (e, st) {
      loggy.app('Create folder $path exception', e, st);

      created = false;
      error = e.toString();
    }

    createFolderResult = CreateFolderResult(functionName: '_createFolder', result: created);
    if (error.isNotEmpty) {
      createFolderResult.errorMessage = error;
    }

    return createFolderResult;
  }

  Future<void> deleteFolder(String path, bool recursive) async {
    update((state) { state.isLoading = true; });

    try {
      final result = await _deleteFolder(path, recursive);
      if (result.errorMessage.isNotEmpty) {
        loggy.app('Delete directory $path failed');
      }
    } catch (e, st) {
      loggy.app('Directory $path deletion exception', e, st);
    }

    await _refreshFolder();
  }

  Future<BasicResult> _deleteFolder(String path, bool recursive) async {
    BasicResult deleteFolderResult;
    String error = '';

    try {
      await oui.Directory.remove(handle, path, recursive: recursive);
    } catch (e, st) {
      loggy.app('Delete folder $path exception', e, st);
      error = 'Delete folder $path failed';
    }

    deleteFolderResult = DeleteFolderResult(functionName: '_deleteFolder', result: 'OK');
    if (error.isNotEmpty) {
      deleteFolderResult.errorMessage = error;
    }

    return deleteFolderResult;
  }

  Future<void> saveFile({
      required String newFilePath,
      required String fileName,
      required int length,
      required Stream<List<int>> fileByteStream,
  }) async {
    if (repo.uploads.containsKey(newFilePath)) {
      showMessage("File is already being uploaded");
      return;
    }

    final file = await _createFile(newFilePath);

    if (file == null) {
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
    } catch (e, st) {
      showMessage(S.current.messageWritingFileError(newFilePath));
      return;
    } finally {
      await file.close();
      update((repo) { repo.uploads.remove(newFilePath); });
    }

    if (job.state.cancel) {
      showMessage(S.current.messageWritingFileCanceled(newFilePath));
    } else {
      showMessage(S.current.messageWritingFileDone(newFilePath));
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
        if (iterator.current.type == oui.EntryType.file) {
          size = await _getFileSize(buildDestinationPath(path, iterator.current.name));
        }
        final item = await _castToBaseItem(path, iterator.current.name, iterator.current.type, size);

        content.add(item);
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
    var file;
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

  Future<BaseItem> _castToBaseItem(String path, String name, oui.EntryType type, int size) async {
    final itemPath = buildDestinationPath(path, name);

    if (type == oui.EntryType.directory) {
      return FolderItem(
          name: name,
          path: itemPath,
          size: size);
    }

    if (type == oui.EntryType.file) {
      return FileItem(name: name, path: itemPath, size: size);
    }

    return <BaseItem>[].single;
  }

  Future<void> downloadFile({ required String sourcePath, required String destinationPath }) async {
    if (repo.downloads.containsKey(sourcePath)) {
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
      loggy.app('Download file ${sourcePath} exception', e, st);
      showMessage(S.current.messageDownloadingFileError(sourcePath));
    } finally {
      update((repo) { repo.downloads.remove(sourcePath); });
      await ouisyncFile.close();
    }
  }

  Future<void> moveEntry({ required String source, required String destination }) async {
    update((state) { state.isLoading = true; });

    try {
      final moveEntryResult = await _moveEntry(source, destination);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Move entry from ${source} to ${destination} failed:\n${moveEntryResult.errorMessage}');
      }
    } catch (e, st) {
      loggy.app('Move entry from ${source} to ${destination} exception', e, st);
    }

    await _refreshFolder();
  }

  Future<BasicResult> _moveEntry(String originPath, String destinationPath) async {
    BasicResult moveEntryResult;
    String error = '';

    try {
      loggy.app('Move entry from $originPath to $destinationPath');

      await handle.move(originPath, destinationPath);
    } catch (e, st) {
      loggy.app('Move entry from $originPath to $destinationPath exception', e, st);
      error = e.toString();
    }

    moveEntryResult = MoveEntryResult(functionName: 'moveEntry', result: destinationPath);
    if (error.isNotEmpty) {
      moveEntryResult.errorMessage = error;
    }

    return moveEntryResult;
  }

  Future<void> deleteFile(String filePath) async {
    update((state) { state.isLoading = true; });

    try{
      final deleteFileResult = await _deleteFile(filePath);
      if (deleteFileResult.errorMessage.isNotEmpty)
      {
        loggy.app('Delete file $filePath failed');
      }
    } catch (e, st) {
      loggy.app('Delete file $filePath exception', e, st);
    }

    await _refreshFolder();
  }

  Future<BasicResult> _deleteFile(String filePath) async {
    BasicResult deleteFileResult;
    String error = '';

    try {
      await oui.File.remove(handle, filePath);
    } catch (e, st) {
      loggy.app('Delete file $filePath exception', e, st);
      error = 'Delete file $filePath failed';
    }

    deleteFileResult = DeleteFileResult(functionName: '_deleteFile', result: 'OK');
    if (error.isNotEmpty) {
      deleteFileResult.errorMessage = error;
    }

    return deleteFileResult;
  }

  Future<void> getContent() async {
    await _refreshFolder();
  }

  int _next_id = 0;
  Future<void> _refreshFolder() async {
    // TODO: Only increment the id when the content changes.
    int id = _next_id;
    _next_id += 1;

    final path = _currentFolder.path;
    bool errorShown = false;

    try {
      while (repo.accessMode != oui.AccessMode.blind) {
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
      loggy.app('Creating file $newFilePath');
      newFile = await oui.File.create(handle, newFilePath);
    } catch (e, st) {
      loggy.app('Creating file $newFilePath failed', e, st);
      showMessage(S.current.messageNewFileError(newFilePath));
    }

    return newFile;
  }
}
