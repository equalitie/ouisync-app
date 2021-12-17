import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../data/data.dart';
import '../blocs.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    required this.directoryRepository
  }) : super(DirectoryInitial());

  final DirectoryRepository directoryRepository;

  @override
  Stream<DirectoryState> mapEventToState(DirectoryEvent event) async* {
    if (event is CreateFolder) {
      yield DirectoryLoadInProgress();

      yield await createFolder(event.repository, event.parentPath, event.newFolderPath);
    }

    if (event is GetContent) {
      if (event.withProgress) {
        yield DirectoryLoadInProgress(); 
      }

      if (event.isSyncing) {
        yield SyncingInProgress();
      }
      
      yield await getFolderContents(event.repository, event.path, isSyncing: event.isSyncing);
    }

    if (event is DeleteFolder) {
      yield DirectoryLoadInProgress();

      yield await deleteFolder(event.repository, event.path, event.parentPath, event.recursive);
    }

    if (event is NavigateTo) {
      if (event.withProgress) {
        yield DirectoryLoadInProgress(); 
      }

      yield await navigateTo(event.repository, event.type, event.origin, event.destination);
    }

    if (event is CreateFile) {
      yield DirectoryLoadInProgress();

      yield await createFile(event.repository, event.newFilePath, event.fileByteStream, event.parentPath);
    }

    if (event is ReadFile) {
      yield DirectoryLoadInProgress();
      
      yield await readFile(event.repository, event.filePath, event.action);
    }

    if (event is MoveEntry) {
      yield DirectoryLoadInProgress();

      yield await moveEntry(event.repository, event.origin, event.destination, event.entryPath, event.newDestinationPath);
    }

    if (event is DeleteFile) {
      yield DirectoryLoadInProgress();

      yield await deleteFile(event.repository, event.filePath, event.parentPath);
    }
  }

  Future<DirectoryState> createFolder(Repository repository, String origin, String newFolderPath) async {
    try{
      final createFileResult = await directoryRepository.createFolder(repository, newFolderPath);
      if (!createFileResult.result) 
      {
        print('The new directory ($newFolderPath) could not be created.');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception creating a new directory ($newFolderPath):\n${e.toString()}');
      return DirectoryLoadFailure();
    }
    
    return await navigateTo(repository, Navigation.content, origin, newFolderPath);
  }

  Future<DirectoryState> getFolderContents(Repository repository, String path, {bool isSyncing = false}) async {
    late final getContentsResult;

    try {
      getContentsResult = await directoryRepository.getFolderContents(repository, path);
      if (getContentsResult.errorMessage.isNotEmpty) {
        print('Get contents in folder $path failed:\n${getContentsResult.errorMessage}');
        return DirectoryLoadFailure(isSyncing: isSyncing);
      }
    } catch (e) {
      print('Exception getting contents for $path:\n${e.toString()}');
      return DirectoryLoadFailure();
    }
    
    return DirectoryLoadSuccess(path:  path, contents: getContentsResult.result, isSyncing: isSyncing);
  }

  Future<DirectoryState> deleteFolder(Repository repository, String path, String parentPath, bool recursive) async {
    late final deleteFolderResult;

    try {
      deleteFolderResult = await directoryRepository.deleteFolder(repository, path, recursive);
      if (deleteFolderResult.errorMessage.isNotEmpty) 
      {
        print('The folder ($path) could not be deleted.');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception deleting the folder $path:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return await getFolderContents(repository, parentPath);
  }

  Future<DirectoryState> navigateTo(Repository repository, Navigation type, String origin, String destination) async {
    var folderContentsResult;

    try {
      folderContentsResult = await directoryRepository.getFolderContents(repository, destination);
      if (folderContentsResult.errorMessage.isNotEmpty) {
        print('Navigation to $destination failed:\n${folderContentsResult.errorMessage}');
        return  NavigationLoadFailure();
      }
    } catch (e) {
      print('Exception navigating to $destination:\n${e.toString()}');
      return NavigationLoadFailure();
    }

    return NavigationLoadSuccess(
        type: type,
        origin: origin,
        destination: destination,
        contents: folderContentsResult.result
      );
  }

  Future<DirectoryState> createFile(Repository repository, String newFilePath, Stream<List<int>> fileByteStream, String parentPath) async {
    try {
      final createFileResult = await directoryRepository.createFile(repository, newFilePath);
      if (createFileResult.errorMessage.isNotEmpty) {
        if (createFileResult.errorMessage != 'File exists') {
          print('File $newFilePath creation failed:\n${createFileResult.errorMessage}');
          // ignore: todo
          // TODO: Make a validation using the library function instead of guessing
          print('The file $newFilePath already exist.');    
          return DirectoryLoadFailure();
        }
      }
    } catch (e) {
      print('Exception creating file $newFilePath:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    try {
      final writeFileResult = await directoryRepository.writeFile(repository, newFilePath, fileByteStream);
      if (writeFileResult.errorMessage.isNotEmpty) {
        print('Writing to the file $newFilePath failed:\n${writeFileResult.errorMessage}');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception writing to file $newFilePath:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return await getFolderContents(repository, parentPath);
  }

  Future<DirectoryState> readFile(Repository repository, String filePath, String action) async {
    late final readFileResult;

    try {
      readFileResult = await directoryRepository.readFile(repository, filePath, action: action);
      if (readFileResult.errorMessage.isNotEmpty) {
        print('Reading file $filePath failed:\n${readFileResult.errorMessage}');
        return DirectoryLoadFailure();
      }  
    } catch (e) {
      print('Exception reading file $filePath:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return DirectoryLoadSuccess(path: filePath, contents: readFileResult.result, action: action);
  }

  Future<DirectoryState> moveEntry(Repository repository, String origin, String destination, String entryPath, String newDestinationPath) async {
    try {
      final moveEntryResult = await directoryRepository.moveEntry(repository, entryPath, newDestinationPath);
      if (moveEntryResult.errorMessage.isNotEmpty) {
        print('Moving entry from $entryPath to $newDestinationPath failed:\n${moveEntryResult.errorMessage}');
        return DirectoryLoadFailure();
      }  
    } catch (e) {
      print('Exception moving entry from $entryPath to $newDestinationPath :\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return await getFolderContents(repository, destination);
  }

  Future<DirectoryState> deleteFile(Repository repository, String filePath, String parentPath) async {
    try{
      final deleteFileResult = await directoryRepository.deleteFile(repository, filePath);
      if (deleteFileResult.errorMessage.isNotEmpty) 
      {
        print('The file ($filePath) could not be deleted.');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception deleting the file $filePath:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return await getFolderContents(repository, parentPath);
  }
}