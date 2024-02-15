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
      maybeCubit?.state.accessMode ?? oui.AccessMode.blind;

  @override
  List<Object> get props => [name, runtimeType];
}

class LoadingRepoEntry extends RepoEntry {
  final RepoLocation _location;

  LoadingRepoEntry(this._location);

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

  RepoSettings get repoSettings => _cubit.repoSettings;
}

class MissingRepoEntry extends RepoEntry {
  final RepoLocation _location;
  final String _error;
  final String? _errorDescription;

  MissingRepoEntry(this._location, this._error, this._errorDescription);

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

  ErrorRepoEntry(this._location, this._error, this._errorDescription);

  String get error => _error;

  String? get errorDescription => _errorDescription;

  @override
  Future<void> close() async {}

  @override
  PasswordMode? get passwordMode => null;

  @override
  RepoLocation get location => _location;
}
