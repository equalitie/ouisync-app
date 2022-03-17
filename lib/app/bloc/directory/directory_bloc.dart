import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

export '../../data/directory_repository.dart';
import '../../utils/utils.dart';
import '../blocs.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    required this.directoryRepository
  }) : super(DirectoryInitial()) {
    on<CreateFolder>(_onCreateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<SaveFile>(_onSaveFile);
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
        print('The new directory ($event.newFolderPath) could not be created.');
        emit(DirectoryLoadFailure());
        return;
      }
    } catch (e) {
      print('Exception creating a new directory ($event.newFolderPath):\n${e.toString()}');
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
        print('The folder (${event.path}) could not be deleted.');
        emit(DirectoryLoadFailure());
        return;
      }
    } catch (e) {
      print('Exception deleting the folder ${event.path}:\n${e.toString()}');
      emit(DirectoryLoadFailure());
      return;
    }

    await _updateContens(
      GetContent(
        repository: event.repository,
        path: event.parentPath,
        withProgress: true
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
          withProgress: true
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
      } catch (e) {
        print('Exception writing the file ${event.newFilePath}:\n${e.toString()}');
        emit(WriteToFileFailure(
          filePath: event.newFilePath,
          fileName: event.fileName,
          length: event.length,
          error: e.toString()
        ));
        return;
      } finally {
        print('Writing file ${event.newFilePath} done - closing');
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
        print('File $newFilePath creation failed:\n${createFileResult.errorMessage}');
        
        return CreateFileFailure(
          filePath: newFilePath,
          fileName: fileName,
          length: length,
          error: createFileResult.errorMessage
        );
      }
    } catch (e) {
      print('Exception creating file $newFilePath:\n${e.toString()}');
      
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

 Future<void> _onMoveEntry(MoveEntry event, Emitter<DirectoryState> emit) async {
    try {
      final moveEntryResult = await directoryRepository.moveEntry(event.repository, event.entryPath, event.newDestinationPath);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        print('Moving entry from ${event.entryPath} to ${event.newDestinationPath} failed:\n${moveEntryResult.errorMessage}');
        emit(DirectoryLoadFailure());
        return;
      }  
    } catch (e) {
      print('Exception moving entry from ${event.entryPath} to ${event.newDestinationPath} :\n${e.toString()}');
      emit(DirectoryLoadFailure());
      return;
    }

    await _updateContens(GetContent(
      repository: event.repository,
      path: event.destination,
      withProgress: true
    ), emit);
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    try{
      final deleteFileResult = await directoryRepository.deleteFile(event.repository, event.filePath);
      if (deleteFileResult.errorMessage.isNotEmpty) 
      {
        print('The file (${event.filePath}) could not be deleted.');
        emit(DirectoryLoadFailure());
        return;
      }
    } catch (e) {
      print('Exception deleting the file ${event.filePath}:\n${e.toString()}');
      emit(DirectoryLoadFailure());
      return;
    }

    await _updateContens(GetContent(
      repository: event.repository,
      path: event.parentPath,
      withProgress: true
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

    var entries;
    try {
      entries = await directoryRepository.getFolderContents(event.repository, event.destination);
    } catch (e) {
      print('Exception navigating to ${event.destination}:\n${e.toString()}');
      emit(NavigationLoadFailure());
      return;
    }

    emit(NavigationLoadSuccess(
      origin: event.origin,
      destination: event.destination,
      contents: entries
    ));
  }

  Future<void> _onGetContents(GetContent event, Emitter<DirectoryState> emit) async {
    await _updateContens(event, emit);
  }

  GetContent? _curGetContentEvent;
  GetContent? _nextGetContentEvent;
  List<Completer> _getContentCompleters = <Completer>[];

  // Trigger content update. If a content update is already in progress, it is scheduled
  // to be done afterwards.
  Future<void> _updateContens(GetContent event, Emitter<DirectoryState> emit) async {
    final completer = Completer<void>();
    final future = completer.future;
    _getContentCompleters.add(completer);

    if (_curGetContentEvent != null) {
      _nextGetContentEvent = event;
      return future;
    }

    _nextGetContentEvent = event;

    _runUpdateLoop(emit); // don't await

    return future;
  }

  void _runUpdateLoop(Emitter<DirectoryState> emit) async {
    while (_nextGetContentEvent != null) {
      _curGetContentEvent = _nextGetContentEvent;
      _nextGetContentEvent = null;

      final completers = _getContentCompleters;
      _getContentCompleters = <Completer>[];

      final state = await _getContents(_curGetContentEvent!);

      _curGetContentEvent = null;

      for (var completer in completers) {
        completer.complete();
      }

      emit(state);
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
