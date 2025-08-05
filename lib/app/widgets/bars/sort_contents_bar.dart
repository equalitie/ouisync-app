import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart'
    show SortBy, SortDirection, SortListCubit, SortListState, ReposState;
import '../../models/models.dart' show OpenRepoEntry;
import '../../utils/utils.dart'
    show AppLogger, Dialogs, Dimensions, Fields, SortByLocalizedExtension;
import '../widgets.dart' show SortByButton, SortDirectionButton;

class SortContentsBar extends StatefulWidget {
  const SortContentsBar({
    required this.sortListCubit,
    required this.reposState,
  });

  final SortListCubit sortListCubit;
  final ReposState reposState;

  @override
  State<SortContentsBar> createState() => _SortContentsBarState();
}

class _SortContentsBarState extends State<SortContentsBar> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SortListCubit, SortListState>(
        bloc: widget.sortListCubit,
        builder: (context, state) => widget.reposState.current == null
            ? SizedBox.shrink()
            : Container(
                alignment: AlignmentDirectional.centerStart,
                padding: Dimensions.paddingActionBox,
                child: Row(
                  children: [
                    SortByButton(sortBy: state.sortBy, sort: _showSortByDialog),
                    const VerticalDivider(width: 6.0),
                    SortDirectionButton(
                      direction: state.direction,
                      sortBy: state.sortBy,
                      sort: _updateSortDirection,
                    ),
                  ],
                ),
              ),
      );

  void _updateSortDirection(SortDirection direction, SortBy sortBy) {
    final newDirection = direction == SortDirection.asc
        ? SortDirection.desc
        : SortDirection.asc;

    widget.sortListCubit.switchSortDirection(newDirection);

    final current = widget.reposState.current;

    if (current is OpenRepoEntry) {
      Dialogs.executeFutureWithLoadingDialog(
        context,
        current.cubit.refresh(sortBy: sortBy, sortDirection: newDirection),
      );
    }
  }

  Future<dynamic> _showSortByDialog() async => await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) => _SortByList(widget.sortListCubit, widget.reposState),
  );
}

class _SortByList extends StatelessWidget with AppLogger {
  _SortByList(this._sortCubit, this._reposState);

  final SortListCubit _sortCubit;
  final ReposState _reposState;

  final ValueNotifier<SortDirection> _sortDirection =
      ValueNotifier<SortDirection>(SortDirection.asc);

  @override
  Widget build(BuildContext context) {
    final sheetTitleStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400);

    return BlocBuilder<SortListCubit, SortListState>(
      bloc: _sortCubit,
      builder: (context, state) {
        _sortDirection.value = state.direction;

        return Container(
          padding: Dimensions.paddingBottomSheet,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Fields.bottomSheetHandle(context),
              Fields.bottomSheetTitle(
                S.current.titleSortBy,
                style: sheetTitleStyle,
              ),
              _buildSortByList(context, state.sortBy, state.direction),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortByList(
    BuildContext context,
    SortBy sortBy,
    SortDirection direction,
  ) => ListView.builder(
    shrinkWrap: true,
    itemCount: SortBy.values.length,
    itemBuilder: (context, index) {
      final sortByItem = SortBy.values[index];

      final settingStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
        color: sortByItem.name == sortBy.name ? Colors.black87 : Colors.black54,
        fontWeight: sortByItem.name == sortBy.name
            ? FontWeight.bold
            : FontWeight.normal,
      );

      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Fields.actionListTile(
              sortByItem.localized,
              textOverflow: TextOverflow.ellipsis,
              textSoftWrap: false,
              style: settingStyle,
              onTap: () async {
                _sortCubit.sortBy(sortByItem);

                final current = _reposState.current;

                if (current == null) {
                  if (sortByItem.name != sortBy.name) return;
                  Navigator.of(context).pop();
                  return;
                }

                if (current is OpenRepoEntry) {
                  await Dialogs.executeFutureWithLoadingDialog(
                    null,
                    current.cubit.refresh(
                      sortBy: sortByItem,
                      sortDirection: direction,
                    ),
                  );

                  Navigator.of(context).pop();
                }
              },
              icon: sortByItem.name == sortBy.name ? Icons.check : null,
              iconColor: Theme.of(context).primaryColor,
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      );
    },
  );
}
