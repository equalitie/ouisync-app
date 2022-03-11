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
    on<ReadFile>(_onReadFile);
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
      type: Navigation.content,
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

    await _getContents(
      GetContent(
        repository: event.repository,
        path: event.path,
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
      await _getContents(
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

  Future<void> _onReadFile(ReadFile event, Emitter<DirectoryState> emit) async {
    emit(DirectoryLoadInProgress());

    late final readFileResult;

    try {
      readFileResult = await directoryRepository.readFile(event.repository, event.filePath, action: event.action);
      if (readFileResult.errorMessage.isNotEmpty) {
        print('Reading file ${event.filePath} failed:\n${readFileResult.errorMessage}');
        emit(DirectoryLoadFailure());
        return;
      }  
    } catch (e) {
      print('Exception reading file ${event.filePath}:\n${e.toString()}');
      emit(DirectoryLoadFailure());
      return;
    }

    emit(DirectoryLoadSuccess(
      path: event.filePath,
      contents: readFileResult.result,
      action: event.action
    ));
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

    await _getContents(GetContent(
      repository: event.repository,
      path: event.destination,
      withProgress: true
    ), emit);
  }

  Future<void> _onDeleteFile(DeleteFile event, Emitter<DirectoryState> emit) async {
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

    await _getContents(GetContent(
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

    var folderContentsResult;
    try {
      folderContentsResult = await directoryRepository.getFolderContents(event.repository, event.destination);
      if (folderContentsResult.errorMessage.isNotEmpty) {
        print('Navigation to ${event.destination} failed:\n${folderContentsResult.errorMessage}');
        emit(NavigationLoadFailure());
        return;
      }
    } catch (e) {
      print('Exception navigating to ${event.destination}:\n${e.toString()}');
      emit(NavigationLoadFailure());
      return;
    }

    emit(NavigationLoadSuccess(
      type: event.type,
      origin: event.origin,
      destination: event.destination,
      contents: folderContentsResult.result
    ));
  }

  Future<void> _onGetContents(GetContent event, Emitter<DirectoryState> emit) async {
    await _getContents(event, emit);
  }

  GetContent? _curGetContentEvent;
  GetContent? _nextGetContentEvent;

  Future<void> _getContents(GetContent event, Emitter<DirectoryState> emit) async {
    if (_curGetContentEvent != null) {
      _nextGetContentEvent = event;
      return;
    }

    _nextGetContentEvent = event;

    while (_nextGetContentEvent != null) {
      _curGetContentEvent = _nextGetContentEvent;
      _nextGetContentEvent = null;

      if (_curGetContentEvent!.withProgress) {
        emit(DirectoryLoadInProgress());
      }

      late final getContentsResult;

      try {
        getContentsResult =
            await directoryRepository.getFolderContents(
                _curGetContentEvent!.repository,
                _curGetContentEvent!.path);

        if (getContentsResult.errorMessage.isNotEmpty) {
          emit(DirectoryLoadFailure());
        } else {
          emit(DirectoryLoadSuccess(
                  path: _curGetContentEvent!.path,
                  contents: getContentsResult.result));
        }
      } catch (e) {
        emit(DirectoryLoadFailure(error: e.toString()));
      }
    }

    _curGetContentEvent = null;
  }
}
