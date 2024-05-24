import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../buttons/sort_by_button.dart';
import '../buttons/sort_direction_button.dart';

class SortContentsBar extends StatefulWidget {
  const SortContentsBar(
      {required this.sortListCubit, required this.reposCubit});

  final SortListCubit sortListCubit;
  final ReposCubit reposCubit;

  @override
  State<SortContentsBar> createState() => _SortContentsBarState();
}

class _SortContentsBarState extends State<SortContentsBar> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SortListCubit, SortListState>(
          bloc: widget.sortListCubit,
          builder: (context, state) => widget.reposCubit.showList
              ? SizedBox.shrink()
              : Container(
                  alignment: Alignment.centerLeft,
                  padding: Dimensions.paddingActionBox,
                  child: Row(
                    children: [
                      SortByButton(
                        sortBy: state.sortBy,
                        sort: _showSortByDialog,
                      ),
                      const VerticalDivider(width: 6.0),
                      SortDirectionButton(
                        direction: state.direction,
                        sortBy: state.sortBy,
                        sort: _updateSortDirection,
                      ),
                    ],
                  ),
                ));

  void _updateSortDirection(SortDirection direction, SortBy sortBy) {
    final newDirection =
        direction == SortDirection.asc ? SortDirection.desc : SortDirection.asc;

    widget.sortListCubit.switchSortDirection(newDirection);

    if (widget.reposCubit.showList) {
      return;
    }

    if (widget.reposCubit.currentRepo is OpenRepoEntry) {
      Dialogs.executeFutureWithLoadingDialog(
        context,
        (widget.reposCubit.currentRepo as OpenRepoEntry).cubit.refresh(
              sortBy: sortBy,
              sortDirection: newDirection,
            ),
      );
    }
  }

  Future<dynamic> _showSortByDialog() async => await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: Dimensions.borderBottomSheetTop,
        builder: (context) => _SortByList(
          widget.sortListCubit,
          widget.reposCubit,
        ),
      );
}

class _SortByList extends StatelessWidget with AppLogger {
  _SortByList(SortListCubit sortCubit, ReposCubit reposCubit)
      : _sortCubit = sortCubit,
        _reposCubit = reposCubit;

  final SortListCubit _sortCubit;
  final ReposCubit _reposCubit;

  final ValueNotifier<SortDirection> _sortDirection =
      ValueNotifier<SortDirection>(SortDirection.desc);

  @override
  Widget build(BuildContext context) {
    final sheetTitleStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w400);

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
              _buildSortByList(
                context,
                state.sortBy,
                state.direction,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortByList(
          BuildContext context, SortBy sortBy, SortDirection direction) =>
      ListView.builder(
        shrinkWrap: true,
        itemCount: SortBy.values.length,
        itemBuilder: (context, index) {
          final sortByItem = SortBy.values[index];

          final settingStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                color: sortByItem.name == sortBy.name
                    ? Colors.black87
                    : Colors.black54,
                fontWeight: sortByItem.name == sortBy.name
                    ? FontWeight.bold
                    : FontWeight.normal,
              );

          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Fields.actionListTile(
                  sortByItem.name.capitalize(),
                  textOverflow: TextOverflow.ellipsis,
                  textSoftWrap: false,
                  style: settingStyle,
                  onTap: () {
                    _sortCubit.sortBy(sortByItem);

                    if (_reposCubit.showList) {
                      if (sortByItem.name != sortBy.name) return;
                      Navigator.of(context).pop();
                      return;
                    }

                    if (_reposCubit.currentRepo is OpenRepoEntry) {
                      Dialogs.executeFutureWithLoadingDialog(
                        context,
                        (_reposCubit.currentRepo as OpenRepoEntry)
                            .cubit
                            .refresh(
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
