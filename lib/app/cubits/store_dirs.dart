import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:ouisync/ouisync.dart' show Session;

import '../utils/storage_volume.dart';

class StoreDirsState {
  final List<StoreDir> dirs;

  const StoreDirsState({required this.dirs});
}

class StoreDir {
  final String path;
  final StorageVolume storageVolume;

  const StoreDir({required this.path, required this.storageVolume});
}

class StoreDirsCubit extends Cubit<StoreDirsState> {
  StoreDirsCubit(Session session) : super(StoreDirsState(dirs: [])) {
    // ...
  }

  @override
  Future<void> close() async {
    await super.close();

    //
  }

  Future<void> _update(Session session) async {
    // ...
  }
}
