import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class PasswordState extends StatefulWidget {
  const PasswordState({required this.passwordState});

  final PasswordStateResult passwordState; // add, change

  @override
  State<PasswordState> createState() => _PasswordStateState(passwordState);
}

class _PasswordStateState extends State<PasswordState> {
  _PasswordStateState(PasswordStateResult state) : _state = state;

  final PasswordStateResult _state;

  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  final TextEditingController _passwordController =
      TextEditingController(text: null);
  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

  final _passwordFocus = FocusNode();
  final _retryPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  @override
  void initState() {
    _passwordFocus.requestFocus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(S.current.titleSecurity),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Form(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              SingleChildScrollView(
                  reverse: true,
                  child: _state.mode == 'add'
                      ? _addPassword('Add local password')
                      : _changePassword('Change local password'))
            ]))
      ])));

  Widget _addPassword(String title) => Column(children: [
        _title(title),
        _passwordInputs(),
        Dimensions.spacingVertical,
        Fields.inPageButton(
            onPressed: () {
              final newPassword = _passwordController.text.isEmpty
                  ? null
                  : _passwordController.text;
              final changed = newPassword != null;

              final result =
                  _state.copyWith(newPassword: newPassword, changed: changed);

              Navigator.of(context).pop(result);
            },
            text: 'Create password'),
        Divider(),
        _manualPasswordWarning(),
      ]);

  Widget _changePassword(String title) => Column(children: [_title(title)]);

  Widget _title(String title) => Container(
      padding: Dimensions.paddingDialog,
      child: Row(children: [
        Fields.constrainedText(title, flex: 0, fontSize: Dimensions.fontBig)
      ]));

  Widget _passwordInputs() => Container(
      padding: Dimensions.paddingDialog,
      child: Column(children: [
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _passwordInputKey,
                  context: context,
                  textEditingController: _passwordController,
                  obscureText: _obscurePassword,
                  label: S.current.labelPassword,
                  suffixIcon: _passwordActions(),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: validateNoEmpty(
                      Strings.messageErrorRepositoryPasswordValidation),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _passwordFocus))
        ]),
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _retypePasswordInputKey,
                  context: context,
                  textEditingController: _retypedPasswordController,
                  obscureText: _obscureRetypePassword,
                  label: S.current.labelRetypePassword,
                  suffixIcon: _retypePasswordActions(),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: (retypedPassword) => retypedPasswordValidator(
                        password: _passwordController.text,
                        retypedPassword: retypedPassword,
                      ),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _retryPasswordFocus))
        ])
      ]));

  Widget _passwordActions() => Wrap(children: [
        IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: _obscurePassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final password = _passwordController.text;
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
                () => _obscureRetypePassword = !_obscureRetypePassword),
            icon: _obscureRetypePassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final retypedPassword = _retypedPasswordController.text;
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

  Widget _manualPasswordWarning() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Fields.autosizeText(S.current.messageRememberSavePasswordAlert,
          color: Colors.red,
          maxLines: 10,
          softWrap: true,
          fontSize: Dimensions.fontSmall,
          textOverflow: TextOverflow.ellipsis));
}

class PasswordStateResult extends Equatable {
  PasswordStateResult(
      {required this.mode,
      required this.currentPassword,
      this.newPassword,
      this.changed = false});

  final String mode;
  final String currentPassword;
  final String? newPassword;
  final bool changed;

  PasswordStateResult copyWith(
          {String? mode,
          String? currentPassword,
          String? newPassword,
          bool? changed}) =>
      PasswordStateResult(
          mode: mode ?? this.mode,
          currentPassword: currentPassword ?? this.currentPassword,
          newPassword: newPassword ?? this.newPassword,
          changed: changed ?? this.changed);

  @override
  List<Object?> get props => [mode, currentPassword, newPassword, changed];
}
