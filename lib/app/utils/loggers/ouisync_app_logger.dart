import 'package:loggy/loggy.dart';

mixin OuiSyncAppLogger implements LoggyType {
  @override
  Loggy<LoggyType> get loggy =>
      Loggy<OuiSyncAppLogger>('ouisync-app -$runtimeType');
}

const LogLevel appLevel = LogLevel('OuiSync', 1);

extension OuiSyncAppLoggy on Loggy {
  void app(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(appLevel, message, error, stackTrace);
}
