import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../cubits/cubits.dart';
import '../utils/settings.dart';
import 'repo_meta_info.dart';

abstract class RepoEntry extends Equatable {
  Future<void> close();
  RepoMetaInfo get metaInfo;
  String get name => metaInfo.name;
  RepoCubit? get maybeCubit => null;

  String? get infoHash => maybeCubit?.state.infoHash;

  oui.AccessMode get accessMode =>
      maybeCubit?.state.accessMode ?? oui.AccessMode.blind;

  @override
  List<Object> get props => [name, runtimeType];
}

class LoadingRepoEntry extends RepoEntry {
  final RepoMetaInfo _metaInfo;

  // FIXME: unused_field
  // bool _closeAfter = false;

  LoadingRepoEntry(this._metaInfo);

  @override
  RepoMetaInfo get metaInfo => _metaInfo;

  @override
  Future<void> close() async {
    // FIXME: unused_field
    //_closeAfter = true;
  }

  @override
  RepoCubit? get maybeCubit => null;
}

class OpenRepoEntry extends RepoEntry {
  final RepoCubit _cubit;

  OpenRepoEntry(this._cubit);

  RepoCubit get cubit => _cubit;

  String get databaseId => _cubit.databaseId;

  @override
  RepoCubit? get maybeCubit => _cubit;

  @override
  Future<void> close() async {
    await _cubit.close();
  }

  @override
  RepoMetaInfo get metaInfo => _cubit.metaInfo;

  SettingsRepoEntry get settingsRepoEntry => _cubit.settingsRepoEntry;
}

class MissingRepoEntry extends RepoEntry {
  final RepoMetaInfo _metaInfo;
  final String _error;
  final String? _errorDescription;

  MissingRepoEntry(this._metaInfo, this._error, this._errorDescription);

  String get error => _error;

  String? get errorDescription => _errorDescription;

  @override
  Future<void> close() async {}

  @override
  RepoMetaInfo get metaInfo => _metaInfo;
}

class ErrorRepoEntry extends RepoEntry {
  final RepoMetaInfo _metaInfo;
  final String _error;
  final String? _errorDescription;

  ErrorRepoEntry(this._metaInfo, this._error, this._errorDescription);

  String get error => _error;

  String? get errorDescription => _errorDescription;

  @override
  Future<void> close() async {}

  @override
  RepoMetaInfo get metaInfo => _metaInfo;
}
