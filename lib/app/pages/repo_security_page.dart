import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../cubits/repo_security.dart';
import '../models/access_mode.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../widgets/holder.dart';
import '../widgets/widgets.dart';

class RepoSecurityPage extends StatelessWidget {
  const RepoSecurityPage({
    required this.settings,
    required this.repo,
    required this.currentLocalSecret,
    required this.passwordHasher,
  });

  final Settings settings;
  final RepoCubit repo;
  final LocalSecret currentLocalSecret;
  final PasswordHasher passwordHasher;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(S.current.titleSecurity), elevation: 0.0),
        body: BlocHolder(
          create: () => RepoSecurityCubit(
            oldLocalSecretMode: repo.state.authMode.localSecretMode,
            oldLocalSecret: currentLocalSecret,
          ),
          builder: _buildContent,
        ),
      );

  ContentWithStickyFooterState _buildContent(
    BuildContext context,
    RepoSecurityCubit cubit,
  ) =>
      ContentWithStickyFooterState(
        content: PopScope(
          canPop: false,
          onPopInvoked: (didPop) => _onPopInvoked(context, didPop, cubit.state),
          child: RepoSecurity(cubit, repo.state.accessMode == AccessMode.blind),
        ),
        footer: BlocBuilder<RepoSecurityCubit, RepoSecurityState>(
          bloc: cubit,
          builder: (context, state) => Fields.inPageButton(
            text: S.current.actionUpdate,
            onPressed: state.hasPendingChanges && state.isValid
                ? () => _onSubmit(context, cubit)
                : null,
          ),
        ),
      );

  void _onPopInvoked(
    BuildContext context,
    bool didPop,
    RepoSecurityState state,
  ) {
    if (didPop) {
      return;
    }

    if (!state.hasPendingChanges) {
      Navigator.pop(context);
      return;
    }

    Dialogs.alertDialogWithActions(
      context: context,
      title: S.current.titleUnsavedChanges,
      body: [Text(S.current.messageUnsavedChanges)],
      actions: [
        TextButton(
            child: Text(S.current.actionCancel),
            onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
            child: Text(S.current.actionDiscard),
            onPressed: () => Navigator.of(context).pop(true))
      ],
    ).then((pop) {
      if (pop ?? false) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _onSubmit(BuildContext context, RepoSecurityCubit cubit) async {
    final confirm = await _confirmSaveChanges(context);
    if (!confirm) {
      return;
    }

    if (await cubit.apply(
      repo,
      passwordHasher: passwordHasher,
      masterKey: settings.masterKey,
    )) {
      showSnackBar(S.current.messageUpdateLocalSecretOk);
    } else {
      showSnackBar(S.current.messageUpdateLocalSecretFailed);
    }
  }

  Future<bool> _confirmSaveChanges(BuildContext context) async {
    final message = S.current.messageConfirmIrreversibleChange;

    final saveChanges = await Dialogs.alertDialogWithActions(
      context: context,
      title: S.current.titleSaveChanges,
      body: [Text(message, style: context.theme.appTextStyle.bodyMedium)],
      actions: [
        TextButton(
            child: Text(S.current.actionCancel),
            onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
            child: Text(S.current.actionAccept),
            onPressed: () => Navigator.of(context).pop(true))
      ],
    );

    return saveChanges ?? false;
  }
}
