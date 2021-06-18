import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';


class MockNavigationBloc 
  extends MockBloc<NavigationEvent, NavigationState> 
  implements NavigationBloc {}

class NavigationStateFake extends Fake implements NavigationEvent {}
void main() {
  setUpAll(() {
    registerFallbackValue(NavigationStateFake());
  });

  navigationBloc();
}

void navigationBloc() {
  group('NavigationBloc', () {
    blocTest<NavigationBloc, NavigationState>(
      'Emits a navigation event to /uno from /',
      build: () => NavigationBloc(NavigationState('/', '/')),
      act: (bloc) => bloc.add(NavigateTo('/', '/uno')),
      expect: () => [const NavigationState('/', '/uno')],
    );
  });
}