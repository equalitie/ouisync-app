import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/user_provided_peers.dart';
import '../utils/utils.dart' show Dimensions, showSnackBar;
import '../widgets/dialogs/add_peer_dialog.dart';
import '../widgets/long_text.dart';
import '../widgets/widgets.dart' show DirectionalAppBar;

class UserProvidedPeersPage extends StatefulWidget {
  UserProvidedPeersPage(this.session);

  final Session session;

  @override
  State<UserProvidedPeersPage> createState() =>
      _UserProvidedPeersState(session);
}

class _UserProvidedPeersState extends State<UserProvidedPeersPage> {
  _UserProvidedPeersState(Session session)
      : _cubit = UserProvidedPeersCubit(session);

  final UserProvidedPeersCubit _cubit;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DirectionalAppBar(
          title: Text(S.current.titleUserProvidedPeers),
        ),
        body: BlocBuilder<UserProvidedPeersCubit, List<String>>(
          bloc: _cubit,
          builder: (context, state) => ListView(
            padding: Dimensions.paddingContents,
            children: _buildPeers(context, state),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_rounded),
          onPressed: () => _addPeer(context),
        ),
      );

  List<Widget> _buildPeers(BuildContext context, List<String> peers) =>
      peers.map((peer) => _buildPeer(context, peer)).toList();

  Widget _buildPeer(BuildContext context, String peer) => Padding(
        padding: EdgeInsetsDirectional.all(4.0),
        child: Row(children: [
          Expanded(child: LongText(peer)),
          IconButton(
            icon: Icon(Icons.delete_outlined),
            onPressed: () => _removePeer(context, peer),
          ),
        ]),
      );

  Future<void> _addPeer(BuildContext context) async {
    final addr = await showDialog<String>(
      context: context,
      builder: (context) => AddPeerDialog(),
    );

    if (addr == null) {
      return;
    }

    await _cubit.addPeer('tcp/$addr');
    await _cubit.addPeer('quic/$addr');

    showSnackBar(S.current.messagePeerAdded);
  }

  Future<void> _removePeer(BuildContext context, String addr) async {
    await _cubit.removePeer(addr);

    showSnackBar(
      S.current.messagePeerRemoved,
      action: SnackBarAction(
        label: S.current.actionUndo,
        onPressed: () => _cubit.addPeer(addr),
      ),
    );
  }
}
