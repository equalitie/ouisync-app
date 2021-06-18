import 'package:bloc/bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc(NavigationState initialState) : super(initialState);

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is NavigateTo) {
      if (event.destination != state.destinationPath) {
        yield NavigationState(event.origin, event.destination);
      }
    }
  }
  
}