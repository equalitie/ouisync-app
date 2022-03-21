import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/loggers/ouisync_app_logger.dart';

class SimpleBlocObserver extends BlocObserver with OuiSyncAppLogger {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    loggy.app('${bloc.runtimeType} $change');
  }
}