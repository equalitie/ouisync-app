import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/utils.dart' show AppLogger;
import 'cubits.dart' show CubitActions;

class SortListState extends Equatable {
  final SortBy sortBy;
  final SortDirection direction;
  final ListType listType;

  SortListState({
    this.sortBy = SortBy.name,
    this.direction = SortDirection.asc,
    this.listType = ListType.repos,
  });

  SortListState copyWith({
    SortBy? sortBy,
    SortDirection? direction,
    ListType? listType,
  }) => SortListState(
    sortBy: sortBy ?? this.sortBy,
    direction: direction ?? this.direction,
    listType: listType ?? this.listType,
  );

  @override
  List<Object?> get props => [sortBy, direction, listType];
}

class SortListCubit extends Cubit<SortListState> with AppLogger, CubitActions {
  SortListCubit._(super.state);

  static SortListCubit create({
    required SortBy sortBy,
    required SortDirection direction,
    required ListType listType,
  }) {
    var initialState = SortListState().copyWith(
      sortBy: sortBy,
      direction: direction,
      listType: listType,
    );

    return SortListCubit._(initialState);
  }

  void sortBy(SortBy sortBy) =>
      emitUnlessClosed(state.copyWith(sortBy: sortBy));

  void switchListType(ListType listType) =>
      emitUnlessClosed(state.copyWith(listType: listType));

  void switchSortDirection(SortDirection direction) =>
      emitUnlessClosed(state.copyWith(direction: direction));
}

enum SortBy { name, size, type }

enum SortDirection { asc, desc }

enum ListType { content, repos }
