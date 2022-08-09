import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

class PeerSetCubit extends Cubit<PeerSetChanged> {
  PeerSetCubit() : super(const PeerSetChanged([]));

  void onPeerSetChanged(oui.Session session) {
    emit(PeerSetChanged(session.connectedPeers));
  }
}

class PeerSetChanged extends Equatable {
  const PeerSetChanged(this.peers);

  final List<oui.ConnectedPeer> peers;

  String stats() {
    final active = peers.fold<int>(0, (prev, peer) {
      if (peer.state == "Active") {
        return prev + 1;
      } else {
        return prev;
      }
    });

    return active.toString() + " / " + peers.length.toString();
  }

  @override
  List<Object> get props => [
    peers,
  ];
}
