import 'package:bloc/bloc.dart';

import '../blocs.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc({
    required this.rootPath
  }) : super(NavigationInitial());

  final String rootPath;

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is NavigateTo) {
      yield NavigationLoadSuccess(
        type: event.type,
        origin: event.origin,
        destination: event.destination
      );
    }
  }
  
}