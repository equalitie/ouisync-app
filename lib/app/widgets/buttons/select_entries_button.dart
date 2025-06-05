import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart'
    show EntrySelectionCubit, EntrySelectionState, RepoCubit, ReposCubit;
import '../../utils/utils.dart' show Dimensions;
import '../widgets.dart' show EntryActions;

class SelectEntriesButton extends StatefulWidget {
  const SelectEntriesButton({
    required this.reposCubit,
    required this.repoCubit,
    super.key,
  });

  final ReposCubit reposCubit;
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
            widget.reposCubit,
            widget.repoCubit,
            state.status == SelectionStatus.on,
          ),
        ),
      );

  Widget _selectState(
    ReposCubit reposCubit,
    RepoCubit repoCubit,
    bool selecting,
  ) =>
      switch (selecting) {
        true => DoneState(reposCubit: reposCubit, repoCubit: repoCubit),
        false => EditState(repoCubit: repoCubit),
      };
}

class DoneState extends StatelessWidget {
  const DoneState({
    required this.reposCubit,
    required this.repoCubit,
    super.key,
  });

  final ReposCubit reposCubit;
  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: () async {
          reposCubit.bottomSheet.hide();
          await repoCubit.endEntriesSelection();
        },
        label: Text(S.current.actionCancel),
        icon: const Icon(Icons.close),
        iconAlignment: IconAlignment.end,
      );
}

class EditState extends StatelessWidget {
  const EditState({required this.repoCubit, super.key});

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: () async => await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) => EntryActions(repoCubit: repoCubit),
        ),
        label: Text(S.current.actionSelect),
        icon: const Icon(Icons.check),
        iconAlignment: IconAlignment.end,
      );
}

enum SelectionStatus { off, on }
