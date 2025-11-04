import 'dart:io' show Platform;

import 'native.dart';

/// Information about a storage volume on the device.
class StorageVolume {
  const StorageVolume({
    required this.description,
    required this.primary,
    required this.removable,
    required this.state,
  });

  final String description;
  final bool primary;
  final bool removable;
  final StorageVolumeState state;

  /// Retrieve storage volume that contains the given path.
  ///
  /// Note this currently works only on Android (returns `null` on other platforms).
  static Future<StorageVolume?> forPath(String path) => Platform.isAndroid
      ? Native.getStorageProperties(path).then(
          (props) => props != null
              ? StorageVolume(
                  description: props.description,
                  primary: props.primary,
                  removable: props.removable,
                  state: props.mounted
                      ? StorageVolumeMounted(mountPoint: props.mountPoint)
                      : StorageVolumeUnmounted(),
                )
              : null,
        )
      : Future.value(null);

  @override
  bool operator ==(Object other) =>
      other is StorageVolume &&
      description == other.description &&
      primary == other.primary &&
      removable == other.removable &&
      state == other.state;

  @override
  int get hashCode => Object.hash(description, primary, removable, state);

  @override
  String toString() =>
      '$runtimeType(description: $description, primary: $primary, removable: $removable, state: $state)';
}

sealed class StorageVolumeState {}

class StorageVolumeMounted extends StorageVolumeState {
  // This property is only supported on Android 30 or later. On older versions it's always `null`.
  final String? mountPoint;

  StorageVolumeMounted({required this.mountPoint});

  @override
  String toString() =>
      mountPoint != null ? 'mounted at $mountPoint' : 'mounted';

  @override
  bool operator ==(Object other) =>
      other is StorageVolumeMounted && mountPoint == other.mountPoint;

  @override
  int get hashCode => mountPoint.hashCode;
}

class StorageVolumeUnmounted extends StorageVolumeState {
  @override
  String toString() => 'unmounted';

  @override
  bool operator ==(Object other) => other is StorageVolumeUnmounted;

  @override
  int get hashCode => 0;
}
