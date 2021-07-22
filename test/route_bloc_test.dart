import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_app/app/models/models.dart';

import 'start_ouisync_test.mocks.dart';

class UpdateRouteStateFake 
  extends Fake
  implements UpdateRoute, Equatable {
    @override
    List<Object> get props => [
      path,
    ];
  }

late FolderItem dummyFolderItem;
void main() {
  setUpAll(() {
    registerFallbackValue<RouteEvent>(UpdateRouteStateFake());

    dummyFolderItem = FolderItem(
      name: 'test',
      path: '/test',
      creationDate: DateTime.now(),
      lastModificationDate: DateTime.now(),
      items: <BaseItem>[]
    );
  });

  routeBloc();
}

void routeBloc() {
  final navBloc = MockNavigationBloc();
  blocTest<RouteBloc, RouteState>(
    'Emits a list of widgets representing the path',
    build: () => RouteBloc(bloc: navBloc),
    act: (bloc) => bloc.add(UpdateRoute(path: '/uno', data: dummyFolderItem)),
    expect: () => [RouteLoadSuccess(path: '/uno', route: Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 2.0)))],
  );
}