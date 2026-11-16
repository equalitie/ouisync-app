import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/session_handle.dart' show SessionProxy;
import 'utils.dart';

class UserProvidedPeersCubit extends Cubit<List<String>> with CubitActions {
  final SessionProxy _session;

  UserProvidedPeersCubit(SessionProxy session) : _session = session, super([]) {
    _session.started.addListener(_refresh);
    unawaited(_refresh());
  }

  @override
  Future<void> close() async {
    _session.started.removeListener(_refresh);
    await super.close();
  }

  Future<void> addPeer(String addr) async {
    await _session.addUserProvidedPeers([addr]);
    await _refresh();
  }

  Future<void> removePeer(String addr) async {
    await _session.removeUserProvidedPeers([addr]);
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_session.started.value == 0) {
      return;
    }
    await _session.getUserProvidedPeers().then(emitUnlessClosed);
  }
}
