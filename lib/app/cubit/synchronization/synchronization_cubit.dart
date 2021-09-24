import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/data.dart';

part 'synchronization_state.dart';

class SynchronizationCubit extends Cubit<SynchronizationState> {
  SynchronizationCubit({
    required this.repository
  }) : super(SynchronizationInitial());

  final DirectoryRepository repository;

  void sync(String path) async {
    try {
      final getContentsResult = await this.repository.getFolderContents(path);
      if (getContentsResult.errorMessage.isNotEmpty) {
        print('Get contents in folder $path failed:\n${getContentsResult.errorMessage}');
        emit(SynchronizationFailure());
      }

      emit(SynchronizationNotification(contents: getContentsResult.result));

    } catch (e) {
      print('Exception getting the directory\'s $path contents:\n${e.toString()}');
      emit(SynchronizationFailure());
    }
  }
}
