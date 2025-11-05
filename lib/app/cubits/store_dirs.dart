import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:ouisync/ouisync.dart' show Session;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectories;

import '../utils/dirs.dart';
import '../utils/native.dart';
import '../utils/storage_volume.dart';

const _name = 'repositories';

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

class StoreDirsCubit extends Cubit<List<StoreDir>> {
  final Session _session;
  final Dirs _dirs;

  StoreDirsCubit(this._session, this._dirs) : super([]) {
    unawaited(_update());
    Native.instance.registerStorageVolumeCallback(_update);
  }

  @override
  Future<void> close() async {
    Native.instance.unregisterStorageVolumeCallback(_update);
    await super.close();
  }

  Future<void> _update() async {
    List<StoreDir> storeDirs;

    if (Platform.isAndroid) {
      storeDirs = await getExternalStorageDirectories()
          .then((dirs) => (dirs ?? []).map((dir) => join(dir.path, _name)))
          .then(_fromPaths)
          .then(
            (dirs) => dirs
                .where((dir) => dir.volume.state is StorageVolumeMounted)
                .toList(),
          );

      await _session.setStoreDirs(storeDirs.paths);
    } else {
      final path = join(_dirs.root, _name);
      final volume = StorageVolume(
        description: '',
        isPrimary: false,
        isRemovable: false,
        state: StorageVolumeMounted(mountPoint: path),
      );

      storeDirs = [StoreDir(path: path, volume: volume)];

      // Using `insertStoreDirs` so that any custom dirs (set via the CLI app or other means) are
      // preserved.
      await _session.insertStoreDirs(storeDirs.paths);
    }

    if (!isClosed) {
      emit(storeDirs);
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
