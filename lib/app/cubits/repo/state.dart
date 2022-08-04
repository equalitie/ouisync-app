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
}
