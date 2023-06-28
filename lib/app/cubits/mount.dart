import 'dart:convert';
import 'dart:async';
import 'package:udp/udp.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dns_client/dns_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../utils/log.dart';

class MountState {}

class MountStateMounting extends MountState {}

class MountStateSuccess extends MountState {}

class MountStateError extends MountState {
  int code;
  String message;
  MountStateError(this.code, this.message);
}

class MountCubit extends Cubit<MountState> with AppLogger {
  MountCubit(oui.Session session) : super(MountStateMounting()) {
    unawaited(_mountFileSystem(session));
  }

  Future<void> _mountFileSystem(oui.Session session) async {
    try {
      await session.mountAllRepositories("O:");
      emit(MountStateSuccess());
    } on oui.Error catch (error) {
      loggy.app("Failed to mount repositories ${error.code}: ${error.message}");
      emit(MountStateError(error.code, error.message));
    }
  }
}
