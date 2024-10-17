import 'package:flutter/material.dart';

import '../../cubits/sort_list.dart';
import '../../utils/dimensions.dart';

class SortDirectionButton extends StatelessWidget {
  const SortDirectionButton({
    required this.direction,
    required this.sortBy,
    required this.sort,
  });

  final SortDirection direction;
  final SortBy sortBy;
  final void Function(SortDirection, SortBy) sort;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadiusDirectional.all(Radius.circular(6.0)),
      child: Center(
        child: InkWell(
          child: Container(
            padding: EdgeInsetsDirectional.all(6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadiusDirectional.all(Radius.circular(6.0)),
            ),
            child: _getDirectionArrow(direction),
          ),
          onTap: () => sort(direction, sortBy),
        ),
      ),
    );
  }

  Widget _getDirectionArrow(SortDirection direction) {
    return direction == SortDirection.asc
        ? const Image(
            image: AssetImage('assets/sort_asc.png'),
            width: Dimensions.sizeIconMicro,
          )
        : const Image(
            image: AssetImage('assets/sort_desc.png'),
            width: Dimensions.sizeIconMicro,
          );
  }
}
