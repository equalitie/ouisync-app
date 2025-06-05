import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;

import '../models/models.dart' show FileSystemEntry;
import '../utils/utils.dart' show AppLogger;
import 'cubits.dart' show CubitActions, NavigationCubit, RepoCubit, ReposCubit;

enum BottomSheetType { copy, delete, download, move, upload, gone }

class BottomSheetInfo extends Equatable {
  final BottomSheetType type;
  final double neededPadding;
  final String entry;

  BottomSheetInfo({
    required this.type,
    required this.neededPadding,
    required this.entry,
  });

  BottomSheetInfo copyWith({
    BottomSheetType? type,
    double? neededPadding,
    String? entry,
  }) =>
      BottomSheetInfo(
        type: type ?? BottomSheetType.gone,
        neededPadding: neededPadding ?? 0.0,
        entry: entry ?? '',
      );

  @override
  List<Object?> get props => [type, neededPadding, entry];
}

sealed class EntryBottomSheetState {}

class MoveEntrySheetState extends Equatable implements EntryBottomSheetState {
  final RepoCubit repoCubit;
  final NavigationCubit navigationCubit;
  final BottomSheetType type;
  final FileSystemEntry entry;

  MoveEntrySheetState({
    required this.repoCubit,
    required this.navigationCubit,
    required this.type,
    required this.entry,
  });

  @override
  List<Object?> get props => [
        repoCubit,
        navigationCubit,
        type,
        entry,
      ];
}

class MoveSelectedEntriesSheetState extends Equatable
    implements EntryBottomSheetState {
  final RepoCubit repoCubit;
  final BottomSheetType type;
  final FileSystemEntry? entry;

  MoveSelectedEntriesSheetState({
    required this.repoCubit,
    required this.type,
    this.entry,
  });

  @override
  List<Object?> get props => [
        repoCubit,
        type,
        entry,
      ];
}

class SaveMediaSheetState extends Equatable implements EntryBottomSheetState {
  final ReposCubit reposCubit;
  final List<String> sharedMediaPaths;

  SaveMediaSheetState({
    required this.reposCubit,
    required this.sharedMediaPaths,
  });

  @override
  List<Object?> get props => [reposCubit, sharedMediaPaths];
}

class HideSheetState implements EntryBottomSheetState {}

class EntryBottomSheetCubit extends Cubit<EntryBottomSheetState>
    with AppLogger, CubitActions {
  EntryBottomSheetCubit() : super(HideSheetState());

  void showMoveEntry({
    required RepoCubit repoCubit,
    required NavigationCubit navigationCubit,
    required BottomSheetType type,
    required FileSystemEntry entry,
  }) =>
      emitUnlessClosed(MoveEntrySheetState(
        repoCubit: repoCubit,
        navigationCubit: navigationCubit,
        type: type,
        entry: entry,
      ));

  void showMoveSelectedEntries({
    required RepoCubit repoCubit,
    required BottomSheetType type,
    FileSystemEntry? entry,
  }) =>
      emitUnlessClosed(MoveSelectedEntriesSheetState(
        repoCubit: repoCubit,
        type: type,
        entry: entry,
      ));

  void showSaveMedia({
    required ReposCubit reposCubit,
    required List<String> paths,
  }) =>
      emitUnlessClosed(SaveMediaSheetState(
        reposCubit: reposCubit,
        sharedMediaPaths: paths,
      ));

  void hide() => emitUnlessClosed(HideSheetState());
}
