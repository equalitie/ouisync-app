import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';
import '../blocs.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    required this.repository
  }) : super(DirectoryInitial());

  final DirectoryRepository repository;

  @override
  Stream<DirectoryState> mapEventToState(DirectoryEvent event) async* {
    if (event is CreateFolder) {
      yield DirectoryLoadInProgress();

      yield await createFolder(event.parentPath, event.newFolderPath);
    }

    if (event is GetContent) {
      if (event.withProgress) {
        yield DirectoryLoadInProgress(); 
      }

      if (event.isSyncing) {
        yield SyncingInProgress();
      }
      
      yield await getFolderContents(event.path, isSyncing: event.isSyncing);
    }

    if (event is DeleteFolder) {
      yield DirectoryLoadInProgress();

      yield await deleteFolder(event.path, event.parentPath);
    }

    if (event is NavigateTo) {
      if (event.withProgress) {
        yield DirectoryLoadInProgress(); 
      }

      yield await navigateTo(event.type, event.origin, event.destination);
    }

    if (event is CreateFile) {
      yield DirectoryLoadInProgress();

      yield await createFile(event.newFilePath, event.fileByteStream, event.parentPath);
    }

    if (event is ReadFile) {
      yield DirectoryLoadInProgress();
      
      yield await readFile(event.filePath, event.action);
    }

    if (event is DeleteFile) {
      yield DirectoryLoadInProgress();

      yield await deleteFile(event.filePath, event.parentPath);
    }
  }

  Future<DirectoryState> createFolder(String origin, String newFolderPath) async {
    try{
      final createFileResult = await this.repository.createFolder(newFolderPath);
      if (!createFileResult.result) 
      {
        print('The new directory ($newFolderPath) could not be created.');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception creating a new directory ($newFolderPath):\n${e.toString()}');
      return DirectoryLoadFailure();
    }
    
    return await navigateTo(Navigation.content, origin, newFolderPath);
  }

  Future<DirectoryState> getFolderContents(String path, {bool isSyncing = false}) async {
    late final getContentsResult;

    try {
      getContentsResult = await this.repository.getFolderContents(path);
      if (getContentsResult.errorMessage.isNotEmpty) {
        print('Get contents in folder $path failed:\n${getContentsResult.errorMessage}');
        return DirectoryLoadFailure(isSyncing: isSyncing);
      }
    } catch (e) {
      print('Exception getting contents for $path:\n${e.toString()}');
      return DirectoryLoadFailure();
    }
    
    return DirectoryLoadSuccess(contents: getContentsResult.result, isSyncing: isSyncing);
  }

  Future<DirectoryState> deleteFolder(String path, String parentPath) async {
    late final deleteFolderResult;

    try {
      deleteFolderResult = await this.repository.deleteFolder(path);
      if (deleteFolderResult.errorMessage.isNotEmpty) 
      {
        print('The folder ($path) could not be deleted.');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception deleting the folder $path:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return await getFolderContents(parentPath);
  }

  Future<DirectoryState> navigateTo(Navigation type, String origin, String destination) async {
    late final folderContentsResult;

    try {
      folderContentsResult = await this.repository.getFolderContents(destination);

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

  Future<DirectoryState> createFile(String newFilePath, Stream<List<int>> fileByteStream, String parentPath) async {
    try {
      final createFileResult = await this.repository.createFile(newFilePath);
      if (createFileResult.errorMessage.isNotEmpty) {
        if (createFileResult.errorMessage != 'File exists') {
          print('File $newFilePath creation failed:\n${createFileResult.errorMessage}');
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
      final writeFileResult = await this.repository.writeFile(newFilePath, fileByteStream);
      if (writeFileResult.errorMessage.isNotEmpty) {
        print('Writing to the file $newFilePath failed:\n${writeFileResult.errorMessage}');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception writing to file $newFilePath:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return await getFolderContents(parentPath);
  }

  Future<DirectoryState> readFile(String filePath, String action) async {
    late final readFileResult;

    try {
      readFileResult = await repository.readFile(filePath, action: action);
      if (readFileResult.errorMessage.isNotEmpty) {
        print('Reading file $filePath failed:\n${readFileResult.errorMessage}');
        return DirectoryLoadFailure();
      }  
    } catch (e) {
      print('Exception reading file $filePath:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return DirectoryLoadSuccess(contents: readFileResult.result, action: action);
  }

  Future<DirectoryState> deleteFile(String filePath, String parentPath) async {
    try{
      final deleteFileResult = await this.repository.deleteFile(filePath);
      if (deleteFileResult.errorMessage.isNotEmpty) 
      {
        print('The file ($filePath) could not be deleted.');
        return DirectoryLoadFailure();
      }
    } catch (e) {
      print('Exception deleting the file $filePath:\n${e.toString()}');
      return DirectoryLoadFailure();
    }

    return await getFolderContents(parentPath);
  }
}