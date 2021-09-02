import 'package:bloc/bloc.dart';
import 'package:ouisync_app/app/data/data.dart';

import '../blocs.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc({
    required this.directoryRepository
  }) : super(NavigationInitial());

  final DirectoryRepository directoryRepository;

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is NavigateTo) {
      yield NavigationLoadInProgress();

      try {
        final folderContentsResult = 
          await this.directoryRepository
          .getFolderContents(event.destination);

        if (folderContentsResult.errorMessage.isNotEmpty) {
          print('Get contents in folder $event.destination failed:\n${folderContentsResult.errorMessage}');
          yield NavigationLoadFailure();
        }

        yield NavigationLoadSuccess(
          type: event.type,
          origin: event.origin,
          destination: event.destination,
          contents: folderContentsResult.result
        );
      } catch (e) {
        print('Exception getting the directory\'s ${event.destination} contents:\n${e.toString()}');
        yield NavigationLoadFailure();
      }
    }
  }
}