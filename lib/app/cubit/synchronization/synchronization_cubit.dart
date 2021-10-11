import 'package:bloc/bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../data/data.dart';
import '../synchronization_state.dart';

class SynchronizationCubit extends Cubit<SynchronizationState> {
  SynchronizationCubit() : super(SynchronizationInitial());

  void sync(Repository repository, String path) async {
    try {
      final directoryRepository = DirectoryRepository();
      final getContentsResult = await directoryRepository.getFolderContents(repository, path);
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
