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
      yield RouteLoadSuccess(
        path: event.path,
        route: _currentLocationBar(event.path, event.action)
        );
    }
  }

  Widget _currentLocationBar(String path, Function action) {
    final current = removeParentFromPath(path);
    return Padding(
      padding: EdgeInsets.only(left: 10.0, bottom: 5.0, right: 10.0),
      child: Row(
        children: [
          _navigation(path, action),
          SizedBox(
            width: path == slash
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
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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
      child: path == slash
      ? const Icon(
          Icons.folder_rounded,
          size: 30.0,
        )
      : const Icon(
          Icons.arrow_back,
          size: 30.0,
        ),
    );
  }
}