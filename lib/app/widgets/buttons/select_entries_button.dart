import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart'
    show
        BottomSheetType,
        EntrySelectionActions,
        EntrySelectionCubit,
        EntrySelectionState,
        RepoCubit;
import '../../utils/utils.dart'
    show AppLogger, Dimensions, EntrySelectionActionsExtension, Fields;

class SelectEntriesButton extends StatefulWidget {
  const SelectEntriesButton({required this.repoCubit, super.key});

  final RepoCubit repoCubit;

  @override
  State<SelectEntriesButton> createState() => _SelectEntriesButtonState();
}

class _SelectEntriesButtonState extends State<SelectEntriesButton> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: widget.repoCubit.entrySelectionCubit,
        builder: (context, state) => Container(
          padding: EdgeInsetsDirectional.only(start: 6.0, end: 2.0),
          child: _selectState(
            widget.repoCubit,
            state.selectionState == SelectionState.on,
          ),
        ),
      );

  Widget _selectState(RepoCubit repoCubit, bool selecting) =>
      switch (selecting) {
        true => DoneState(repoCubit: repoCubit),
        false => EditState(repoCubit: repoCubit),
      };
}

class DoneState extends StatelessWidget {
  const DoneState({
    required this.repoCubit,
    super.key,
  });

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: () async =>
            repoCubit.entrySelectionCubit.selectedEntries.isEmpty
                ? await repoCubit.endEntriesSelection()
                : await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: Dimensions.borderBottomSheetTop,
                    builder: (context) => _EntrySelectionActionsList(repoCubit),
                  ),
        label: Text(S.current.actionDone),
        icon: const Icon(Icons.arrow_drop_down_outlined),
        iconAlignment: IconAlignment.end,
      );
}

class EditState extends StatelessWidget {
  const EditState({required this.repoCubit, super.key});

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: () async => await repoCubit.startEntriesSelection(),
        label: Text(S.current.actionSelect),
        icon: const Icon(Icons.check),
        iconAlignment: IconAlignment.end,
      );
}

enum SelectionState { off, on }

class _EntrySelectionActionsList extends StatelessWidget with AppLogger {
  _EntrySelectionActionsList(this.repoCubit);

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: repoCubit.entrySelectionCubit,
        builder: (context, state) {
          return Container(
            padding: Dimensions.paddingBottomSheet,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Fields.bottomSheetHandle(context)),
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () async {
                        await repoCubit.endEntriesSelection();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                _buildSelectedEntriesActionList(context),
              ],
            ),
          );
        },
      );

  Widget _buildSelectedEntriesActionList(BuildContext context) =>
      ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 1,
          color: Colors.black12,
        ),
        itemCount: EntrySelectionActions.values.length,
        itemBuilder: (context, index) {
          final actionItem = EntrySelectionActions.values[index];

          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Fields.actionListTile(
                  actionItem.localized,
                  textOverflow: TextOverflow.ellipsis,
                  textSoftWrap: false,
                  style: Theme.of(context).textTheme.bodyMedium,
                  onTap: () async {
                    final type = switch (actionItem) {
                      EntrySelectionActions.download =>
                        BottomSheetType.download,
                      EntrySelectionActions.copy => BottomSheetType.copy,
                      EntrySelectionActions.move => BottomSheetType.move,
                      EntrySelectionActions.delete => BottomSheetType.delete,
                    };

                    Navigator.of(context).pop();
                    repoCubit.showMoveSelectedEntriesBottomSheet(
                      sheetType: type,
                    );

                    return;
                  },
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          );
        },
      );
}
