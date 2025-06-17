import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/utils/share_token.dart';
import 'utils.dart';

class RepoImportCubit extends Cubit<ShareTokenResult?> with CubitActions {
  RepoImportCubit({required this.reposCubit}) : super(null) {
    tokenController.addListener(
      () => unawaited(setToken(tokenController.text)),
    );
  }

  final ReposCubit reposCubit;
  final tokenController = TextEditingController();

  @override
  Future<void> close() async {
    tokenController.dispose();
    await super.close();
  }

  Future<void> setToken(String input) async {
    final result = await parseShareToken(reposCubit, input);
    emitUnlessClosed(result);
  }
}
