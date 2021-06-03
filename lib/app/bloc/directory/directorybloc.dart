import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

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
        final createFileResult = await this.blocRepository.createFolder(event.session, event.newFolderPath);
        if (!createFileResult.result) 
        {
          print('The new directory (${event.newFolderPath}) could not be created in repository ${event.session}');
          yield DirectoryLoadFailure();

          return;
        }

        yield await _getFolderContents(event.session, event.parentPath, false);

      } catch (e) {
        print('Exception creating a new directory (${event.newFolderPath}) in repository ${event.session}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is RequestContent) {
      yield DirectoryLoadInProgress();
      
      try {
        yield await _getFolderContents(event.session, event.path, event.recursive);

      } catch (e) {
        print('Exception getting the directory\'s ${event.path} contents in repository ${event.session}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is CreateFile) {
      yield DirectoryLoadInProgress();

      try {
        final createFileResult = await this.blocRepository.createFile(event.session, event.newFilePath);
        if (createFileResult.errorMessage.isNotEmpty) {
          if (createFileResult.errorMessage != 'File exists') {
            print('File ${event.newFilePath} creation in repository ${event.session} failed:\n${createFileResult.errorMessage}');
            yield DirectoryLoadFailure();

            return;  
          }
          
          print('The file ${event.newFilePath} already exist.');    
        }

        final writeFileResult = await this.blocRepository.writeFile(event.session, event.newFilePath, event.fileByteStream);
        if (writeFileResult.errorMessage.isNotEmpty) {
          print('Writing to the file ${event.newFilePath} failed:\n${writeFileResult.errorMessage}');
          yield DirectoryLoadFailure();

          return;
        }

        yield await _getFolderContents(event.session, event.parentPath, false);
        
      } catch (e) {
        print('Exception creating file ${event.newFilePath} in repository ${event.newFilePath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is ReadFile) {
      yield DirectoryLoadInProgress();
      
      final readFileResult = await blocRepository.readFile(event.session, event.filePath);
      if (readFileResult.errorMessage.isNotEmpty) {
        print('Reading file ${event.filePath} failed:\n${readFileResult.errorMessage}');
        yield DirectoryLoadFailure();

        return;
      }

      yield DirectoryLoadSuccess(contents: readFileResult.result);
    }
  }

  Future<DirectoryState> _getFolderContents(Session session, String folderPath, bool recursive) async {
    final getContentsResult = await this.blocRepository.getContents(session, folderPath, recursive);
    if (getContentsResult.errorMessage.isNotEmpty) {
      print('Get contents in folder $folderPath failed:\n${getContentsResult.errorMessage}');
      return DirectoryLoadFailure();
    }

    return DirectoryLoadSuccess(contents: getContentsResult.result);
  }
}