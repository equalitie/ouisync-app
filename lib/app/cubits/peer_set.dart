import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hex/hex.dart';
import 'package:ouisync/ouisync.dart';
import 'package:stream_transform/stream_transform.dart';

import '../utils/log.dart';
import 'utils.dart';

class PeerSetCubit extends Cubit<PeerSet> with CubitActions, AppLogger {
  final Session _session;
  StreamSubscription<void>? _subscription;

  PeerSetCubit(Session session)
      : _session = session,
        super(const PeerSet([])) {
    unawaited(_init());
  }

  Future<void> _init() async {
    await setAutoRefresh(null);
    await refresh();
  }

  Future<void> setAutoRefresh(Duration? period) async {
    await _subscription?.cancel();

    if (period != null) {
      _subscription =
          Stream.periodic(period).asyncMapSample((_) => refresh()).listen(null);
      loggy.debug('peer set auto refresh enabled (period: $period)');
    } else {
      _subscription =
          _session.networkEvents.asyncMapSample((_) => refresh()).listen(null);
      loggy.debug('peer set auto refresh disabled');
    }
  }

  Future<void> refresh() async {
    final peers = await _session.getPeers();

    if (!isClosed) {
      emitUnlessClosed(PeerSet(peers));
    }
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
      final key = switch (peer.state) {
        PeerStateActive(id: final id) => PeerKey(HEX.encode(id.value)),
        _ => PeerKey(null),
      };

      result.putIfAbsent(key, () => <PeerInfo>[]).add(peer);
    }

    return result;
  }

  /// Number of connected peers
  int get numConnected => peers
      .map((peer) => switch (peer.state) {
            PeerStateActive(id: final id) => id,
            _ => null,
          })
      .nonNulls
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
