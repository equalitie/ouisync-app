import 'package:flutter/material.dart';

import '../../cubits/sort_list.dart';

class SortByButton extends StatelessWidget {
  const SortByButton({
    required this.sortBy,
    required this.sort,
  });

  final SortBy sortBy;
  final Future Function() sort;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      child: Center(
        child: InkWell(
          child: Container(
            padding: EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            child: Text('Sort by ${sortBy.name}'),
          ),
          onTap: () async => sort(),
        ),
      ),
    );
  }
}
