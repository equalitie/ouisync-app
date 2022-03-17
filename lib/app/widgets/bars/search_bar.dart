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
            const Icon(Icons.search_outlined),
            onPressed: () {},
            size: Dimensions.sizeIconAverage
          )
        ]
      )
    );
  }
}