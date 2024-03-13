import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../cubits/cubits.dart';
import '../utils/utils.dart';
import '../models/models.dart';

abstract class RepoEntry extends Equatable {
  Future<void> close();
  RepoLocation get location;
  String get name => location.name;
  PasswordMode? get passwordMode;
  RepoCubit? get maybeCubit => null;

  String? get infoHash => maybeCubit?.state.infoHash;

  oui.AccessMode get accessMode =>
      maybeCubit?.accessMode ?? oui.AccessMode.blind;

  @override
  List<Object> get props => [name, runtimeType];

  RepoSettings? get repoSettings;
}

class LoadingRepoEntry extends RepoEntry {
  final RepoLocation _location;
  // Only null when the repo is being created;
  @override
  final RepoSettings? repoSettings;

  LoadingRepoEntry(this._location, this.repoSettings);

  @override
  RepoLocation get location => _location;

  @override
  Future<void> close() async {}

  @override
  PasswordMode? get passwordMode => null;

  @override
  RepoCubit? get maybeCubit => null;
}

class OpenRepoEntry extends RepoEntry {
  final RepoCubit _cubit;

  OpenRepoEntry(this._cubit);

  RepoCubit get cubit => _cubit;

  DatabaseId get databaseId => _cubit.databaseId;

  @override
  RepoCubit? get maybeCubit => _cubit;

  @override
  Future<void> close() async {
    await _cubit.close();
  }

  @override
  RepoLocation get location => _cubit.location;

  @override
  PasswordMode? get passwordMode => _cubit.state.passwordMode;

  @override
  RepoSettings get repoSettings => _cubit.repoSettings;
}

class MissingRepoEntry extends RepoEntry {
  final RepoLocation _location;
  final String _error;
  final String? _errorDescription;
  @override
  final RepoSettings repoSettings;

  MissingRepoEntry(
      this._location, this._error, this._errorDescription, this.repoSettings);

  String get error => _error;

  String? get errorDescription => _errorDescription;

  @override
  Future<void> close() async {}

  @override
  PasswordMode? get passwordMode => null;

  @override
  RepoLocation get location => _location;
}

class ErrorRepoEntry extends RepoEntry {
  final RepoLocation _location;
  final String _error;
  final String? _errorDescription;
  // Null only if the repo was being created and failed.
  @override
  final RepoSettings? repoSettings;

  ErrorRepoEntry(
      this._location, this._error, this._errorDescription, this.repoSettings);

  String get error => _error;

  String? get errorDescription => _errorDescription;

  @override
  Future<void> close() async {}

  @override
  PasswordMode? get passwordMode => null;

  @override
  RepoLocation get location => _location;
}
