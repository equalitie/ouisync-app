import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../utils/utils.dart';

class ShareRepository extends StatelessWidget {
  const ShareRepository({
    required this.repositoryName,
    required this.token
  });

  final String repositoryName;
  final String token;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHandle(context),
          _shareCodeDetails(context, this.repositoryName, this.token),
        ],
      ),
    ); 
  }

  Widget _shareCodeDetails(BuildContext context, String repositoryName, String token) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitle('Share $repositoryName'),
          buildIconLabel(Icons.supervisor_account_rounded, 'Share this with your peer', iconSize: 40.0),
          _buildShareBox(token)
        ]
      )
    );
  }

  Widget _buildShareBox(String token) => Container(
    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      border: Border.all(
        color: Colors.black45,
        width: 1.0,
        style: BorderStyle.solid
      ),
      color: Colors.white,
    ),
    child: Row(
      children: [
        buildConstrainedText(token, size: 20.0, softWrap: false, overflow: TextOverflow.ellipsis, color: Colors.black),
        _copyTokenAction(token),
        _shareTokenAction(token),
      ],
    )
  );

  IconButton _copyTokenAction(String token) {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.content_copy_rounded),
      iconSize: 30.0,
    );
  }

  IconButton _shareTokenAction(String token) {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.share_outlined),
      iconSize: 30.0,
    );
  }
}