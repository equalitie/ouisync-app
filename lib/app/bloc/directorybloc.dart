import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/directoryevent.dart';
import 'package:ouisync_app/app/bloc/directorystate.dart';
import 'package:ouisync_app/app/data/repositories/directoryrepository.dart';
import 'package:ouisync_app/app/models/models.dart';


class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({
    @required this.repository
  }) : assert(repository != null), super(DirectoryInitial());

  final DirectoryRepository repository;

  @override
  Stream<DirectoryState> mapEventToState(DirectoryEvent event) async* {
    if (event is ContentRequest) {
      yield DirectoryLoadInProgress();
      try {
        final List<BaseItem> contents = await repository.getContents(event.repoPath, event.folderPath);
        yield DirectoryLoadSuccess(contents: contents);
      } catch (e) {
        print('Exception getting the directory\'s ${event.folderPath} contents in repository ${event.repoPath}:\n${e.toString()}');
        yield DirectoryLoadFailure();
      }
    }
  }
}