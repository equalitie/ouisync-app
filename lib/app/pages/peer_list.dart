import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import '../cubit/peer_set.dart';

class PeerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connected Peers")),
      body: Container(
        child: buildList(),
      )
    );
  }

  Widget buildList() =>
    BlocConsumer<PeerSetCubit, PeerSetChanged>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.peers.length,
          itemBuilder: (context, index) => buildRow(state.peers[index])
        );},
      listener: (context, state) {
      });

  Widget buildRow(oui.ConnectedPeer peer) {
    return ListTile(
      title: Text("${peer.ip} : ${peer.port}  ${peer.direction}"),
      trailing: Text("${peer.state}"));
  }
}
