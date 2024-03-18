import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../cubits/cubits.dart';
import '../utils/utils.dart';
import '../models/models.dart';

sealed class RepoEntry extends Equatable {
  DatabaseId? get databaseId;
  RepoLocation get location;
  RepoCubit? get cubit => null;
  PasswordMode? get passwordMode => null;

  String get name => location.name;
  String? get infoHash => cubit?.state.infoHash;
  oui.AccessMode get accessMode => cubit?.accessMode ?? oui.AccessMode.blind;

  Future<void> close();

  @override
  List<Object> get props => [name, runtimeType];
}

class LoadingRepoEntry extends RepoEntry {
  LoadingRepoEntry(this.databaseId, this.location);

  @override
  final RepoLocation location;

  // Only null when the repo is being created;
  @override
  final DatabaseId? databaseId;

  @override
  Future<void> close() async {}
}

class OpenRepoEntry extends RepoEntry {
  OpenRepoEntry(this.cubit);

  @override
  final RepoCubit cubit;

  @override
  DatabaseId get databaseId => cubit.databaseId;

  @override
  Future<void> close() async {
    await cubit.close();
  }

  @override
  RepoLocation get location => cubit.location;

  @override
  PasswordMode get passwordMode => cubit.state.authMode.passwordMode;
}

class MissingRepoEntry extends RepoEntry {
  MissingRepoEntry(
    this.databaseId,
    this.location,
    this.error,
    this.errorDescription,
  );

  @override
  final DatabaseId databaseId;

  @override
  final RepoLocation location;

  final String error;
  final String? errorDescription;

  @override
  Future<void> close() async {}
}

class ErrorRepoEntry extends RepoEntry {
  ErrorRepoEntry(
    this.databaseId,
    this.location,
    this.error,
    this.errorDescription,
  );

  // Null only if the repo was being created and failed.
  @override
  final DatabaseId? databaseId;

  @override
  final RepoLocation location;

  final String error;
  final String? errorDescription;

  @override
  Future<void> close() async {}
}
