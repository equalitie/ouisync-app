import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../utils/log.dart';
import 'repo.dart';

/// Cubit representing sync progress of a file.
class FileProgress extends Cubit<int?> with AppLogger {
  FileProgress(RepoCubit repo, this.path) : super(null) {
    _subscription = repo.handle.events
        .startWith(null)
        .asyncMapSample((_) => _fetch(repo))
        .listen(
          emit,
          onError: (e, st) {}, // these errors are not important - ignore
        );

    loggy.debug('$runtimeType for $path created');
  }

  final String path;
  StreamSubscription<int?>? _subscription;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();

    loggy.debug('$runtimeType for $path closed');
  }

  Future<int?> _fetch(RepoCubit repo) async {
    final file = await repo.openFile(path);

    if (file == null) {
      return null;
    }

    // To avoid read-locking the file for longer than necessary, close it before awaiting the result.
    final future = file.progress;
    await file.close();

    loggy.debug("$runtimeType for $path fetch start");
    final value = await future;
    loggy.debug("$runtimeType for $path fetch done: $value");

    return value;
  }
}
