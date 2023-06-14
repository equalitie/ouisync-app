import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class GetPasswordState extends StatefulWidget {
  const GetPasswordState({required this.passwordState});

  final GetPasswordResult passwordState; // add, change

  @override
  State<GetPasswordState> createState() =>
      _GetPasswordStateState(passwordState);
}

class _GetPasswordStateState extends State<GetPasswordState> {
  _GetPasswordStateState(GetPasswordResult state) : _state = state;

  final GetPasswordResult _state;

  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  final TextEditingController _passwordController =
      TextEditingController(text: null);
  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

  final _passwordFocus = FocusNode();
  final _retypePasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  bool _samePassword = false;

  @override
  void initState() {
    super.initState();

    if (_state.newPassword == null) return;

    if (_state.newPassword!.isNotEmpty) {
      _initStateValues(_state.newPassword!);
    }
  }

  void _initStateValues(String password) {
    setState(() {
      _setPassword(password);

      _passwordController.text.isEmpty
          ? _scrollToVisible(_passwordFocus)
          : _retypePasswordFocus.requestFocus();
    });
  }

  void _setPassword(String newPassword) {
    _passwordController.text = newPassword;
    _retypedPasswordController.text = newPassword;
  }

  void _scrollToVisible(FocusNode focusNode) => WidgetsBinding.instance
      .addPostFrameCallback((_) => Scrollable.ensureVisible(
            focusNode.context!,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          ));

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
                  child: Column(children: [
                    _title(),
                    ..._passwordInputs(),
                    ..._samePasswordWarning(),
                    ..._savePassword(context),
                    _manualPasswordWarning()
                  ]))
            ]))
      ])));

  Widget _title() {
    final title = _state.action == PasswordAction.add
        ? S.current.messageAddLocalPassword
        : S.current.messageChangeLocalPassword;

    return Container(
        padding: Dimensions.paddingDialog,
        child: Row(children: [
          Fields.constrainedText(title,
              flex: 0, fontSize: Dimensions.fontBig, color: Colors.black)
        ]));
  }

  List<Widget> _passwordInputs() => [
        Container(
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
                        validator: (retypedPassword) =>
                            retypedPasswordValidator(
                              password: _passwordController.text,
                              retypedPassword: retypedPassword,
                            ),
                        autovalidateMode: AutovalidateMode.disabled,
                        focusNode: _retypePasswordFocus))
              ])
            ])),
        Dimensions.spacingVertical
      ];

  List<Widget> _savePassword(BuildContext context) {
    final actionText = _state.action == PasswordAction.add
        ? S.current.messageAddLocalPassword
        : S.current.messageChangeLocalPassword;

    return [
      Fields.inPageButton(
          onPressed: () {
            final newPassword = _passwordController.text.isEmpty
                ? null
                : _passwordController.text;

            final changed = newPassword != null;

            final passwordResult =
                _state.copyWith(newPassword: newPassword, changed: changed);

            _onSaved(passwordResult);
          },
          text: actionText),
      Divider()
    ];
  }

  void _onSaved(GetPasswordResult passwordResult) async {
    final isPasswordOk = _passwordInputKey.currentState?.validate() ?? false;
    final isRetypePasswordOk =
        _retypePasswordInputKey.currentState?.validate() ?? false;

    if (!(isPasswordOk && isRetypePasswordOk)) return;

    _passwordInputKey.currentState!.save();
    _retypePasswordInputKey.currentState!.save();

    final isSamePassword =
        _state.currentPassword == _retypedPasswordController.text;
    setState(() => _samePassword = isSamePassword);

    if (_samePassword) return;

    Navigator.of(context).pop(passwordResult);
  }

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

  List<Widget> _samePasswordWarning() => [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Visibility(
                visible: _samePassword,
                child: Fields.autosizeText(
                    S.current.messageErrorNewPasswordSameOldPassword,
                    color: Colors.red,
                    maxLines: 10,
                    softWrap: true,
                    textOverflow: TextOverflow.ellipsis))),
        Dimensions.spacingVertical
      ];

  Widget _manualPasswordWarning() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Fields.autosizeText(S.current.messageRememberSavePasswordAlert,
          color: Colors.red,
          maxLines: 10,
          softWrap: true,
          fontSize: Dimensions.fontSmall,
          textOverflow: TextOverflow.ellipsis));

  @override
  void dispose() {
    _passwordController.dispose();
    _retypedPasswordController.dispose();

    _passwordFocus.dispose();
    _retypePasswordFocus.dispose();

    super.dispose();
  }
}

class GetPasswordResult extends Equatable {
  GetPasswordResult(
      {required this.action,
      required this.currentPassword,
      this.newPassword,
      this.changed = false});

  final PasswordAction action;
  final String currentPassword;
  final String? newPassword;
  final bool changed;

  GetPasswordResult copyWith(
          {PasswordAction? action,
          String? currentPassword,
          String? newPassword,
          bool? changed}) =>
      GetPasswordResult(
          action: action ?? this.action,
          currentPassword: currentPassword ?? this.currentPassword,
          newPassword: newPassword ?? this.newPassword,
          changed: changed ?? this.changed);

  @override
  List<Object?> get props => [action, currentPassword, newPassword, changed];
}
