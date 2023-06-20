import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as o;

mixin OuiSyncAppLogger implements LoggyType {
  @override
  Loggy<LoggyType> get loggy => Loggy<OuiSyncAppLogger>(runtimeType.toString());
}

const LogLevel appLevel = LogLevel('OuiSync', 2); // 2 == debug

extension OuiSyncAppLoggy on Loggy {
  void app(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(appLevel, message, error, stackTrace);
}

class AppLogPrinter extends LoggyPrinter {
  @override
  void onLog(LogRecord record) {
    final level = _convertLogLevel(record.level);

    final message = StringBuffer(record.message);

    if (record.error != null) {
      message.write(' ${record.error}');
    }

    if (record.stackTrace != null) {
      message.write('\n${record.stackTrace}');
    }

    o.logPrint(level, record.loggerName, message.toString());
  }
}

o.LogLevel _convertLogLevel(LogLevel level) {
  if (level.priority == 1) {
    return o.LogLevel.trace;
  }

  if (level.priority == LogLevel.debug.priority) {
    return o.LogLevel.debug;
  }

  if (level.priority == LogLevel.info.priority) {
    return o.LogLevel.info;
  }

  if (level.priority == LogLevel.warning.priority) {
    return o.LogLevel.warn;
  }

  if (level.priority == LogLevel.error.priority) {
    return o.LogLevel.error;
  }

  throw 'unsupported log level $level';
}
