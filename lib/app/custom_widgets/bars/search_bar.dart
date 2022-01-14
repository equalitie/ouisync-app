import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Text(
              '<search>',
              textAlign: TextAlign.center,
            )
          ),
          Fields.actionIcon(
            icon: Icons.search_outlined,
            onTap: () {},
            size: 35.0
          )
        ]
      )
    );
  }
}