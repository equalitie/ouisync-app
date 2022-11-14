import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

class PeerSetCubit extends Cubit<PeerSet> {
  final Session _session;
  StreamSubscription<List<PeerInfo>>? _subscription;

  PeerSetCubit({required Session session})
      : _session = session,
        super(const PeerSet([]));

  void init() {
    if (_subscription != null) {
      return;
    }

    _subscription =
        _session.onPeersChange.listen((peers) => emit(PeerSet(peers)));

    emit(PeerSet(_session.peers));
  }

  @override
  Future<void> close() async {
    _subscription?.cancel();
    super.close();
  }
}

class PeerSet extends Equatable {
  final List<PeerInfo> peers;

  const PeerSet(this.peers);

  /// Group the peers by their runtime id. Entries without runtime id are not grouped.
  SplayTreeMap<PeerKey, List<PeerInfo>> get grouped {
    var result = SplayTreeMap<PeerKey, List<PeerInfo>>();

    for (var peer in peers) {
      final runtimeId = peer.runtimeId;
      final key = runtimeId != null
          ? PeerKey(runtimeId, 0)
          : PeerKey('', result.length + 1);

      result.putIfAbsent(key, () => <PeerInfo>[]).add(peer);
    }

    return result;
  }

  String stats() {
    final active = peers.fold<int>(0, (prev, peer) {
      if (peer.state == "Active") {
        return prev + 1;
      } else {
        return prev;
      }
    });

    return "$active/${peers.length}";
  }

  @override
  List<Object> get props => [peers];
}

class PeerKey implements Comparable<PeerKey> {
  final String runtimeId;
  final int fallback;

  PeerKey(this.runtimeId, this.fallback);

  @override
  int get hashCode => Object.hash(runtimeId, fallback);

  @override
  bool operator ==(Object other) =>
      other is PeerKey &&
      runtimeId == other.runtimeId &&
      fallback == other.fallback;

  @override
  int compareTo(PeerKey other) {
    if (runtimeId.isNotEmpty) {
      if (other.runtimeId.isNotEmpty) {
        return Comparable.compare(runtimeId, other.runtimeId);
      } else {
        return -1;
      }
    } else {
      if (other.runtimeId.isNotEmpty) {
        return 1;
      } else {
        return Comparable.compare(fallback, other.fallback);
      }
    }
  }
}
