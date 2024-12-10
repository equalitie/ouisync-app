import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart'
    show
        EntrySelectionActions,
        EntrySelectionCubit,
        EntrySelectionState,
        RepoCubit;
import '../../utils/utils.dart'
    show
        AppLogger,
        Dialogs,
        Dimensions,
        EntrySelectionActionsExtension,
        Fields,
        Native;

class SelectEntriesButton extends StatefulWidget {
  const SelectEntriesButton({
    required this.repoCubit,
    super.key,
  });

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
          child: _selectState(state.selectionState == SelectionState.on),
        ),
      );

  Widget _selectState(bool selecting) => switch (selecting) {
        true => DoneState(repoCubit: widget.repoCubit),
        false => EditState(repoCubit: widget.repoCubit),
      };
}

class DoneState extends StatelessWidget {
  const DoneState({required this.repoCubit, super.key});

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
                    builder: (context) => _EntrySelectionActionsList(
                      repoCubit.entrySelectionCubit,
                    ),
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
  _EntrySelectionActionsList(EntrySelectionCubit entrySelectionCubit)
      : _entrySelectionCubit = entrySelectionCubit;

  final EntrySelectionCubit _entrySelectionCubit;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: _entrySelectionCubit,
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
                        await _repoCubit.endEntriesSelection();

                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                _buildSortByList(context, cubit: _entrySelectionCubit),
              ],
            ),
          );
        },
      );

  Widget _buildSortByList(
    BuildContext context, {
    required EntrySelectionCubit cubit,
  }) =>
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
                    if (actionItem == EntrySelectionActions.delete) {
                      await Dialogs.executeFutureWithLoadingDialog(
                        null,
                        cubit.deleteEntries(),
                      );

                      await cubit.endSelection();
                      Navigator.of(context).pop();
                    }

                    if (actionItem == EntrySelectionActions.download) {
                      String? defaultDirectoryPath;
                      if (io.Platform.isAndroid) {
                        defaultDirectoryPath =
                            await Native.getDownloadPathForAndroid();
                      } else {
                        final defaultDirectory = io.Platform.isIOS
                            ? await getApplicationDocumentsDirectory()
                            : await getDownloadsDirectory();

                        defaultDirectoryPath = defaultDirectory?.path;
                      }

                      if (defaultDirectoryPath == null) return;

                      await Dialogs.executeFutureWithLoadingDialog(
                        null,
                        cubit.saveEntriesToDevice(
                          context,
                          defaultDirectoryPath: defaultDirectoryPath,
                        ),
                      );

                      await cubit.endSelection();
                      Navigator.of(context).pop();
                    }
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
