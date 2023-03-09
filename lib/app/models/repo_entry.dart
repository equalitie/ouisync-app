import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../cubits/cubits.dart';
import '../utils/settings.dart';
import 'folder.dart';
import 'repo_meta_info.dart';

abstract class RepoEntry extends Equatable {
  Future<void> close();
  RepoMetaInfo get metaInfo;
  String get name => metaInfo.name;
  String? get infoHash;
  bool? get authenticateWithBiometrics;
  Folder? get currentFolder;
  RepoCubit? get maybeCubit => null;

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
  String? get infoHash => null;

  @override
  bool? get authenticateWithBiometrics => null;

  @override
  Folder? get currentFolder => null;

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

  @override
  String? get infoHash => _cubit.state.infoHash;

  @override
  bool? get authenticateWithBiometrics => _cubit.state.authenticationRequired;

  @override
  Folder? get currentFolder => _cubit.currentFolder;
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
  bool? get authenticateWithBiometrics => null;

  @override
  Folder? get currentFolder => null;

  @override
  String? get infoHash => null;

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
  bool? get authenticateWithBiometrics => null;

  @override
  Folder? get currentFolder => null;

  @override
  String? get infoHash => null;

  @override
  RepoMetaInfo get metaInfo => _metaInfo;
}
