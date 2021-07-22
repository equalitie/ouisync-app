import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/models/models.dart';

import '../../utils/actions.dart';
import '../../utils/utils.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc({
    required this.bloc
  }) : super(RouteInitial());

  final Bloc bloc;

  @override
  Stream<RouteState> mapEventToState(
    RouteEvent event,
  ) async* {
    if (event is UpdateRoute) {
      final routeList = <Widget>[ buildRouteSection(bloc, slash, slash, event.data) ];

      if (event.path != slash) {
        final pathMap = getPathMap(event.path);
        pathMap.forEach((parentPath, destinationPath) {
          final sectionWidget = buildRouteSection(bloc, parentPath, destinationPath, event.data);
          routeList.add(sectionWidget);

          if (destinationPath != slash) {
            routeList.add(slashWidget()); 
          }
        }); 
      }

      final routeWidget = buildRoute(routeList);
      yield RouteLoadSuccess(path: event.path, route: routeWidget);
    }
  }
}