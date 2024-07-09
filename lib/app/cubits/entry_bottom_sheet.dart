import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/bindings.dart';

import '../utils/log.dart';
import 'cubits.dart';

enum BottomSheetType { move, upload, gone }

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
  final String entryPath;
  final EntryType entryType;

  MoveEntrySheetState({
    required this.repoCubit,
    required this.navigationCubit,
    required this.entryPath,
    required this.entryType,
  });

  @override
  List<Object?> get props => [
        repoCubit,
        navigationCubit,
        entryPath,
        entryType,
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
    with AppLogger {
  EntryBottomSheetCubit() : super(HideSheetState());

  void showMoveEntry({
    required RepoCubit repoCubit,
    required NavigationCubit navigationCubit,
    required String entryPath,
    required EntryType entryType,
  }) =>
      emit(
        MoveEntrySheetState(
          repoCubit: repoCubit,
          navigationCubit: navigationCubit,
          entryPath: entryPath,
          entryType: entryType,
        ),
      );

  void showSaveMedia(
          {required ReposCubit reposCubit, required List<String> paths}) =>
      emit(
        SaveMediaSheetState(
          reposCubit: reposCubit,
          sharedMediaPaths: paths,
        ),
      );

  void hide() => emit(HideSheetState());
}
