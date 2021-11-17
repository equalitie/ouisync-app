import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';

void main() {
  // TODO: Expand this test suite
  blocTest('Emits a list of widgets representing the path',
    build: () => RouteBloc(),
    act: (RouteBloc bloc) => bloc.add(UpdateRoute(path: '/uno', action: () {})),
    expect: () => [isA<RouteLoadSuccess>()],
  );
}