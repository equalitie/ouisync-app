import 'package:loggy/loggy.dart';

class OuiSyncAppLogger implements LoggyType {
  @override
  Loggy<LoggyType> get loggy => Loggy<OuiSyncAppLogger>('ouisync-app - $runtimeType');
}