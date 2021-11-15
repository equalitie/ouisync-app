import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/models/models.dart';

class UpdateRouteStateFake 
  extends Fake
  implements UpdateRoute, Equatable {
    @override
    List<Object> get props => [
      path,
      action
    ];}

late FolderItem dummyFolderItem;
void main() {
  setUpAll(() {
    registerFallbackValue<RouteEvent>(UpdateRouteStateFake());

    dummyFolderItem = FolderItem(
      name: 'test',
      path: '/test',
      items: <BaseItem>[]
    );
  });
  // TODO: Expand this test suite
  blocTest('Emits a list of widgets representing the path',
    build: () => RouteBloc(),
    act: (RouteBloc bloc) => bloc.add(UpdateRoute(path: '/uno', action: () {})),
    expect: () => [isA<RouteLoadSuccess>()],
  );
}