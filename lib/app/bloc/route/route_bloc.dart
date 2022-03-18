import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/actions.dart';
import '../../utils/strings.dart';
import '../../utils/dimensions.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(RouteInitial()){
    on<UpdateRoute>((event, emit) => emit(
      RouteLoadSuccess(
        path: event.path, action: event.action
      ))
    );
  }
}
