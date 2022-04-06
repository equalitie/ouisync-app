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
      body: Container(child: _buildTable())
    );
  }

  Widget _buildTable() =>
    BlocConsumer<PeerSetCubit, PeerSetChanged>(
      builder: (context, state) =>
        SingleChildScrollView(
          // FittexBox to prevent table overflowing the screen.
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: DataTable(
              columns: [
                DataColumn(label: Text("IP")),
                DataColumn(label: Text("Port")),
                DataColumn(label: Text("Direction")),
                DataColumn(label: Expanded(child: Text("State", textAlign: TextAlign.right))),
              ],
              rows: state.peers.map((peer) => _buildRow(peer)).toList()))),
      listener: (context, state) {
      });

  DataRow _buildRow(oui.ConnectedPeer peer) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(peer.ip)),
        DataCell(Text(peer.port)),
        DataCell(Text(peer.direction)),
        DataCell(Align(alignment: Alignment.centerRight, child: Text(peer.state))),
      ],
    );
  }
}
