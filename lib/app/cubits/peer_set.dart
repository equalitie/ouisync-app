import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync/ouisync.dart';

class PeerSetCubit extends Cubit<PeerSet> {
  final Session _session;
  StreamSubscription<List<PeerInfo>>? _subscription;

  PeerSetCubit(Session session)
      : _session = session,
        super(const PeerSet([]));

  void init() {
    if (_subscription != null) {
      return;
    }

    unawaited(_session.peers.then((peers) => emit(PeerSet(peers))));

    _subscription =
        _session.onPeersChange.listen((peers) => emit(PeerSet(peers)));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}

class PeerSet extends Equatable {
  final List<PeerInfo> peers;

  const PeerSet(this.peers);

  /// Group the peers by their runtime id. Entries without runtime id are all grouped together.
  /// Groups with runtime id are sorted before those without.
  SplayTreeMap<PeerKey, List<PeerInfo>> get grouped {
    var result = SplayTreeMap<PeerKey, List<PeerInfo>>();

    for (var peer in peers) {
      final key = PeerKey(peer.runtimeId);
      result.putIfAbsent(key, () => <PeerInfo>[]).add(peer);
    }

    return result;
  }

  /// Number of connected peers
  int get numConnected => peers
      .where((peer) => peer.state == PeerStateKind.active)
      .map((peer) => peer.runtimeId)
      .toSet()
      .length;

  @override
  List<Object> get props => [peers];
}

class PeerKey implements Comparable<PeerKey> {
  final String? runtimeId;

  PeerKey(this.runtimeId);

  @override
  int get hashCode => runtimeId.hashCode;

  @override
  bool operator ==(Object other) =>
      other is PeerKey && runtimeId == other.runtimeId;

  @override
  int compareTo(PeerKey other) {
    final lhs = runtimeId;
    final rhs = other.runtimeId;

    if (lhs != null) {
      if (rhs != null) {
        return Comparable.compare(lhs, rhs);
      } else {
        return -1;
      }
    } else {
      if (rhs != null) {
        return 1;
      } else {
        return 0;
      }
    }
  }
}
