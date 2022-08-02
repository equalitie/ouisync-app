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
  RepoCubit(RepoState state)
    : super(state);

  RepoState get repo => state;

  Future<void> navigateTo(String destination) async {
    update((state) { state.isLoading = true; });
    repo.currentFolder.goTo(destination);
    await _refreshFolder();
    update((state) { state.isLoading = false; });
  }

  Future<void> createFolder(String folderPath) async {
    update((state) { state.isLoading = true; });

    try{
      final result = await repo.createFolder(folderPath);
      if (result.result) {
        repo.currentFolder.goTo(folderPath);
      } else {
        loggy.app('Directory $folderPath creation failed');
      }
    } catch (e, st) {
      loggy.app('Directory $folderPath creation exception', e, st);
    }

    await _refreshFolder();
  }

  Future<void> deleteFolder(String path, bool recursive) async {
    update((state) { state.isLoading = true; });

    try {
      final result = await repo.deleteFolder(path, recursive);
      if (result.errorMessage.isNotEmpty) {
        loggy.app('Delete directory $path failed');
      }
    } catch (e, st) {
      loggy.app('Directory $path deletion exception', e, st);
    }

    await _refreshFolder();
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

    int offset = 0;
    try {
      final stream = fileByteStream
      .takeWhile((element) {
        return _takeWhile(
          repo.handle,
          newFilePath,
          _repositorySave,
          job.state);
      });

      await for (final buffer in stream) {
        await file.write(offset, buffer);
        offset += buffer.length;
        job.update((job) { job.soFar = offset; });
      }
    } catch (e, st) {
      loggy.app('Writing to file ${newFilePath} exception', e, st);
      showMessage(S.current.messageWritingFileError(newFilePath));
      //emit(WriteToFileDone(repository: repo, path: newFilePath));
      update((repo) { repo.uploads.remove(newFilePath); });
      return;
    } finally {
      loggy.app('Writing to file ${newFilePath} done - closing');
      await file.close();
    }

    if (_cancelFileWriting.isEmpty) {
      showMessage(S.current.messageWritingFileDone(newFilePath));
      update((repo) { repo.uploads.remove(newFilePath); });
      return;
    }

    if (_cancelFileWriting == newFilePath) {
      loggy.app('${newFilePath} writing canceled by the user');
      _cancelFileWriting = '';

      showMessage(S.current.messageWritingFileCanceled(newFilePath));
      update((repo) { repo.uploads.remove(newFilePath); });
    }
  }

  String _cancelFileWriting = '';
  oui.Repository? _repositorySave;
  void cancelSaveFile(String filePath) {
    loggy.app('Canceling ${filePath} creation');

    _repositorySave = repo.handle;
    _cancelFileWriting = filePath;

    loggy.app('Cancel creation: repository=${repo.name} handle=${repo.handle.handle} file=${filePath}');
  }

  // TODO
  Future<void> downloadFile({ required String sourcePath, required String destinationPath }) async {
    //final ouisyncFile = await File.open(repo.handle, sourcePath);
    //final length = await ouisyncFile.length;

    //final newFile = io.File(destinationPath);
    //int offset = 0;

    //emit(DownloadFileInProgress(
    //  repository: repo,
    //  path: destinationPath,
    //  fileName: sourcePath,
    //  length: length,
    //  progress: offset
    //));

    //try {
    //    while (_takeWhile(repo.handle, sourcePath, _repositoryDownload, _cancelFileDownload)) {
    //    final chunk = await ouisyncFile.read(offset, Constants.bufferSize);
    //    offset += chunk.length;

    //    await newFile.writeAsBytes(chunk, mode: io.FileMode.writeOnlyAppend);

    //    emit(DownloadFileInProgress(
    //      repository: repo,
    //      path: destinationPath,
    //      fileName: sourcePath,
    //      length: length,
    //      progress: offset
    //    ));

    //    if (chunk.length < Constants.bufferSize) {
    //      emit(DownloadFileDone(
    //        repository: repo,
    //        path: sourcePath,
    //        devicePath: destinationPath,
    //        result: DownloadFileResult.done));
    //      break;
    //    }
    //  }
    //} catch (e, st) {
    //  loggy.app('Download file ${sourcePath} exception', e, st);

    //  showMessage(S.current.messageDownloadingFileError(sourcePath));
    //  emit(DownloadFileDone(
    //    repository: repo,
    //    path: sourcePath,
    //    devicePath: destinationPath,
    //    result: DownloadFileResult.failed));

    //  return;
    //} finally {
    //  loggy.app('Download file ${sourcePath} done - closing');
    //  await ouisyncFile.close();
    //}

    //if (_cancelFileDownload.isEmpty) {
    //  showMessage(S.current.messageDownloadingFileDone(sourcePath));
    //  return;
    //}

    //if (_cancelFileDownload == sourcePath) {
    //  _cancelFileDownload = '';

    //  loggy.app('${sourcePath} download canceled by the user');
    //  showMessage(S.current.messageDownloadingFileCanceled(sourcePath));

    //  emit(DownloadFileDone(
    //    repository: repo,
    //    path: sourcePath,
    //    devicePath: destinationPath,
    //    result: DownloadFileResult.canceled));
    //}
  }

  String _cancelFileDownload = '';
  oui.Repository? _repositoryDownload;
  void cancelDownloadFile(String filePath) {
    loggy.app('Canceling $filePath download');

    _repositoryDownload = repo.handle;
    _cancelFileDownload = filePath;

    loggy.app('Cancel downloading: repository=${repo.name} handle=${repo.handle.handle} file=${filePath}');
  }

  bool _takeWhile(
    oui.Repository repository,
    String filePath,
    oui.Repository? cancelRepository,
    Job job) {
      loggy.app('Take while: handle=${repository.handle} file=$filePath cancel-repo=${cancelRepository?.handle}');

      if (repository != cancelRepository) {
        return true;
      }

      return !job.cancel;
  }

  Future<oui.File?> _createFile(String newFilePath) async {
    CreateFileResult? createFileResult;

    try {
      createFileResult = (await repo.createFile(newFilePath)) as CreateFileResult?;
      if (createFileResult!.errorMessage.isNotEmpty) {
        loggy.app('Create file $newFilePath failed:\n${createFileResult.errorMessage}');
        showMessage(S.current.messageNewFileError(newFilePath));
        return null;
      }
    } catch (e, st) {
      loggy.app('Create file $newFilePath exception', e, st);
      showMessage(S.current.messageNewFileError(newFilePath));
      return null;
    }

    return createFileResult.result!;
  }

  Future<void> moveEntry({ required String source, required String destination }) async {
    update((state) { state.isLoading = true; });

    try {
      final moveEntryResult = await repo.moveEntry(source, destination);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Move entry from ${source} to ${destination} failed:\n${moveEntryResult.errorMessage}');
      }
    } catch (e, st) {
      loggy.app('Move entry from ${source} to ${destination} exception', e, st);
    }

    await _refreshFolder();
  }

  Future<void> deleteFile(String filePath) async {
    update((state) { state.isLoading = true; });

    try{
      final deleteFileResult = await repo.deleteFile(filePath);
      if (deleteFileResult.errorMessage.isNotEmpty)
      {
        loggy.app('Delete file $filePath failed');
      }
    } catch (e, st) {
      loggy.app('Delete file $filePath exception', e, st);
    }

    await _refreshFolder();
  }

  Future<void> getContent() async {
    await _refreshFolder();
  }

  int next_id = 0;
  Future<void> _refreshFolder() async {
    // TODO: Only increment the id when the content changes.
    int id = next_id;
    next_id += 1;

    final path = repo.currentFolder.path;
    bool errorShown = false;

    try {
      while (repo.accessMode != oui.AccessMode.blind) {
        bool success = await repo.currentFolder.refresh();

        if (success) break;
        if (repo.currentFolder.isRoot()) break;

        repo.currentFolder.goUp();

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
}
