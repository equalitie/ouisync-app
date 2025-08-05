import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show Session;

import '../../generated/l10n.dart';
import '../pages/repo_reset_access.dart';
import '../cubits/cubits.dart'
    show RepoCubit, RepoSecurityCubit, RepoSecurityState;
import '../models/models.dart' show UnlockedAccess;
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
        LinkStyleAsyncButton,
        CustomAdaptiveSwitch,
        PasswordValidation;
import '../models/models.dart' show SecretKeyOrigin;

//--------------------------------------------------------------------

class RepoSecurityPage extends StatefulWidget {
  static Future<void> show(
    BuildContext context,
    Settings settings,
    Session session,
    RepoCubit repo,
    UnlockedAccess originalAccess,
    PasswordHasher passwordHasher,
  ) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RepoSecurityPage(
        settings,
        session,
        repo,
        originalAccess,
        passwordHasher,
      ),
    ),
  );

  const RepoSecurityPage(
    this.settings,
    this.session,
    this.repo,
    this.originalAccess,
    this.passwordHasher,
  );

  final Settings settings;
  final Session session;
  final RepoCubit repo;
  final UnlockedAccess originalAccess;
  final PasswordHasher passwordHasher;

  @override
  State<RepoSecurityPage> createState() => _State(originalAccess);
}

//--------------------------------------------------------------------

class _State extends State<RepoSecurityPage> {
  UnlockedAccess access;

  _State(this.access);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DirectionalAppBar(title: Text(S.current.titleSecurity)),
    body: BlocHolder(
      create: () => RepoSecurityCubit(
        currentLocalSecretMode: widget.repo.state.authMode.localSecretMode,
        currentAccess: access,
      ),
      builder: _buildContent,
    ),
  );

  ContentWithStickyFooterState _buildContent(
    BuildContext context,
    RepoSecurityCubit cubit,
  ) => ContentWithStickyFooterState(
    content: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) =>
          _onPopInvoked(context, didPop, cubit.state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RepoSecurityWidget(cubit),
          // TODO: Arbitrary size, this can likely be done better.
          SizedBox(height: 14),
          _buildResetRepoUsingTokenButton(context),
        ],
      ),
    ),
    footer: BlocBuilder<RepoSecurityCubit, RepoSecurityState>(
      bloc: cubit,
      builder: (context, state) => Fields.inPageAsyncButton(
        key: Key('security-update-button'),
        text: S.current.actionUpdate,
        onPressed: state.hasPendingChanges && state.isValid
            ? () => _onSubmit(context, cubit)
            : null,
      ),
    ),
  );

  Widget _buildResetRepoUsingTokenButton(BuildContext context) {
    return LinkStyleAsyncButton(
      key: Key('enter-repo-reset-screen'), // Used in tests
      text: "Reset repository access using a share token",
      onTap: () async {
        final newAccess = await RepoResetAccessPage.show(
          context: context,
          session: widget.session,
          settings: widget.settings,
          repo: widget.repo,
          startAccess: access,
        );

        final unlockedAccess = newAccess.asUnlocked;

        if (unlockedAccess == null) {
          Navigator.pop(context);
          return;
        }

        setState(() {
          access = unlockedAccess;
        });
      },
    );
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
      context,
      title: S.current.titleUnsavedChanges,
      body: [Text(S.current.messageUnsavedChanges)],
      actions: [
        TextButton(
          child: Text(S.current.actionCancel),
          onPressed: () async => await Navigator.of(context).maybePop(false),
        ),
        TextButton(
          child: Text(S.current.actionDiscard),
          onPressed: () async => await Navigator.of(context).maybePop(true),
        ),
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
      context,
      title: S.current.titleSaveChanges,
      body: [Text(message, style: context.theme.appTextStyle.bodyMedium)],
      actions: [
        TextButton(
          child: Text(S.current.actionCancel),
          onPressed: () async => await Navigator.of(context).maybePop(false),
        ),
        TextButton(
          child: Text(S.current.actionAccept),
          onPressed: () async => await Navigator.of(context).maybePop(true),
        ),
      ],
    );

    return saveChanges ?? false;
  }
}

//--------------------------------------------------------------------

class RepoSecurityWidget extends StatelessWidget {
  const RepoSecurityWidget(this.cubit, {super.key});

  final RepoSecurityCubit cubit;

  @override
  Widget build(BuildContext context) {
    final warningStyle = context.theme.appTextStyle.bodyMedium.copyWith(
      color: Colors.red,
    );

    return BlocBuilder<RepoSecurityCubit, RepoSecurityState>(
      bloc: cubit,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOriginSwitch(state),
          _buildPasswordFields(state),
          _buildStoreSwitch(state),
          _buildSecureWithBiometricsSwitch(state),
          _buildManualPasswordWarning(state, warningStyle),
        ],
      ),
    );
  }

  Widget _buildPasswordFields(RepoSecurityState state) =>
      switch (state.plannedOrigin) {
        SecretKeyOrigin.manual => PasswordValidation(
          onChanged: cubit.setLocalPassword,
          required: state.isLocalPasswordRequired,
        ),
        SecretKeyOrigin.random => SizedBox.shrink(),
      };

  Widget _buildOriginSwitch(RepoSecurityState state) => _buildSwitch(
    key: Key('use-local-password'), // Used in tests
    value: state.plannedOrigin == SecretKeyOrigin.manual,
    title: S.current.messageUseLocalPassword,
    onChanged: (value) => cubit.setOrigin(
      value ? SecretKeyOrigin.manual : SecretKeyOrigin.random,
    ),
  );

  Widget _buildStoreSwitch(RepoSecurityState state) =>
      switch (state.plannedOrigin) {
        SecretKeyOrigin.manual => _buildSwitch(
          key: Key('store-on-device'),
          value: state.secretWillBeStored,
          title: S.current.labelRememberPassword,
          onChanged: cubit.setStore,
        ),
        SecretKeyOrigin.random => SizedBox.shrink(),
      };

  // On desktops the keyring is accessible to any application once the user is
  // logged in into their account and thus giving the user the option to protect
  // their repository with system authentication might give them a false sense
  // of security. Therefore unlocking repositories with system authentication is
  // not supported on these systems.
  Widget _buildSecureWithBiometricsSwitch(RepoSecurityState state) =>
      state.isBiometricsAvailable
      ? _buildSwitch(
          value: state.plannedWithBiometrics.toBool,
          title: S.current.messageSecureUsingBiometrics,
          onChanged: state.isSecureWithBiometricsEnabled
              ? cubit.setSecureWithBiometrics
              : null,
        )
      : SizedBox.shrink();

  Widget _buildManualPasswordWarning(
    RepoSecurityState state,
    TextStyle warningStyle,
  ) {
    final visible = !state.secretWillBeStored;
    return _buildWarning(
      visible,
      S.current.messageRememberSavePasswordAlert,
      warningStyle,
    );
  }

  Widget _buildWarning(bool visible, String warning, TextStyle textStyle) =>
      Visibility(
        visible: visible,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 24.0),
          child: Fields.autosizeText(
            warning,
            style: textStyle,
            maxLines: 10,
            softWrap: true,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      );

  Widget _buildSwitch({
    Key? key,
    required bool value,
    required String title,
    required void Function(bool)? onChanged,
  }) => CustomAdaptiveSwitch(
    key: key,
    value: value,
    title: title,
    contentPadding: EdgeInsetsDirectional.zero,
    onChanged: onChanged,
  );
}
