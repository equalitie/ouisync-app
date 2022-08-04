part of 'cubit.dart';

class Job {
  int soFar;
  int total;
  bool cancel = false;
  Job(this.soFar, this.total);
}

class RepoState with OuiSyncAppLogger {
  bool isLoading = false;
  final Map<String, cubits.Watch<Job>> uploads = HashMap();
  final Map<String, cubits.Watch<Job>> downloads = HashMap();
  final List<String> messages = <String>[];

  String name;

  // TODO: Ideally, this shouldn't be exposed.
  oui.Repository handle;

  RepoState(this.name, this.handle);

  oui.AccessMode get accessMode => handle.accessMode;
  String get id => handle.lowHexId();

  bool isDhtEnabled() => handle.isDhtEnabled();
  void enableDht() { handle.enableDht(); }
  void disableDht() { handle.disableDht(); }

  Future<oui.Directory> openDirectory(String path) async {
    return await oui.Directory.open(handle, path);
  }

  // NOTE: This operator is required for the DropdownMenuButton to show
  // entries properly.
  @override
  bool operator==(Object other) {
    if (identical(this, other)) return true;
    return other is RepoState && id == other.id;
  }

  Future<BasicResult> deleteFolder(String path, bool recursive) async {
    BasicResult deleteFolderResult;
    String error = '';

    try {
      await oui.Directory.remove(handle, path, recursive: recursive);
    } catch (e, st) {
      loggy.app('Delete folder $path exception', e, st);
      error = 'Delete folder $path failed';
    }

    deleteFolderResult = DeleteFolderResult(functionName: 'deleteFolder', result: 'OK');
    if (error.isNotEmpty) {
      deleteFolderResult.errorMessage = error;
    }

    return deleteFolderResult;
  }

  Future<void> close() async {
    await handle.close();
  }
}
