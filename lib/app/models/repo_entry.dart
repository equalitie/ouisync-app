import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import '../cubits/cubits.dart';
import 'folder.dart';

abstract class RepoEntry extends Equatable {
  Future<void> close();
  String get name;
  oui.Repository? get maybeHandle;
  String? get id;
  Folder? get currentFolder;
  RepoCubit? get maybeCubit => null;

  @override
  List<Object> get props => [ name, runtimeType ];
}

class LoadingRepoEntry extends RepoEntry {
  final String _repoName;
  bool _closeAfter = false;

  LoadingRepoEntry(this._repoName);

  @override
  String get name => _repoName;

  Future<void> close() async {
    _closeAfter = true;
  }

  @override
  oui.Repository? get maybeHandle => null;

  @override
  String? get id => null;

  @override
  Folder? get currentFolder => null;

  @override
  RepoCubit? get maybeCubit => null;
}

class OpenRepoEntry extends RepoEntry {
  final RepoCubit _cubit;

  OpenRepoEntry(this._cubit);

  RepoCubit get cubit => _cubit;

  @override
  RepoCubit? get maybeCubit => _cubit;

  Future<void> close() async {
    await _cubit.close();
  }

  @override
  String get name => _cubit.name;

  oui.Repository get handle => _cubit.handle;

  @override
  oui.Repository? get maybeHandle => _cubit.handle;

  @override
  String? get id => _cubit.id;

  @override
  Folder? get currentFolder => _cubit.currentFolder;
}
