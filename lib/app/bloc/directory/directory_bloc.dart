import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
export '../../models/repo_state.dart';
import '../blocs.dart';


class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> with OuiSyncAppLogger {
  DirectoryBloc() : super(DirectoryInitial()) {
    on<CreateFolder>(_onCreateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<SaveFile>(_onSaveFile);
    on<CancelSaveFile>(_onCancelSaveFile);
    on<RenameEntry>(_onRenameEntry);
    on<MoveEntry>(_onMoveEntry);
    on<DeleteFile>(_onDeleteFile);
    on<GetContent>(_onGetContents);
  }

  Future<void> _onCreateFolder(CreateFolder event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try{
      final createFileResult = await event.repository.createFolder(event.newFolderPath);
      if (!createFileResult.result) 
      {
        loggy.app('Directory ${event.newFolderPath} creation failed');
      }
    } catch (e, st) {
      loggy.app('Directory ${event.newFolderPath} creation exception', e, st);
    }
    
    event.repository.currentFolder.path = event.newFolderPath;

    await _refreshFolder(event.repository, emit);
  }

  Future<void> _onDeleteFolder(DeleteFolder event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    late final deleteFolderResult;
    try {
      deleteFolderResult = await event.repository.deleteFolder(event.path, event.recursive);
      if (deleteFolderResult.errorMessage.isNotEmpty) 
      {
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
      event.length
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
        emit(WriteToFileFailure(
          path: event.newFilePath,
          fileName: event.fileName,
          length: event.length,
          error: e.toString()
        ));
        return;
      } finally {
        loggy.app('Writing to file ${event.newFilePath} done - closing');
        await file.close();
      }

      if (_cancelFileWriting.isEmpty) {
        emit(WriteToFileDone(
          path: event.newFilePath,
          fileName: event.fileName,
          length: event.length
        ));

        return;
      }

      if (_cancelFileWriting == event.newFilePath) {
        loggy.app('${event.newFilePath} writing canceled by the user');
        
        emit(WriteToFileCanceled(
          path: event.newFilePath,
          fileName: event.fileName,
        ));
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
    int length
  ) async {
    CreateFileResult? createFileResult;
    try {
      createFileResult = (await repository.createFile(newFilePath)) as CreateFileResult?;
      if (createFileResult!.errorMessage.isNotEmpty) {
        loggy.app('Create file $newFilePath failed:\n${createFileResult.errorMessage}');
        
        return CreateFileFailure(
          path: newFilePath,
        );
      }
    } catch (e, st) {
      loggy.app('Create file $newFilePath exception', e, st);
      
      return CreateFileFailure(
        path: newFilePath,
      );
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

  Future<void> _onRenameEntry(RenameEntry event, Emitter<DirectoryState> emit) async {
    try {
      final renameEntryResult = await event.repository.moveEntry(event.entryPath, event.newEntryPath);
      if (renameEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Rename entry from ${event.entryPath} to ${event.newEntryPath} failed:\n${renameEntryResult.errorMessage}');
      }  
    } catch (e, st) {
      loggy.app('Rename entry from ${event.entryPath} to ${event.newEntryPath} exception', e, st);
    }

    await _refreshFolder(event.repository, emit);
  }

  Future<void> _onMoveEntry(MoveEntry event, Emitter<DirectoryState> emit) async {
    try {
      final moveEntryResult = await event.repository.moveEntry(event.entryPath, event.newDestinationPath);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Move entry from ${event.entryPath} to ${event.newDestinationPath} failed:\n${moveEntryResult.errorMessage}');
      }  
    } catch (e, st) {
      loggy.app('Move entry from ${event.entryPath} to ${event.newDestinationPath} exception', e, st);
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

  RepoState? _curRefreshRepo;
  RepoState? _nextRefreshRepo;
  Emitter<DirectoryState>? _nextEmit;
  List<Completer> _getContentCompleters = <Completer>[];

  // Trigger content update. If a content update is already in progress, it is scheduled
  // to be done afterwards.
  Future<void> _refreshFolder(RepoState repo, Emitter<DirectoryState> emit) async {
    final completer = Completer<void>();
    final future = completer.future;
    _getContentCompleters.add(completer);

    _nextRefreshRepo = repo;
    _nextEmit = emit;

    if (_curRefreshRepo == null) {
      _runUpdateLoop(); // don't await
    }

    return future;
  }

  void _runUpdateLoop() async {
    while (_nextRefreshRepo != null) {
      _curRefreshRepo = _nextRefreshRepo;
      _nextRefreshRepo = null;

      final emit = _nextEmit!;
      _nextEmit = null;

      final completers = _getContentCompleters;
      _getContentCompleters = <Completer>[];

      final state = await _getContents(_curRefreshRepo!);

      _curRefreshRepo = null;

      emit(state);

      for (var completer in completers) {
        completer.complete();
      }
    }
  }

  Future<DirectoryState> _getContents(RepoState repo) async {
    try {
      if (repo.accessMode == AccessMode.blind) {
        return DirectoryLoadFailure();
      }

      await repo.currentFolder.refresh();

      return DirectoryLoadSuccess(path: repo.currentFolder.path);
    }
    catch (e) {
      return DirectoryLoadFailure(error: e.toString());
    }
  }

}
