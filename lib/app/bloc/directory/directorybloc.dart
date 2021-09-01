import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';
import '../blocs.dart';

class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    required this.blocRepository
  }) : super(DirectoryInitial());

  final DirectoryRepository blocRepository;

  @override
  Stream<DirectoryState> mapEventToState(DirectoryEvent event) async* {
    if (event is CreateFolder) {
      yield DirectoryLoadInProgress();

      try{
        final createFileResult = await this.blocRepository.createFolder(event.newFolderPath);
        if (!createFileResult.result) 
        {
          print('The new directory (${event.newFolderPath}) could not be created.');
          yield DirectoryLoadFailure();

          return;
        }

        yield await getFolderContents(event.parentPath);

      } catch (e) {
        print('Exception creating a new directory (${event.newFolderPath}):\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is RequestContent) {
      if (event.withProgressIndicator) {
        yield DirectoryLoadInProgress(); 
      }
      
      try {
        yield await getFolderContents(event.path);

      } catch (e) {
        print('Exception getting the directory\'s ${event.path} contents:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is DeleteFolder) {
      yield DirectoryLoadInProgress();

      try{
        final deleteFolderResult = await this.blocRepository.deleteFolder(event.path);
        if (deleteFolderResult.errorMessage.isNotEmpty) 
        {
          print('The folder (${event.path}) could not be deleted.');
          yield DirectoryLoadFailure();

          return;
        }

        yield await getFolderContents(event.parentPath);

      } catch (e) {
        print('Exception deleting the folder ${event.path}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is CreateFile) {
      yield DirectoryLoadInProgress();

      try {
        final createFileResult = await this.blocRepository.createFile(event.newFilePath);
        if (createFileResult.errorMessage.isNotEmpty) {
          if (createFileResult.errorMessage != 'File exists') {
            print('File ${event.newFilePath} creation failed:\n${createFileResult.errorMessage}');
            yield DirectoryLoadFailure();

            return;  
          }
          // TODO: Make a validation using the library function instead of guessing
          print('The file ${event.newFilePath} already exist.');    
        }

        final writeFileResult = await this.blocRepository.writeFile(event.newFilePath, event.fileByteStream);
        if (writeFileResult.errorMessage.isNotEmpty) {
          print('Writing to the file ${event.newFilePath} failed:\n${writeFileResult.errorMessage}');
          yield DirectoryLoadFailure();

          return;
        }

        yield await getFolderContents(event.parentPath);
        
      } catch (e) {
        print('Exception creating file ${event.newFilePath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is ReadFile) {
      yield DirectoryLoadInProgress();
      
      final readFileResult = await blocRepository.readFile(event.filePath, action: event.action);
      if (readFileResult.errorMessage.isNotEmpty) {
        print('Reading file ${event.filePath} failed:\n${readFileResult.errorMessage}');
        yield DirectoryLoadFailure();

        return;
      }

      yield DirectoryLoadSuccess(contents: readFileResult.result, action: event.action);
    }

    if (event is DeleteFile) {
      yield DirectoryLoadInProgress();

      try{
        final deleteFileResult = await this.blocRepository.deleteFile(event.filePath);
        if (deleteFileResult.errorMessage.isNotEmpty) 
        {
          print('The file (${event.filePath}) could not be deleted.');
          yield DirectoryLoadFailure();

          return;
        }

        yield await getFolderContents(event.parentPath);

      } catch (e) {
        print('Exception deleting the file ${event.filePath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }
  }

  Future<DirectoryState> getFolderContents(String path) async {
    final getContentsResult = await this.blocRepository.getFolderContents(path);
    if (getContentsResult.errorMessage.isNotEmpty) {
      print('Get contents in folder $path failed:\n${getContentsResult.errorMessage}');
      return DirectoryLoadFailure();
    }

    return DirectoryLoadSuccess(contents: getContentsResult.result);
  }
}