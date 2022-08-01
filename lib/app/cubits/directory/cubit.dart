import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import 'state.dart';
import '../../models/models.dart';

export "state.dart";
export '../../models/repo_state.dart';

class DirectoryCubit extends Cubit<DirectoryState> with OuiSyncAppLogger {
  DirectoryCubit() : super(DirectoryInitial()) {}

  Future<void> navigateTo(BuildContext context, RepoState repo, String destination) async {
    emit(DirectoryLoadInProgress());
    repo.currentFolder.goTo(destination);
    await _refreshFolder(context, repo);
  }

  Future<void> createFolder(BuildContext context, RepoState repo, String folderPath) async {
    emit(DirectoryLoadInProgress());

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

    await _refreshFolder(context, repo);
  }

  Future<void> deleteFolder(BuildContext context, RepoState repo, String path, bool recursive) async {
    emit(DirectoryLoadInProgress());

    try {
      final result = await repo.deleteFolder(path, recursive);
      if (result.errorMessage.isNotEmpty) {
        loggy.app('Delete directory $path failed');
      }
    } catch (e, st) {
      loggy.app('Directory $path deletion exception', e, st);
    }

    await _refreshFolder(context, repo);
  }

  Future<void> saveFile(
      BuildContext context,
      RepoState repo, {
      required String newFilePath,
      required String fileName,
      required int length,
      required Stream<List<int>> fileByteStream,
  }) async {
    final file = await _createFile(
      context,
      repo,
      newFilePath,
      fileName,
    );

    if (file == null) {
      return;
    }

    await _refreshFolder(context, repo);

    int offset = 0;
    try {
      final stream = fileByteStream
      .takeWhile((element) {
        return _takeWhile(
          repo.handle,
          newFilePath,
          _repositorySave,
          _cancelFileWriting);
      });

      await for (final buffer in stream) {
        await file.write(offset, buffer);
        offset += buffer.length;

        emit(WriteToFileInProgress(
          repository: repo,
          path: newFilePath,
          fileName: fileName,
          length: length,
          progress: offset
        ));
      }
    } catch (e, st) {
      loggy.app('Writing to file ${newFilePath} exception', e, st);
      showMessage(context, S.current.messageWritingFileError(newFilePath));
      emit(WriteToFileDone(repository: repo, path: newFilePath));
      return;
    } finally {
      loggy.app('Writing to file ${newFilePath} done - closing');
      await file.close();
    }

    if (_cancelFileWriting.isEmpty) {
      showMessage(context, S.current.messageWritingFileDone(newFilePath));
      emit(WriteToFileDone(repository: repo, path: newFilePath));
      return;
    }

    if (_cancelFileWriting == newFilePath) {
      loggy.app('${newFilePath} writing canceled by the user');
      _cancelFileWriting = '';

      showMessage(context, S.current.messageWritingFileCanceled(newFilePath));
      emit(WriteToFileDone(repository: repo, path: newFilePath));
    }
  }

  String _cancelFileWriting = '';
  Repository? _repositorySave;
  void cancelSaveFile(RepoState repo, String filePath) {
    loggy.app('Canceling ${filePath} creation');

    _repositorySave = repo.handle;
    _cancelFileWriting = filePath;

    loggy.app('Cancel creation: repository=${repo.name} handle=${repo.handle.handle} file=${filePath}');
  }

  Future<void> downloadFile(
      BuildContext context,
      RepoState repo,
      { required String sourcePath, required String destinationPath }) async
  {
    final ouisyncFile = await File.open(repo.handle, sourcePath);
    final length = await ouisyncFile.length;

    final newFile = io.File(destinationPath);
    int offset = 0;

    emit(DownloadFileInProgress(
      repository: repo,
      path: destinationPath,
      fileName: sourcePath,
      length: length,
      progress: offset
    ));

    try {
        while (_takeWhile(repo.handle, sourcePath, _repositoryDownload, _cancelFileDownload)) {
        final chunk = await ouisyncFile.read(offset, Constants.bufferSize);
        offset += chunk.length;

        await newFile.writeAsBytes(chunk, mode: io.FileMode.writeOnlyAppend);

        emit(DownloadFileInProgress(
          repository: repo,
          path: destinationPath,
          fileName: sourcePath,
          length: length,
          progress: offset
        ));

        if (chunk.length < Constants.bufferSize) {
          emit(DownloadFileDone(
            repository: repo,
            path: sourcePath,
            devicePath: destinationPath,
            result: DownloadFileResult.done));
          break;
        }
      }
    } catch (e, st) {
      loggy.app('Download file ${sourcePath} exception', e, st);

      showMessage(context, S.current.messageDownloadingFileError(sourcePath));
      emit(DownloadFileDone(
        repository: repo,
        path: sourcePath,
        devicePath: destinationPath,
        result: DownloadFileResult.failed));

      return;
    } finally {
      loggy.app('Download file ${sourcePath} done - closing');
      await ouisyncFile.close();
    }

    if (_cancelFileDownload.isEmpty) {
      showMessage(context, S.current.messageDownloadingFileDone(sourcePath));
      return;
    }

    if (_cancelFileDownload == sourcePath) {
      _cancelFileDownload = '';

      loggy.app('${sourcePath} download canceled by the user');
      showMessage(context, S.current.messageDownloadingFileCanceled(sourcePath));

      emit(DownloadFileDone(
        repository: repo,
        path: sourcePath,
        devicePath: destinationPath,
        result: DownloadFileResult.canceled));
    }
  }

  String _cancelFileDownload = '';
  Repository? _repositoryDownload;
  void cancelDownloadFile(RepoState repo, String filePath) {
    loggy.app('Canceling $filePath download');

    _repositoryDownload = repo.handle;
    _cancelFileDownload = filePath;

    loggy.app('Cancel downloading: repository=${repo.name} handle=${repo.handle.handle} file=${filePath}');
  }

  bool _takeWhile(
    Repository repository,
    String filePath,
    Repository? cancelRepository,
    String cancelFilePath) {
      loggy.app('Take while: handle=${repository.handle} file=$filePath cancel-repo=${cancelRepository?.handle} cancel-file=$cancelFilePath');

      if (repository != cancelRepository) {
        return true;
      }

      return filePath != cancelFilePath;
  }

  Future<File?> _createFile(
    BuildContext context,
    RepoState repository,
    String newFilePath,
    String fileName,
  ) async {
    CreateFileResult? createFileResult;

    try {
      createFileResult = (await repository.createFile(newFilePath)) as CreateFileResult?;
      if (createFileResult!.errorMessage.isNotEmpty) {
        loggy.app('Create file $newFilePath failed:\n${createFileResult.errorMessage}');
        showMessage(context, S.current.messageNewFileError(newFilePath));
        return null;
      }
    } catch (e, st) {
      loggy.app('Create file $newFilePath exception', e, st);
      showMessage(context, S.current.messageNewFileError(newFilePath));
      return null;
    }

    return createFileResult.result!;
  }

  Future<void> moveEntry(
      BuildContext context,
      RepoState repo,
      { required String source, required String destination }) async
  {
    emit(DirectoryLoadInProgress());

    try {
      final moveEntryResult = await repo.moveEntry(source, destination);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Move entry from ${source} to ${destination} failed:\n${moveEntryResult.errorMessage}');
      }
    } catch (e, st) {
      loggy.app('Move entry from ${source} to ${destination} exception', e, st);
    }

    await _refreshFolder(context, repo);
  }

  Future<void> deleteFile(BuildContext context, RepoState repo, String filePath) async {
    emit(DirectoryLoadInProgress());

    try{
      final deleteFileResult = await repo.deleteFile(filePath);
      if (deleteFileResult.errorMessage.isNotEmpty)
      {
        loggy.app('Delete file $filePath failed');
      }
    } catch (e, st) {
      loggy.app('Delete file $filePath exception', e, st);
    }

    await _refreshFolder(context, repo);
  }

  Future<void> getContent(BuildContext context, RepoState repository) async {
    await _refreshFolder(context, repository);
  }

  int next_id = 0;
  Future<void> _refreshFolder(BuildContext context, RepoState repo) async {
    // TODO: Only increment the id when the content changes.
    int id = next_id;
    next_id += 1;

    final path = repo.currentFolder.path;
    bool errorShown = false;

    try {
      while (repo.accessMode != AccessMode.blind) {
        bool success = await repo.currentFolder.refresh();

        if (success) break;
        if (repo.currentFolder.isRoot()) break;

        repo.currentFolder.goUp();

        if (!errorShown) {
          errorShown = true;
          showMessage(context, S.current.messageErrorCurrentPathMissing(path));
        }
      }
    }
    catch (e) {
      showMessage(context, e.toString());
    }

    emit(DirectoryReloaded(id: id, path: path));
  }

  void showMessage(BuildContext context, String message) {
    showSnackBar(context, content: Text(message));
  }
}
