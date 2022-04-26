import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
export '../../models/repo_state.dart';
import '../blocs.dart';
import '../../../generated/l10n.dart';


class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> with OuiSyncAppLogger {
  DirectoryBloc() : super(DirectoryInitial()) {
    on<CreateFolder>(_onCreateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<SaveFile>(_onSaveFile);
    on<CancelSaveFile>(_onCancelSaveFile);
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
          if (_cancelFileWriting.isEmpty) { return true; }
          return _cancelFileWriting != event.newFilePath;
        });
        
        await for (final buffer in stream) {
          await file.write(offset, buffer);
          offset += buffer.length;

          emit(WriteToFileInProgress(
            path: event.newFilePath,
            fileName: event.fileName,
            length: event.length,
            progress: offset
          ));
        }
      } catch (e, st) {
        loggy.app('Writing to file ${event.newFilePath} exception', e, st);
        emit(ShowMessage(S.current.messageWritingFileError(event.newFilePath)));
        emit(WriteToFileDone(path: event.newFilePath));
        return;
      } finally {
        loggy.app('Writing to file ${event.newFilePath} done - closing');
        await file.close();
      }

      if (_cancelFileWriting.isEmpty) {
        emit(ShowMessage(S.current.messageWritingFileDone(event.newFilePath)));
        emit(WriteToFileDone(path: event.newFilePath));
        return;
      }

      if (_cancelFileWriting == event.newFilePath) {
        loggy.app('${event.newFilePath} writing canceled by the user');
        emit(ShowMessage(S.current.messageWritingFileCanceled(event.newFilePath)));
        emit(WriteToFileDone(path: event.newFilePath));
      }
    }
  }

  String _cancelFileWriting = '';
  void _onCancelSaveFile(CancelSaveFile event, Emitter<DirectoryState> emit) {
    loggy.app('Canceling ${event.filePath}');
    _cancelFileWriting = event.filePath;
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
