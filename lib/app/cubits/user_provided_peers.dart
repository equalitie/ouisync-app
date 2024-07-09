import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

class UserProvidedPeersCubit extends Cubit<List<String>> {
  final Session _session;

  UserProvidedPeersCubit(Session session)
      : _session = session,
        super([]) {
    unawaited(_refresh());
  }

  Future<void> addPeer(String addr) async {
    await _session.addUserProvidedPeer(addr);
    await _refresh();
  }

  Future<void> removePeer(String addr) async {
    await _session.removeUserProvidedPeer(addr);
    await _refresh();
  }

  Future<void> _refresh() => _session.userProvidedPeers.then(emit);
}
