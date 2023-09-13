import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:result_type/result_type.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/repo_actions_mixin.dart';
import '../../storage/secure_storage.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ManageDesktopPassword extends StatefulWidget {
  ManageDesktopPassword(
      {required this.context,
      required this.repoCubit,
      required this.action,
      required this.repositoryName,
      required this.authMode,
      required this.usesBiometrics});

  final BuildContext context;
  final RepoCubit repoCubit;
  final PasswordAction action;
  final String repositoryName;
  final AuthMode authMode;
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
    _buildingFuture = _userAuthentication(
        widget.repoCubit.databaseId, widget.repoCubit.state.authenticationMode);

    super.initState();
  }

  Future<bool> _userAuthentication(String databaseId, AuthMode authMode) async {
    String currentPassword = '';

    if (authMode != AuthMode.manual) {
      final securePassword = await SecureStorage(databaseId: databaseId)
          .tryGetPassword(authMode: authMode);

      if (securePassword == null || securePassword.isEmpty) {
        if (securePassword != null) {
          final userAuthenticationFailed = authMode == AuthMode.noLocalPassword
              ? S.current.messageRepoAuthFailed
              : S.current.messageBioAuthFailed;
          showSnackBar(context, message: userAuthenticationFailed);
        }

        return false;
      }

      currentPassword = securePassword;
    }

    _initStateValues(currentPassword);
    return true;
  }

  void _initStateValues(String currentPassword) {
    _requiresManualAuthentication =
        widget.action != PasswordAction.add && currentPassword.isEmpty;

    _currentPasswordController.text =
        _requiresManualAuthentication == false ? currentPassword : '';

    if (widget.authMode == AuthMode.manual && _requiresManualAuthentication) {
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
                    validator: validateNoEmpty(
                        Strings.messageErrorRepositoryPasswordValidation),
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
                    validator: validateNoEmpty(
                        Strings.messageErrorRepositoryPasswordValidation),
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
              showSnackBar(context,
                  message: S.current.messagePasswordCopiedClipboard);
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
              showSnackBar(context,
                  message: S.current.messagePasswordCopiedClipboard);
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

    UnlockResult? unlockResult;

    final validateCurrentPassword = await _validateCurrentPassword(
        widget.context, currentPassword, widget.repoCubit);

    if (validateCurrentPassword.isFailure) {
      final message = validateCurrentPassword.failure;

      if (message != null) {
        showSnackBar(context, message: message);
      }

      return null;
    }

    unlockResult = validateCurrentPassword.success;

    final result = SetPasswordResult(
        repositoryName: repositoryName,
        newPassword: newPassword,
        message: '',
        unlockResult: unlockResult);

    Navigator.of(widget.context).pop(result);
  }

  Future<Result<UnlockResult, String?>> _validateCurrentPassword(
      BuildContext parentContext,
      String currentPassword,
      RepoCubit repoCubit) async {
    final unlockResult =
        await _unlockShareToken(parentContext, repoCubit, currentPassword);

    final accessMode = await unlockResult.shareToken.mode;
    if (accessMode == AccessMode.blind) {
      return Failure(S.current.messageUnlockRepoFailed);
    }

    return Success(unlockResult);
  }

  Future<ShareToken> _loadShareToken(
          BuildContext context, RepoCubit repo, String password) =>
      Dialogs.executeFutureWithLoadingDialog(context,
          f: repo.createShareToken(AccessMode.write, password: password));

  Future<UnlockResult> _unlockShareToken(
      BuildContext context, RepoCubit repo, String password) async {
    final token = await _loadShareToken(context, repo, password);
    return UnlockResult(password: password, shareToken: token);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _retypedNewPasswordController.dispose();

    _newPasswordFocus.dispose();

    super.dispose();
  }
}

class SetPasswordResult {
  SetPasswordResult(
      {required this.repositoryName,
      required this.newPassword,
      required this.message,
      this.unlockResult});

  final String repositoryName;
  final String newPassword;
  final String message;
  final UnlockResult? unlockResult;
}
