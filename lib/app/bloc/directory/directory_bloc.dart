import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../blocs.dart';

export '../../data/directory_repository.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> with OuiSyncAppLogger {
  DirectoryBloc({
    required this.directoryRepository
  }) : super(DirectoryInitial()) {
    on<CreateFolder>(_onCreateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<SaveFile>(_onSaveFile);
    on<RenameEntry>(_onRenameEntry);
    on<MoveEntry>(_onMoveEntry);
    on<DeleteFile>(_onDeleteFile);
    on<NavigateTo>(_onNavigateTo);
    on<GetContent>(_onGetContents);
  }

  final DirectoryRepository directoryRepository;

  Future<void> _onCreateFolder(CreateFolder event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try{
      final createFileResult = await directoryRepository.createFolder(event.repository, event.newFolderPath);
      if (!createFileResult.result) 
      {
        loggy.app('Directory ${event.newFolderPath} creation failed');
        emit(DirectoryLoadFailure());
        return;
      }
    } catch (e, st) {
      loggy.app('Directory ${event.newFolderPath} creation exception', e, st);
      emit(DirectoryLoadFailure());
      return;
    }
    
    await _onNavigateTo(NavigateTo(
      repository: event.repository,
      origin: event.parentPath,
      destination: event.newFolderPath,
      withProgress: true
    ), emit);
  }

  Future<void> _onDeleteFolder(DeleteFolder event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    late final deleteFolderResult;
    try {
      deleteFolderResult = await directoryRepository.deleteFolder(event.repository, event.path, event.recursive);
      if (deleteFolderResult.errorMessage.isNotEmpty) 
      {
        loggy.app('Delete directory ${event.path} failed');
        emit(DirectoryLoadFailure());
        return;
      }
    } catch (e, st) {
      loggy.app('Directory ${event.path} deletion exception', e, st);
      emit(DirectoryLoadFailure());
      return;
    }

    await _updateContens(
      GetContent(
        repository: event.repository,
        path: event.parentPath,
      ),
      emit
    );
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
      final parentPath = extractParentFromPath(event.newFilePath);
      await _updateContens(
        GetContent(
          repository: event.repository,
          path: parentPath,
        ),
        emit
      );

      final file = await File.open(event.repository, event.newFilePath);
      int offset = 0;

      try {
        await for (final buffer in event.fileByteStream) {
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
          filePath: event.newFilePath,
          fileName: event.fileName,
          length: event.length,
          error: e.toString()
        ));
        return;
      } finally {
        loggy.app('Writing to file ${event.newFilePath} done - closing');
        await file.close();
      }

      emit(WriteToFileDone(
        filePath: event.newFilePath,
        fileName: event.fileName,
        length: event.length
      ));
    }
  }

  Future<DirectoryState> _createFile(
    Repository repository,
    String newFilePath,
    String fileName,
    int length
  ) async {
    var createFileResult;
    try {
      createFileResult = await directoryRepository.createFile(repository, newFilePath);
      if (createFileResult.errorMessage.isNotEmpty) {
        loggy.app('Create file $newFilePath failed:\n${createFileResult.errorMessage}');
        
        return CreateFileFailure(
          filePath: newFilePath,
          fileName: fileName,
          length: length,
          error: createFileResult.errorMessage
        );
      }
    } catch (e, st) {
      loggy.app('Create file $newFilePath exception', e, st);
      
      return CreateFileFailure(
        filePath: newFilePath,
        fileName: fileName,
        length: length,
        error: e.toString()
      );
    }

    final name = removeParentFromPath(newFilePath);
    final extension = extractFileTypeFromName(newFilePath);
    return CreateFileDone(
      fileName: name,
      path: newFilePath,
      extension: extension
    );
  }

  Future<void> _onRenameEntry(RenameEntry event, Emitter<DirectoryState> emit) async {
    try {
      final renameEntryResult = await directoryRepository.moveEntry(event.repository, event.entryPath, event.newEntryPath);
      if (renameEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Rename entry from ${event.entryPath} to ${event.newEntryPath} failed:\n${renameEntryResult.errorMessage}');
        emit(DirectoryLoadFailure());
        return;
      }  
    } catch (e, st) {
      loggy.app('Rename entry from ${event.entryPath} to ${event.newEntryPath} exception', e, st);
      emit(DirectoryLoadFailure());
      return;
    }

    await _updateContens(GetContent(
      repository: event.repository,
      path: event.path,
    ), emit);
  }

  Future<void> _onMoveEntry(MoveEntry event, Emitter<DirectoryState> emit) async {
    try {
      final moveEntryResult = await directoryRepository.moveEntry(event.repository, event.entryPath, event.newDestinationPath);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        loggy.app('Move entry from ${event.entryPath} to ${event.newDestinationPath} failed:\n${moveEntryResult.errorMessage}');
        emit(DirectoryLoadFailure());
        return;
      }  
    } catch (e, st) {
      loggy.app('Move entry from ${event.entryPath} to ${event.newDestinationPath} exception', e, st);
      emit(DirectoryLoadFailure());
      return;
    }

    await _updateContens(GetContent(
      repository: event.repository,
      path: event.destination,
    ), emit);
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try{
      final deleteFileResult = await directoryRepository.deleteFile(event.repository, event.filePath);
      if (deleteFileResult.errorMessage.isNotEmpty) 
      {
        loggy.app('Delete file ${event.filePath} failed');
        emit(DirectoryLoadFailure());
        return;
      }
    } catch (e, st) {
      loggy.app('Delete file ${event.filePath} exception', e, st);
      emit(DirectoryLoadFailure());
      return;
    }

    await _updateContens(GetContent(
      repository: event.repository,
      path: event.parentPath,
    ), emit);
  }
  
  Future<void> _onNavigateTo(NavigateTo event, Emitter<DirectoryState> emit) async {
    if (event.withProgress) {
      emit(DirectoryLoadInProgress());
    }

    if (event.repository.accessMode == AccessMode.blind) {
      emit(NavigationLoadBlind(previousAccessMode: event.previousAccessMode));
      return;
    }

    try {
      emit(NavigationLoadSuccess(
        origin: event.origin,
        destination: event.destination,
        contents: await directoryRepository.getFolderContents(event.repository, event.destination)
      ));
    } catch (e,st) {
      loggy.app('Navigate to ${event.destination} exception', e, st);
      emit(NavigationLoadFailure());
    }
  }

  Future<void> _onGetContents(GetContent event, Emitter<DirectoryState> emit) async {
    await _updateContens(event, emit);
  }

  GetContent? _curGetContentEvent;
  GetContent? _nextGetContentEvent;
  Emitter<DirectoryState>? _nextEmit;
  List<Completer> _getContentCompleters = <Completer>[];

  // Trigger content update. If a content update is already in progress, it is scheduled
  // to be done afterwards.
  Future<void> _updateContens(GetContent event, Emitter<DirectoryState> emit) async {
    final completer = Completer<void>();
    final future = completer.future;
    _getContentCompleters.add(completer);

    _nextGetContentEvent = event;
    _nextEmit = emit;

    if (_curGetContentEvent == null) {
      _runUpdateLoop(); // don't await
    }

    return future;
  }

  void _runUpdateLoop() async {
    while (_nextGetContentEvent != null) {
      _curGetContentEvent = _nextGetContentEvent;
      _nextGetContentEvent = null;

      final emit = _nextEmit!;
      _nextEmit = null;

      final completers = _getContentCompleters;
      _getContentCompleters = <Completer>[];

      final state = await _getContents(_curGetContentEvent!);

      _curGetContentEvent = null;

      emit(state);

      for (var completer in completers) {
        completer.complete();
      }
    }
  }

  Future<DirectoryState> _getContents(GetContent event) async {
    try {
      final entries = await directoryRepository.getFolderContents(event.repository, event.path);
      return DirectoryLoadSuccess(path: event.path, contents: entries);
    } catch (e) {
      return DirectoryLoadFailure(error: e.toString());
    }
  }
}
