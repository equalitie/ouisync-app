import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_app/app/widgets/repo_creation.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../cubits/repo_creation.dart';
import '../utils/utils.dart';

class RepoCreationPage extends StatefulWidget {
  RepoCreationPage({
    required this.reposCubit,
    this.initialTokenValue,
  });

  final ReposCubit reposCubit;
  final String? initialTokenValue;

  @override
  State<RepoCreationPage> createState() => _RepoCreationPageState();
}

class _RepoCreationPageState extends State<RepoCreationPage> with AppLogger {
  late RepoCreationCubit repoCreationCubit;

  @override
  void initState() {
    super.initState();
    repoCreationCubit = RepoCreationCubit(reposCubit: widget.reposCubit);
    repoCreationCubit.setInitialTokenValue(widget.initialTokenValue);
  }

  @override
  void dispose() {
    unawaited(repoCreationCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.titleCreateRepository),
          elevation: 0.0,
        ),
        body: RepoCreation(repoCreationCubit),
      );
}
