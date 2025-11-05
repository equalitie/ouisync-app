import 'dart:async' show StreamController;
import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path_provider/path_provider.dart';

/// One of the MethodChannel handlers used for calling functions implemented
/// natively, and viceversa. See also ouisync/bindings/dart/native_channels and
/// TODO: merge them into a single ouisync channel, some time around when we
/// finally rename the bindings to libouisync and the UI to ouisync proper
class Native {
  Native._() {
    _channel.setMethodCallHandler(_methodHandler);
  }

  static final instance = Native._();

  final _channel = MethodChannel('org.equalitie.ouisync/native');
  final _storageVolumeChangedController = StreamController<void>.broadcast();

  Stream<void> get storageVolumeChanged =>
      _storageVolumeChangedController.stream;

  Future<void> log(LogLevel level, String message) =>
      _channel.invokeMethod('log', [level.toInt(), message]);

  /// In Android, it retrieves the legacy path to the Download directory
  Future<String?> getDownloadPathForAndroid() =>
      _channel.invokeMethod<String>('getDownloadPath');

  // On MacOS this returns the root of the directory where files and folders are stored.
  // Should be something like ~/Library/CloudStorage/Ouisync-<Domain>`.
  Future<String?> getMountRootDirectory() =>
      _channel.invokeMethod<String>('getMountRootDirectory');

  /// Path to a directory where the application may place application support
  /// files. If this directory does not exist, it is created automatically.
  Future<io.Directory> getBaseDir() async {
    if (io.Platform.isIOS || io.Platform.isMacOS) {
      // on Darwin, we can't use the default implementation because the UI and
      // backend run in different address spaces and file sandboxes, so we defer
      // this decision to the host to allow for maximum customizability
      // TODO: delegate this decision to the host on all platforms instead?
      return io.Directory(await _channel.invokeMethod('getSharedDir'));
    } else {
      // default to the path provider plugin; this usually means the homedir
      return getApplicationSupportDirectory();
    }
  }

  Future<Uri> getDocumentUri(String path) => _channel
      .invokeMethod<String>('getDocumentUri', [path])
      .then((uri) => Uri.parse(uri!));

  Future<
    ({
      String description,
      String? mountPoint,
      bool isPrimary,
      bool isRemovable,
      bool isMounted,
    })?
  >
  getStorageVolume(String path) => _channel
      .invokeMapMethod<String, Object?>('getStorageVolume', [path])
      .then(
        (map) => map != null
            ? (
                description: map['description'] as String,
                mountPoint: map['mountPoint'] as String?,
                isPrimary: map['isPrimary'] as bool,
                isRemovable: map['isRemovable'] as bool,
                isMounted: map['isMounted'] as bool,
              )
            : null,
      );

  /// Handler method in charge of picking the right function based in the
  /// [call.method].
  ///
  /// [call] is the object sent from the native platform with the function name ([call.method])
  /// and any arguments included ([call.arguments])
  Future<dynamic> _methodHandler(MethodCall call) async {
    switch (call.method) {
      case 'storageVolumeChanged':
        _storageVolumeChangedController.add(null);
      default:
        throw PlatformException(
          code: '0',
          message: 'No such method: "${call.method}"',
        );
    }
  }
}
