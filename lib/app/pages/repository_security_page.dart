import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../cubits/security.dart';
import '../mixins/repo_actions_mixin.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class RepositorySecurity extends StatefulWidget {
<<<<<<< HEAD
  const RepositorySecurity(
      {required this.repo,
      required this.password,
      required this.shareToken,
      required this.isBiometricsAvailable});
=======
  const RepositorySecurity({
    required this.repo,
    required this.password,
    required this.isBiometricsAvailable,
    required this.authenticationMode,
  });
>>>>>>> b448ecee (Update to the new local secrets / access mode API)

  final RepoCubit repo;
  final String password;
  final bool isBiometricsAvailable;

  @override
  State<RepositorySecurity> createState() => _RepositorySecurityState();
}

class _RepositorySecurityState extends State<RepositorySecurity>
    with AppLogger, RepositoryActionsMixin {
  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  final TextEditingController _passwordController =
      TextEditingController(text: null);
  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

  late final SecurityCubit security;

  final FocusNode _passwordAction = FocusNode(debugLabel: 'password_input');

  @override
  void initState() {
    security = SecurityCubit.create(
        repoCubit: widget.repo,
        isBiometricsAvailable: widget.isBiometricsAvailable,
        password: widget.password);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(S.current.titleSecurity), elevation: 0.0),
      body: SingleChildScrollView(
          child: Container(
              child: BlocBuilder<SecurityCubit, SecurityState>(
                  bloc: security,
                  builder: (context, state) => Column(children: [
                        _pasword(state),
                        Divider(height: 30.0),
                        _biometrics(state)
                      ])))));

  Widget _pasword(SecurityState state) {
    return Container(
        padding: Dimensions.paddingDialog,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(state.passwordModeTitle),
          Dimensions.spacingVerticalDouble,
          PasswordValidation(
              passwordMode: state.passwordMode,
              passwordInputKey: _passwordInputKey,
              retypePasswordInputKey: _retypePasswordInputKey,
              passwordController: _passwordController,
              retypedPasswordController: _retypedPasswordController,
              actions: _passwordActions),
          Dimensions.spacingVertical
        ]));
  }

  Widget _passwordActions(PasswordMode passwordMode) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: passwordMode == PasswordMode.manual
          ? [
              Row(children: [
                TextButton(
                    focusNode: _passwordAction,
                    child: Text(S.current.actionRemoveLocalPassword,
                        style: context.theme.appTextStyle.bodyMedium
                            .copyWith(color: Constants.dangerColor)),
                    onPressed: () async {
                      final positiveButtonText = S.current.actionRemove;
                      final confirmationMessage =
                          S.current.messageRemoveLocalPasswordConfirmation;

                      final saveChanges = await confirmSaveChanges(
                        context,
                        positiveButtonText,
                        confirmationMessage,
                      );

                      if (saveChanges == null || !saveChanges) return;

                      await Dialogs.executeFutureWithLoadingDialog(context,
                          f: _removePassword());
                    })
              ]),
              Dimensions.spacingVertical,
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Fields.inPageButton(
                    onPressed: () async {
                      final password = _retypedPasswordController.text;
                      if (password.isEmpty) return;

                      final newPassword = validatePassword(password,
                          passwordInputKey: _passwordInputKey,
                          retypePasswordInputKey: _retypePasswordInputKey);

                      if (newPassword == null) return;

                      final positiveButtonText = S.current.actionUpdate;
                      final confirmationMessage =
                          S.current.messageUpdateLocalPasswordConfirmation;

                      final saveChanges = await confirmSaveChanges(
                          context, positiveButtonText, confirmationMessage);

                      if (saveChanges == null || !saveChanges) return;

                      await Dialogs.executeFutureWithLoadingDialog(context,
                          f: _updateLocalPassword(newPassword));
                    },
                    text: S.current.actionUpdate,
                    size: Dimensions.sizeInPageButtonLong,
                    focusNode: _passwordAction)
              ])
            ]
          : [
              Fields.inPageButton(
                  onPressed: passwordMode == PasswordMode.none
                      ? () async {
                          final password = _retypedPasswordController.text;
                          if (password.isEmpty) return;

                          final newPassword = validatePassword(password,
                              passwordInputKey: _passwordInputKey,
                              retypePasswordInputKey: _retypePasswordInputKey);

                          if (newPassword == null) return;

                          final positiveButtonText = S.current.actionAdd;
                          final confirmationMessage =
                              S.current.messageAddLocalPasswordConfirmation;

                          final saveChanges = await confirmSaveChanges(
                              context, positiveButtonText, confirmationMessage);

                          if (saveChanges == null || !saveChanges) return;

                          _passwordController.clear();
                          _retypedPasswordController.clear();

                          await Dialogs.executeFutureWithLoadingDialog(context,
                              f: _addLocalPassword(newPassword));
                        }
                      : null,
                  text: S.current.actionCreate,
                  size: Dimensions.sizeInPageButtonLong,
                  focusNode: _passwordAction)
            ]);

  Widget _biometrics(SecurityState state) =>
      BlocBuilder<SecurityCubit, SecurityState>(
          bloc: security,
          builder: (context, state) => state.isBiometricsAvailable
              ? Column(children: [
                  SwitchListTile.adaptive(
                      value: state.unlockWithBiometrics,
                      secondary:
                          Icon(Icons.fingerprint_rounded, color: Colors.black),
                      title: Text(S.current.messageUnlockUsingBiometrics,
                          style: context.theme.appTextStyle.bodyMedium),
                      onChanged: (useBiometrics) async {
                        final positiveButtonText = S.current.actionAccept;
                        String confirmationMessage = useBiometrics
                            ? S.current.messageUnlockUsingBiometricsConfirmation
                            : S.current.messageRemoveBiometricsConfirmation;

                        if (useBiometrics &&
                            state.passwordMode == PasswordMode.manual) {
                          confirmationMessage +=
                              '\n\n${S.current.messageRemoveBiometricsConfirmationMoreInfo}.';
                        }

                        final saveChanges = await confirmSaveChanges(
                            context, positiveButtonText, confirmationMessage);

                        if (saveChanges == null || !saveChanges) return;

                        await Dialogs.executeFutureWithLoadingDialog(context,
                            f: _updateUnlockWithBiometrics(useBiometrics));
                      })
                ])
              : SizedBox());

  Future<void> _addLocalPassword(String newPassword) async {
    final addLocalPasswordResult = await security.addLocalPassword(newPassword);

    if (addLocalPasswordResult != null) {
      showSnackBar(context, message: addLocalPasswordResult);
      return;
    }

    _clearPasswordInputs();
  }

  Future<void> _updateLocalPassword(String newPassword) async {
    final updateRepoLocalPasswordResult =
        await security.updateLocalPassword(newPassword);

    if (updateRepoLocalPasswordResult != null) {
      showSnackBar(context, message: updateRepoLocalPasswordResult);
      return;
    }

    _clearPasswordInputs();
  }

  void _clearPasswordInputs() {
    _passwordController.clear();
    _retypedPasswordController.clear();

    _passwordAction.requestFocus();
  }

  Future<void> _removePassword() async {
    final removeRepoLocalPasswordResult = await security.removeLocalPassword();

    if (removeRepoLocalPasswordResult != null) {
      showSnackBar(context, message: removeRepoLocalPasswordResult);
    }
  }

  Future<void> _updateUnlockWithBiometrics(bool unlockWithBiometrics) async {
    final updateUnlockRepoWithBiometricsResult =
        await security.updateUnlockRepoWithBiometrics(unlockWithBiometrics);

    if (updateUnlockRepoWithBiometricsResult != null) {
      showSnackBar(context, message: updateUnlockRepoWithBiometricsResult);
      return;
    }

    _clearPasswordInputs();
  }
}
