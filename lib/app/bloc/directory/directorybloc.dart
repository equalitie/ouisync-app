import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/directoryrepository.dart';
import 'directoryevent.dart';
import 'directorystate.dart';


class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    @required this.repository
  }) : 
  assert(repository != null),
  super(DirectoryInitial());

  final DirectoryRepository repository;

  @override
  Stream<DirectoryState> mapEventToState(DirectoryEvent event) async* {
    if (event is RequestContent) {
      yield DirectoryLoadInProgress();
      
      try {
        yield await _getFolderContents(event.repoPath, event.folderRelativePath);

      } catch (e) {
        print('Exception getting the directory\'s ${event.folderRelativePath} contents in repository ${event.repoPath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is CreateFolder) {
      yield DirectoryLoadInProgress();

      try{
        final createFileResult = await repository.createFolder(event.repoPath, event.newFolderRelativePath);
        if (!createFileResult.result) 
        {
          print('The new directory (${event.newFolderRelativePath}) could not be created in repository ${event.repoPath}');
          yield DirectoryLoadFailure();

          return;
        }

        yield await _getFolderContents(event.repoPath, event.parentPath);

      } catch (e) {
        print('Exception creating a new directory (${event.newFolderRelativePath}) in repository ${event.repoPath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is CreateFile) {
      yield DirectoryLoadInProgress();

      try {
        final createFileResult = await repository.createFile(event.repoPath, event.newFileRelativePath);
        if (createFileResult.errorMessage.isNotEmpty) {
          if (createFileResult.errorMessage != 'File exists') {
            print('File ${event.newFileRelativePath} creation in repository ${event.repoPath} failed:\n${createFileResult.errorMessage}');
            yield DirectoryLoadFailure();

            return;  
          }
          
          print('The file ${event.newFileRelativePath} already exist.');    
        }

        final writeFileResult = await repository.writeFile(event.repoPath, event.newFileRelativePath, event.fileStream);
        if (writeFileResult.errorMessage.isNotEmpty) {
          print('Writing to the file ${event.newFileRelativePath} failed:\n${writeFileResult.errorMessage}');
          yield DirectoryLoadFailure();

          return;
        }

        yield await _getFolderContents(event.repoPath, event.parentPath);
        
      } catch (e) {
        print('Exception creating file ${event.newFileRelativePath} in repository ${event.newFileRelativePath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is ReadFile) {
      await repository.readFile(event.repoPath, event.fileRelativePath, event.totalBytes);
    }
  }

  Future<DirectoryState> _getFolderContents(String repositoryPath, String folderPath) async {
    final getContentsResult = await repository.getContents(repositoryPath, folderPath);
    if (getContentsResult.errorMessage.isNotEmpty) {
      print('Get contents in folder $folderPath failed:\n${getContentsResult.errorMessage}');
      return DirectoryLoadFailure();
    }

    return DirectoryLoadSuccess(contents: getContentsResult.result);
  }
}