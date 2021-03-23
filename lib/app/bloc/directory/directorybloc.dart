import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/directoryrepository.dart';
import '../../models/models.dart';
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
    if (event is FolderCreate) {
      yield DirectoryLoadInProgress();

      try{
        bool creationOk = await repository.createFolder(event.repoPath, event.newFolderRelativePath);
        if (creationOk) {
          final List<BaseItem> contents = await repository.getContents(event.repoPath, event.parentPath);
          yield DirectoryLoadSuccess(contents: contents);  
        }
        else {
          print('The new directory (${event.newFolderRelativePath}) could not be created in repository ${event.repoPath}');
          yield DirectoryLoadFailure();
        }
      } catch (e) {
        print('Exception creating a new directory (${event.newFolderRelativePath}) in repository ${event.repoPath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }

    if (event is ContentRequest) {
      yield DirectoryLoadInProgress();
      
      try {
        final List<BaseItem> contents = await repository.getContents(event.repoPath, event.folderRelativePath);
        yield DirectoryLoadSuccess(contents: contents);
      } catch (e) {
        print('Exception getting the directory\'s ${event.folderRelativePath} contents in repository ${event.repoPath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }
  }
}