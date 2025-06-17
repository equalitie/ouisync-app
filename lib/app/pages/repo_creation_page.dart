import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoCreationCubit, ReposCubit;
import '../widgets/widgets.dart'
    show BlocHolder, DirectionalAppBar, RepoCreation;

class RepoCreationPage extends StatelessWidget {
  RepoCreationPage({super.key, required this.reposCubit, this.token});

  final ReposCubit reposCubit;
  final ShareToken? token;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DirectionalAppBar(
      title: Text(
        token == null
            ? S.current.titleCreateRepository
            : S.current.titleAddRepository,
      ),
    ),
    body: BlocHolder(
      create: () => RepoCreationCubit(reposCubit: reposCubit)..setToken(token),
      builder: (context, cubit) => RepoCreation(cubit),
    ),
  );
}
