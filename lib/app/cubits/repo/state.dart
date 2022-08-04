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

  Future<void> close() async {
    await handle.close();
  }
}
