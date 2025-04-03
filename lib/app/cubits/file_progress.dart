import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import 'cubits.dart' show CubitActions, RepoCubit;

/// Cubit representing sync progress of a file.
class FileProgress extends Cubit<int?> with CubitActions {
  FileProgress(RepoCubit repo, this.path) : super(null) {
    _subscription =
        repo.events.startWith(null).asyncMapSample((_) => _fetch(repo)).listen(
              emitUnlessClosed,
              onError: (e, st) {}, // these errors are not important - ignore
            );
  }

  final String path;
  StreamSubscription<int?>? _subscription;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }

  Future<int?> _fetch(RepoCubit repo) async {
    final file = await repo.openFile(path);

    // To avoid read-locking the file for longer than necessary, close it before awaiting the result.
    final future = file.getProgress();
    await file.close();

    return await future;
  }
}
