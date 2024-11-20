import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../pages/repo_reset_access.dart';
import '../cubits/cubits.dart'
    show RepoCubit, RepoSecurityCubit, RepoSecurityState;
import '../models/models.dart'
    show LocalSecret, Access, BlindAccess, ReadAccess, WriteAccess;
import '../utils/utils.dart'
    show
        AppThemeExtension,
        Dialogs,
        Fields,
        PasswordHasher,
        Settings,
        showSnackBar,
        ThemeGetter;
import '../widgets/widgets.dart'
    show
        BlocHolder,
        ContentWithStickyFooterState,
        DirectionalAppBar,
        RepoSecurity,
        LinkStyleAsyncButton;

class RepoSecurityPage extends StatefulWidget {
  const RepoSecurityPage({
    required this.settings,
    required this.repo,
    required this.localSecret,
    required this.passwordHasher,
  });

  final Settings settings;
  final RepoCubit repo;
  final LocalSecret localSecret;
  final PasswordHasher passwordHasher;

  @override
  State<RepoSecurityPage> createState() => _State(localSecret);
}

class _State extends State<RepoSecurityPage> {
  LocalSecret? currentLocalSecret;

  _State(this.currentLocalSecret);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DirectionalAppBar(title: Text(S.current.titleSecurity)),
        body: BlocHolder(
          create: () => RepoSecurityCubit(
            oldLocalSecretMode: widget.repo.state.authMode.localSecretMode,
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
          onPopInvokedWithResult: (didPop, _) =>
              _onPopInvoked(context, didPop, cubit.state),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (currentLocalSecret != null) RepoSecurity(cubit, isBlind: false),
            // TODO: Arbitrary size, this can likely be done better.
            SizedBox(height: 14),
            _buildResetRepoUsingTokenButton(context),
          ]),
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

  Widget _buildResetRepoUsingTokenButton(BuildContext context) {
    return LinkStyleAsyncButton(
        text: "Reset repository access using a share token",
        onTap: () async {
          final newAccess = await RepoResetAccessPage.show(
              context, widget.repo, widget.settings);

          switch (newAccess) {
            case null:
              return;
            case BlindAccess():
              setState(() {
                currentLocalSecret = null;
              });
              Navigator.pop(context);
            case ReadAccess():
              setState(() {
                currentLocalSecret = newAccess.localSecret;
              });
            case WriteAccess():
              setState(() {
                currentLocalSecret = newAccess.localSecret;
              });
          }
        });
  }

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
            onPressed: () async => await Navigator.of(context).maybePop(false)),
        TextButton(
            child: Text(S.current.actionDiscard),
            onPressed: () async => await Navigator.of(context).maybePop(true))
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
      widget.repo,
      passwordHasher: widget.passwordHasher,
      masterKey: widget.settings.masterKey,
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
            onPressed: () async => await Navigator.of(context).maybePop(false)),
        TextButton(
            child: Text(S.current.actionAccept),
            onPressed: () async => await Navigator.of(context).maybePop(true))
      ],
    );

    return saveChanges ?? false;
  }
}
