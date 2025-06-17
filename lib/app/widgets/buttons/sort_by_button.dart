import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/sort_list.dart';
import '../../utils/utils.dart' show SortByLocalizedExtension;

class SortByButton extends StatelessWidget {
  const SortByButton({required this.sortBy, required this.sort});

  final SortBy sortBy;
  final Future Function() sort;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadiusDirectional.all(Radius.circular(6.0)),
      child: Center(
        child: InkWell(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsetsDirectional.all(6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadiusDirectional.all(Radius.circular(6.0)),
              ),
              child: Text(S.current.messageSortBy(sortBy.localized)),
            ),
          ),
          onTap: () async => sort(),
        ),
      ),
    );
  }
}
