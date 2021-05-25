import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../data/data.dart';
import '../blocs.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    @required this.repository
  }) : super(DirectoryInitial());

  final DirectoryRepository repository;

  @override
  Stream<DirectoryState> mapEventToState(DirectoryEvent event) async* {
    if (event is RequestContent) {
      yield DirectoryLoadInProgress();
      
      try {
        yield await _getFolderContents(event.repository, event.path, event.recursive);

      } catch (e) {
        print('Exception getting the directory\'s ${event.path} contents in repository ${event.repository}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is CreateFolder) {
      yield DirectoryLoadInProgress();

      try{
        final createFileResult = await this.repository.createFolder(event.repository, event.newFolderPath);
        if (!createFileResult.result) 
        {
          print('The new directory (${event.newFolderPath}) could not be created in repository ${event.repository}');
          yield DirectoryLoadFailure();

          return;
        }

        yield await _getFolderContents(event.repository, event.parentPath, false);

      } catch (e) {
        print('Exception creating a new directory (${event.newFolderPath}) in repository ${event.repository}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is CreateFile) {
      yield DirectoryLoadInProgress();

      try {
        final createFileResult = await this.repository.createFile(event.repository, event.newFilePath);
        if (createFileResult.errorMessage.isNotEmpty) {
          if (createFileResult.errorMessage != 'File exists') {
            print('File ${event.newFilePath} creation in repository ${event.repository} failed:\n${createFileResult.errorMessage}');
            yield DirectoryLoadFailure();

            return;  
          }
          
          print('The file ${event.newFilePath} already exist.');    
        }

        final writeFileResult = await this.repository.writeFile(event.repository, event.newFilePath, event.fileByteStream);
        if (writeFileResult.errorMessage.isNotEmpty) {
          print('Writing to the file ${event.newFilePath} failed:\n${writeFileResult.errorMessage}');
          yield DirectoryLoadFailure();

          return;
        }

        yield await _getFolderContents(event.repository, event.parentPath, false);
        
      } catch (e) {
        print('Exception creating file ${event.newFilePath} in repository ${event.newFilePath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is ReadFile) {
      await repository.readFile(event.repository, event.filePath);
    }
  }

  Future<DirectoryState> _getFolderContents(Repository repository, String folderPath, bool recursive) async {
    final getContentsResult = await this.repository.getContents(repository, folderPath, recursive);
    if (getContentsResult.errorMessage.isNotEmpty) {
      print('Get contents in folder $folderPath failed:\n${getContentsResult.errorMessage}');
      return DirectoryLoadFailure();
    }

    return DirectoryLoadSuccess(contents: getContentsResult.result);
  }
}