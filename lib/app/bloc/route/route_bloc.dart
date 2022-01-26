import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/utils.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(RouteInitial());

  @override
  Stream<RouteState> mapEventToState(
    RouteEvent event,
  ) async* {
    if (event is UpdateRoute) {
      yield RouteLoadSuccess(
        path: event.path,
        route: _currentLocationBar(event.path, event.action)
        );
    }
  }

  Widget _currentLocationBar(String path, Function action) {
    final current = removeParentFromPath(path);
    return Row(
      children: [
        _navigation(path, action),
        SizedBox(
          width: path == Strings.rootPath
          ? 5.0
          : 0.0
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              '$current',
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Dimensions.fontAverage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _navigation(String path, Function action) {
    final target = extractParentFromPath(path);

    return GestureDetector(
      onTap: () {
        if (target != path) {
          action.call();
        }
      },
      child: path == Strings.rootPath
      ? const Icon(
          Icons.lock_rounded,
          size: 30.0,
        )
      : const Icon(
          Icons.arrow_back,
          size: 30.0,
        ),
    );
  }
}