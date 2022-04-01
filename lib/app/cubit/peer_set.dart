import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

class PeerSetCubit extends Cubit<PeerSetChanged> {
  PeerSetCubit() : super(PeerSetChanged([]));

  void onPeerSetChanged(oui.Session session) {
    emit(PeerSetChanged(session.connectedPeers));
  }
}

class PeerSetChanged extends Equatable {
  const PeerSetChanged(this.peers);

  final List<oui.ConnectedPeer> peers;

  @override
  List<Object> get props => [
    peers,
  ];
}
