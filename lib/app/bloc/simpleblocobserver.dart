import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/loggers/ouisync_app_logger.dart';

class SimpleBlocObserver extends BlocObserver with OuiSyncAppLogger {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    loggy.app('onCreate ${bloc.runtimeType}');
  }
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    loggy.app('onError ${bloc.runtimeType} $error');
  }
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    loggy.app('onClose ${bloc.runtimeType}');
  }
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    loggy.app('onEvent ${bloc.runtimeType} $event');
  }
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    loggy.app('onTransition ${bloc.runtimeType} $transition');
  }
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    loggy.app('onChange ${bloc.runtimeType} $change');
  }
}
