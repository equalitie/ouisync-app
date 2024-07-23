import 'package:flutter/services.dart';

/// MethodChannel handler for calling functions
/// implemented natively, and viceversa.
class Native {
  static const MethodChannel _channel =
      MethodChannel('org.equalitie.ouisync_app/native');

  /// Sets the method handler for the calls to and from native implementations.
  static void init() {
    _channel.setMethodCallHandler(_methodHandler);
  }

  /// Handler method in charge of picking the right function based in the
  /// [call.method].
  ///
  /// [call] is the object sent from the native platform with the function name ([call.method])
  /// and any arguments included ([call.arguments])
  static Future<dynamic> _methodHandler(MethodCall call) async {}

  /// In Android, it retrieves the legacy path to the Download directory
  static Future<String> getDownloadPathForAndroid() async {
    final dynamic result = await _channel.invokeMethod('getDownloadPath');
    return result;
  }

  /// In iOS or MacOS, it retrieves the default path where repositories shall be stored
  static Future<String> getDefaultRepositoriesDirectory() async {
    return await _channel.invokeMethod('getDefaultRepositoriesDirectory');
  }
}
