import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../blocs.dart';

export '../../models/repo_state.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> with OuiSyncAppLogger {
  DirectoryBloc() : super(DirectoryInitial()) {
    on<CreateFolder>(_onCreateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<SaveFile>(_onSaveFile);
    on<CancelSaveFile>(_onCancelSaveFile);
    on<DownloadFile>(_onDownloadFile);
    on<CancelDownloadFile>(_onCancelDownloadFile);
    on<MoveEntry>(_onMoveEntry);
    on<DeleteFile>(_onDeleteFile);
    on<NavigateTo>(_onNavigateTo);
    on<GetContent>(_onGetContents);
  }

  Future<void> _onNavigateTo(NavigateTo event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());
    event.repository.currentFolder.goTo(event.destination);
    await _refreshFolder(event.repository, emit);
  }

  Future<void> _onCreateFolder(CreateFolder event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try{
      final result = await event.repository.createFolder(event.newFolderPath);
      if (result.result) {
        event.repository.currentFolder.goTo(event.newFolderPath);
      } else {
        loggy.app('Directory ${event.newFolderPath} creation failed');
      }
    } catch (e, st) {
      loggy.app('Directory ${event.newFolderPath} creation exception', e, st);
    }

    await _refreshFolder(event.repository, emit);
  }

  Future<void> _onDeleteFolder(DeleteFolder event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try {
      final result = await event.repository.deleteFolder(event.path, event.recursive);
      if (result.errorMessage.isNotEmpty) {
        loggy.app('Delete directory ${event.path} failed');
      }
    } catch (e, st) {
      loggy.app('Directory ${event.path} deletion exception', e, st);
    }

    await _refreshFolder(event.repository, emit);
  }

  Future<void> _onSaveFile(SaveFile event, Emitter<DirectoryState> emit) async {
    final fileCreationResult = await _createFile(
      event.repository,
      event.newFilePath,
      event.fileName,
    );

    emit(fileCreationResult);

    if (fileCreationResult is CreateFileDone) {
      await _refreshFolder(event.repository, emit);

      final file = fileCreationResult.file;
      int offset = 0;
      try {
        final stream = event.fileByteStream
        .takeWhile((element) {
          return _takeWhile(
            event.repository.handle,
            event.newFilePath,
            _repositorySave,
            _cancelFileWriting);
        });
        
        await for (final buffer in stream) {
          await file.write(offset, buffer);
          offset += buffer.length;

          emit(WriteToFileInProgress(
            repository: event.repository,
            path: event.newFilePath,
            fileName: event.fileName,
            length: event.length,
            progress: offset
          ));

          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e, st) {
        loggy.app('Writing to file ${event.newFilePath} exception', e, st);
        emit(ShowMessage(S.current.messageWritingFileError(event.newFilePath)));
        emit(WriteToFileDone(repository: event.repository, path: event.newFilePath));
        return;
      } finally {
        loggy.app('Writing to file ${event.newFilePath} done - closing');
        await file.close();
      }

      if (_cancelFileWriting.isEmpty) {
        emit(ShowMessage(S.current.messageWritingFileDone(event.newFilePath)));
        emit(WriteToFileDone(repository: event.repository, path: event.newFilePath));
        return;
      }

      if (_cancelFileWriting == event.newFilePath) {
        loggy.app('${event.newFilePath} writing canceled by the user');
        _cancelFileWriting = '';

        emit(ShowMessage(S.current.messageWritingFileCanceled(event.newFilePath)));
        emit(WriteToFileDone(repository: event.repository, path: event.newFilePath));
      }
    }
  }

  String _cancelFileWriting = '';
  Repository? _repositorySave;
  void _onCancelSaveFile(CancelSaveFile event, Emitter<DirectoryState> emit) {
    loggy.app('Canceling ${event.filePath} creation');

    _repositorySave = event.repository.handle;
    _cancelFileWriting = event.filePath;

    loggy.app('Cancel creation: repository=${event.repository.name} handle=${event.repository.handle.handle} file=${event.filePath}');
  }

  Future<void> _onDownloadFile(DownloadFile event, Emitter<DirectoryState> emit) async {
    final ouisyncFile = await File.open(event.repository.handle, event.originFilePath);
    final length = await ouisyncFile.length;

    final newFile = io.File(event.destinationPath);
    int offset = 0;

    emit(DownloadFileInProgress(
      repository: event.repository,
      path: event.destinationPath,
      fileName: event.originFilePath,
      length: length,
      progress: offset
    ));
    
    try {
        while (_takeWhile(event.repository.handle, event.originFilePath, _repositoryDownload, _cancelFileDownload)) {
        final chunk = await ouisyncFile.read(offset, Constants.bufferSize);
        offset += chunk.length;
  
        await newFile.writeAsBytes(chunk, mode: io.FileMode.writeOnlyAppend);
  
        emit(DownloadFileInProgress(
          repository: event.repository,
          path: event.destinationPath,
          fileName: event.originFilePath,
          length: length,
          progress: offset
        ));

        if (chunk.length < Constants.bufferSize) {
          emit(DownloadFileDone(
            repository: event.repository,
            path: event.originFilePath,
            devicePath: event.destinationPath,
            result: DownloadFileResult.done));
          break;
        }
      }
    } catch (e, st) {
      loggy.app('Download file ${event.originFilePath} exception', e, st);

      emit(ShowMessage(S.current.messageDownloadingFileError(event.originFilePath)));
      emit(DownloadFileDone(
        repository: event.repository,
        path: event.originFilePath,
        devicePath: event.destinationPath,
        result: DownloadFileResult.failed));

      return;
    } finally {
      loggy.app('Download file ${event.originFilePath} done - closing');
      await ouisyncFile.close();
    }

    if (_cancelFileDownload.isEmpty) {
      emit(ShowMessage(S.current.messageDownloadingFileDone(event.originFilePath)));
      return;
    }

    if (_cancelFileDownload == event.originFilePath) {
      _cancelFileDownload = '';
      
      loggy.app('${event.originFilePath} download canceled by the user');
      emit(ShowMessage(S.current.messageDownloadingFileCanceled(event.originFilePath)));

      emit(DownloadFileDone(
        repository: event.repository,
        path: event.originFilePath,
        devicePath: event.destinationPath,
        result: DownloadFileResult.canceled));
    }
  }

  String _cancelFileDownload = '';
  Repository? _repositoryDownload;
  void _onCancelDownloadFile(CancelDownloadFile event, Emitter<DirectoryState> emit) {
    loggy.app('Canceling ${event.filePath} download');

    _repositoryDownload = event.repository.handle;
    _cancelFileDownload = event.filePath;

    loggy.app('Cancel downloading: repository=${event.repository.name} handle=${event.repository.handle.handle} file=${event.filePath}');
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

  Future<DirectoryState> _createFile(
    RepoState repository,
    String newFilePath,
    String fileName,
  ) async {
    CreateFileResult? createFileResult;
    try {
      createFileResult = (await repository.createFile(newFilePath)) as CreateFileResult?;
      if (createFileResult!.errorMessage.isNotEmpty) {
        loggy.app('Create file $newFilePath failed:\n${createFileResult.errorMessage}');
        return ShowMessage(S.current.messageNewFileError(newFilePath));
      }
    } catch (e, st) {
      loggy.app('Create file $newFilePath exception', e, st);
      return ShowMessage(S.current.messageNewFileError(newFilePath));
    }

    final name = getBasename(newFilePath);
    final extension = getFileExtension(newFilePath);
    return CreateFileDone(
      file: createFileResult.result!,
      fileName: name,
      path: newFilePath,
      extension: extension
    );
  }

  Future<void> _onMoveEntry(MoveEntry event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try {
      final moveEntryResult = await event.repository.moveEntry(event.source, event.destination);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Move entry from ${event.source} to ${event.destination} failed:\n${moveEntryResult.errorMessage}');
      }
    } catch (e, st) {
      loggy.app('Move entry from ${event.source} to ${event.destination} exception', e, st);
    }

    await _refreshFolder(event.repository, emit);
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try{
      final deleteFileResult = await event.repository.deleteFile(event.filePath);
      if (deleteFileResult.errorMessage.isNotEmpty)
      {
        loggy.app('Delete file ${event.filePath} failed');
      }
    } catch (e, st) {
      loggy.app('Delete file ${event.filePath} exception', e, st);
    }

    await _refreshFolder(event.repository, emit);
  }

  Future<void> _onGetContents(GetContent event, Emitter<DirectoryState> emit) async {
    await _refreshFolder(event.repository, emit);
  }

  int next_id = 0;
  Future<void> _refreshFolder(RepoState repo, Emitter<DirectoryState> emit) async {
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
          emit(ShowMessage(S.current.messageErrorCurrentPathMissing(path)));
        }
      }
    }
    catch (e) {
      emit(ShowMessage(e.toString()));
    }

    emit(DirectoryReloaded(id: id, path: path));
  }
}
