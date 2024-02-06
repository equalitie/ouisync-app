import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/password_mode.dart';
import '../../utils/utils.dart';
import '../../utils/platform/platform.dart';
import '../widgets.dart';

class ManageDesktopPassword extends StatefulWidget {
  ManageDesktopPassword(
      {required this.context,
      required this.repoCubit,
      required this.action,
      required this.repositoryName,
      required this.passwordMode,
      required this.usesBiometrics});

  final BuildContext context;
  final RepoCubit repoCubit;
  final PasswordAction action;
  final String repositoryName;
  final PasswordMode passwordMode;
  final bool usesBiometrics;

  @override
  State<ManageDesktopPassword> createState() => _ManageDesktopPasswordState();
}

class _ManageDesktopPasswordState extends State<ManageDesktopPassword>
    with AppLogger {
  final _currentPasswordInputKey = GlobalKey<FormFieldState>();
  final _newPasswordInputKey = GlobalKey<FormFieldState>();
  final _retypeNewPasswordInputKey = GlobalKey<FormFieldState>();

  final TextEditingController _currentPasswordController =
      TextEditingController(text: null);

  final TextEditingController _newPasswordController =
      TextEditingController(text: null);
  final TextEditingController _retypedNewPasswordController =
      TextEditingController(text: null);

  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _retypeNewPasswordFocus = FocusNode();

  final _createButtonFocus = FocusNode();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureRetypeNewPassword = true;

  bool _requiresManualAuthentication = false;
  bool _samePassword = false;

  late final Future<bool> _buildingFuture;

  @override
  void initState() {
    _buildingFuture = _userAuthentication();

    super.initState();
  }

  Future<bool> _userAuthentication() async {
    final repoSettings = widget.repoCubit.repoSettings;
    final passwordMode = repoSettings.passwordMode;

    String currentPassword = '';

    if (passwordMode != PasswordMode.manual) {
      var validated = true;

      if (PlatformValues.isMobileDevice && passwordMode == PasswordMode.bio) {
        try {
          validated = await SecurityValidations.validateBiometrics();
        } on Exception catch (e, st) {
          loggy.app('Biometric authentication (local_auth) failed', e, st);
          validated = false;
        }

        if (!validated) {
          showSnackBar(S.current.messageBioAuthFailed);
          return false;
        }
      }

      currentPassword = repoSettings.getPassword()!;
    }

    _initStateValues(currentPassword);
    return true;
  }

  void _initStateValues(String currentPassword) {
    _requiresManualAuthentication =
        widget.action != PasswordAction.add && currentPassword.isEmpty;

    _currentPasswordController.text =
        _requiresManualAuthentication == false ? currentPassword : '';

    if (widget.passwordMode == PasswordMode.manual &&
        _requiresManualAuthentication) {
      _currentPasswordFocus.requestFocus();
      return;
    }

    _newPasswordController.text.isEmpty
        ? _newPasswordFocus.requestFocus()
        : _retypeNewPasswordFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _buildingFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError == false && snapshot.hasData == true) {
          final authenticationOk = snapshot.data;
          if (authenticationOk == false) {
            Navigator.of(context).pop(null);
          }
        }

        return Form(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              SingleChildScrollView(
                  reverse: true, child: _newRepositoryWidget(widget.context))
            ]));
      });

  Widget _newRepositoryWidget(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w400);

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText('"${widget.repositoryName}"',
              flex: 0, style: bodyStyle),
          Dimensions.spacingVerticalDouble,
          ..._passwordSection(),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  List<Widget> _passwordSection() =>
      [_passwordInputs(), _samePasswordWarning()];

  Widget _passwordInputs() => Container(
          child: Column(children: [
        if (_requiresManualAuthentication)
          Row(children: [
            Expanded(
                child: Fields.formTextField(
                    key: _currentPasswordInputKey,
                    context: context,
                    textEditingController: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    label: S.current.labelRepositoryCurrentPassword,
                    suffixIcon: _currentPasswordActions(),
                    hint: S.current.messageRepositoryCurrentPassword,
                    onSaved: (_) {},
                    validator: validateNoEmptyMaybeRegExpr(
                        emptyError:
                            S.current.messageErrorRepositoryPasswordValidation),
                    autovalidateMode: AutovalidateMode.disabled,
                    focusNode: _currentPasswordFocus))
          ]),
        if ([PasswordAction.biometrics, PasswordAction.remove]
                .contains(widget.action) ==
            false)
          Row(children: [
            Expanded(
                child: Fields.formTextField(
                    key: _newPasswordInputKey,
                    context: context,
                    textEditingController: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    label: S.current.labelPassword,
                    suffixIcon: _passwordActions(),
                    hint: S.current.messageRepositoryNewPassword,
                    onSaved: (_) {},
                    validator: validateNoEmptyMaybeRegExpr(
                        emptyError:
                            S.current.messageErrorRepositoryPasswordValidation),
                    autovalidateMode: AutovalidateMode.disabled,
                    focusNode: _newPasswordFocus))
          ]),
        if ([PasswordAction.biometrics, PasswordAction.remove]
                .contains(widget.action) ==
            false)
          Row(children: [
            Expanded(
                child: Fields.formTextField(
                    key: _retypeNewPasswordInputKey,
                    context: context,
                    textEditingController: _retypedNewPasswordController,
                    obscureText: _obscureRetypeNewPassword,
                    label: S.current.labelRetypePassword,
                    suffixIcon: _retypePasswordActions(),
                    hint: S.current.messageRepositoryNewPassword,
                    onSaved: (_) {},
                    validator: (retypedPassword) => retypedPasswordValidator(
                          password: _newPasswordController.text,
                          retypedPassword: retypedPassword,
                        ),
                    autovalidateMode: AutovalidateMode.disabled,
                    focusNode: _retypeNewPasswordFocus))
          ])
      ]));

  Widget _currentPasswordActions() => Wrap(children: [
        IconButton(
            onPressed: () => setState(
                () => _obscureCurrentPassword = !_obscureCurrentPassword),
            icon: _obscureCurrentPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
      ]);

  Widget _passwordActions() => Wrap(children: [
        IconButton(
            onPressed: () =>
                setState(() => _obscureNewPassword = !_obscureNewPassword),
            icon: _obscureNewPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final password = _newPasswordController.text;
              if (password.isEmpty) return;

              await copyStringToClipboard(password);
              showSnackBar(S.current.messagePasswordCopiedClipboard);
            },
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black)
      ]);

  Widget _retypePasswordActions() => Wrap(children: [
        IconButton(
            onPressed: () => setState(
                () => _obscureRetypeNewPassword = !_obscureRetypeNewPassword),
            icon: _obscureRetypeNewPassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final retypedPassword = _retypedNewPasswordController.text;
              if (retypedPassword.isEmpty) return;

              await copyStringToClipboard(retypedPassword);
              showSnackBar(S.current.messagePasswordCopiedClipboard);
            },
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black)
      ]);

  String? retypedPasswordValidator(
      {required String password, required String? retypedPassword}) {
    if (retypedPassword == null || password != retypedPassword) {
      return S.current.messageErrorRetypePassword;
    }

    return null;
  }

  Widget _samePasswordWarning() => Visibility(
      visible: _samePassword,
      child: Fields.autosizeText(
          S.current.messageErrorNewPasswordSameOldPassword,
          style: TextStyle(color: Colors.red),
          maxLines: 10,
          softWrap: true,
          textOverflow: TextOverflow.ellipsis));

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionAccept,
            focusNode: _createButtonFocus,
            onPressed: () => _onSaved(widget.repositoryName,
                _currentPasswordController.text, _newPasswordController.text),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
      ];

  void _onSaved(
      String repositoryName, String currentPassword, String newPassword) async {
    final isCurentPasswordOk =
        _currentPasswordInputKey.currentState?.validate() ??
            currentPassword.isNotEmpty;

    if (isCurentPasswordOk == false) return;

    _currentPasswordInputKey.currentState?.save();

    if ([PasswordAction.add, PasswordAction.change].contains(widget.action)) {
      final isPasswordOk =
          _newPasswordInputKey.currentState?.validate() ?? false;
      final isRetypePasswordOk =
          _retypeNewPasswordInputKey.currentState?.validate() ?? false;

      if (!(isPasswordOk && isRetypePasswordOk)) return;

      _newPasswordInputKey.currentState?.save();
      _retypeNewPasswordInputKey.currentState?.save();

      final isSamePassword = currentPassword == newPassword;
      setState(() => _samePassword = isSamePassword);

      if (isSamePassword) return;
    }

    final validateCurrentPassword = await _validateCurrentPassword(
      widget.context,
      currentPassword,
      widget.repoCubit,
    );

    if (validateCurrentPassword.isFailure) {
      final message = validateCurrentPassword.failure;

      if (message != null) {
        showSnackBar(message);
      }

      return null;
    }

    final result = SetPasswordResult(
      repositoryName: repositoryName,
      oldPassword: validateCurrentPassword.success,
      newPassword: newPassword,
      message: '',
    );

    Navigator.of(widget.context).pop(result);
  }

  Future<Result<String, String?>> _validateCurrentPassword(
    BuildContext parentContext,
    String currentPassword,
    RepoCubit repoCubit,
  ) async =>
      switch (await repoCubit.getPasswordAccessMode(currentPassword)) {
        AccessMode.write || AccessMode.read => Success(currentPassword),
        AccessMode.blind => Failure(S.current.messageUnlockRepoFailed),
      };

  @override
  void dispose() {
    _newPasswordController.dispose();
    _retypedNewPasswordController.dispose();

    _newPasswordFocus.dispose();

    super.dispose();
  }
}

class SetPasswordResult {
  SetPasswordResult({
    required this.repositoryName,
    required this.newPassword,
    required this.message,
    this.oldPassword,
  });

  final String repositoryName;
  final String? oldPassword;
  final String newPassword;
  final String message;
}
