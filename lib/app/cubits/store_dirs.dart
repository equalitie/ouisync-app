import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:ouisync/ouisync.dart' show Session;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectories;

import '../utils/dirs.dart';
import '../utils/native.dart';
import '../utils/storage_volume.dart';

const _name = 'repositories';

class StoreDirs extends Iterable<StoreDir> {
  final List<StoreDir> values;

  const StoreDirs([this.values = const []]);

  @override
  Iterator<StoreDir> get iterator => values.iterator;

  @override
  int get length => values.length;

  @override
  bool operator ==(Object other) =>
      other is StoreDirs && listEquals(values, other.values);

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() => '$runtimeType($values)';
}

class StoreDir {
  final String path;
  final StorageVolume volume;

  const StoreDir({required this.path, required this.volume});

  @override
  bool operator ==(Object other) =>
      other is StoreDir && path == other.path && volume == other.volume;

  @override
  int get hashCode => Object.hash(path, volume);

  @override
  String toString() => '$runtimeType(path: $path, volume: $volume)';
}

class StoreDirsCubit extends Cubit<StoreDirs> {
  final Session _session;
  final Dirs _dirs;

  StoreDirsCubit(this._session, this._dirs) : super(StoreDirs()) {
    unawaited(_update());
    Native.instance.registerStorageVolumeCallback(_update);
  }

  @override
  Future<void> close() async {
    Native.instance.unregisterStorageVolumeCallback(_update);
    await super.close();
  }

  Future<void> _update() async {
    List<StoreDir> dirs;

    if (Platform.isAndroid) {
      dirs = await getExternalStorageDirectories()
          .then((dirs) => (dirs ?? []).map((dir) => join(dir.path, _name)))
          .then(_fromPaths)
          .then(
            (dirs) => dirs
                .where((dir) => dir.volume.state is StorageVolumeMounted)
                .toList(),
          );

      await _session.setStoreDirs(dirs.paths);
    } else {
      final path = join(_dirs.root, _name);
      final volume = StorageVolume(
        description: '',
        isPrimary: false,
        isRemovable: false,
        state: StorageVolumeMounted(mountPoint: path),
      );

      dirs = [StoreDir(path: path, volume: volume)];

      // Using `insertStoreDirs` so that any custom dirs (set via the CLI app or other means) are
      // preserved.
      await _session.insertStoreDirs(dirs.paths);
    }

    if (!isClosed) {
      emit(StoreDirs(dirs));
    }
  }
}

Future<List<StoreDir>> _fromPaths(Iterable<String> paths) => Future.wait(
  paths.map(
    (path) => StorageVolume.forPath(path).then(
      (volume) => volume != null ? StoreDir(path: path, volume: volume) : null,
    ),
  ),
).then((dirs) => dirs.nonNulls.toList());

extension on List<StoreDir> {
  List<String> get paths => map((dir) => dir.path).toList();
}
