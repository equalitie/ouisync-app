import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/cubits/cubits.dart'
    show
        EntrySelectionCubit,
        EntrySelectionState,
        RepoCubit,
        ReposCubit,
        SortListCubit;
import 'package:ouisync_app/app/utils/utils.dart' show ThemeGetter;
import 'package:ouisync_app/app/widgets/widgets.dart'
    show SelectEntriesButton, SelectionStatus, SortContentsBar;

class FolderContentsBar extends StatefulWidget {
  const FolderContentsBar({
    required this.reposCubit,
    required this.repoCubit,
    required this.hasContents,
    required this.sortListCubit,
    required this.entrySelectionCubit,
    super.key,
  });

  final ReposCubit reposCubit;
  final RepoCubit repoCubit;
  final bool hasContents;
  final SortListCubit sortListCubit;
  final EntrySelectionCubit entrySelectionCubit;

  @override
  State<FolderContentsBar> createState() => _FolderContentsBarState();
}

class _FolderContentsBarState extends State<FolderContentsBar> {
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
    bloc: widget.entrySelectionCubit,
    builder: (context, state) => Container(
      padding: EdgeInsetsDirectional.symmetric(vertical: 4.0, horizontal: 2.0),
      decoration: _getDecorator(state),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.hasContents)
            SortContentsBar(
              sortListCubit: widget.sortListCubit,
              reposState: widget.reposCubit.state,
            ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.hasContents || state.status == SelectionStatus.on)
                  SelectEntriesButton(
                    repoCubit: widget.repoCubit,
                    reposCubit: widget.reposCubit,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Decoration _getDecorator(EntrySelectionState state) => BoxDecoration(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
    ),
    border: state.status == SelectionStatus.on
        ? Border(
            bottom: BorderSide(
              color: Colors.black26,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          )
        : null,
    color: state.status == SelectionStatus.on
        ? context.theme.secondaryHeaderColor
        : null,
  );
}
