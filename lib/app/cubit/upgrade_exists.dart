import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import '../utils/loggers/ouisync_app_logger.dart';

class UpgradeExistsCubit extends Cubit<bool> with OuiSyncAppLogger {
  UpgradeExistsCubit() : super(true);

  Future<void> foundNewerVersion() async {
    emit(true);
  }
}
