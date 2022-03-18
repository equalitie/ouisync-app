import 'package:loggy/loggy.dart';

class OuiSyncAppLogger implements LoggyType {
  @override
  Loggy<LoggyType> get loggy => Loggy<OuiSyncAppLogger>('[$runtimeType]');
}

const LogLevel appLevel = LogLevel('ouisync-app', 1);

extension OuiSyncAppLoggy on Loggy {
  void app(dynamic message, [Object? error, StackTrace? stackTrace]) => log(appLevel, message, error, stackTrace);
}