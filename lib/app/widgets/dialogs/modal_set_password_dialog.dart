import 'package:flutter/material.dart';
import 'package:random_password_generator/random_password_generator.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SetPassword extends StatefulWidget {
  SetPassword(
      {required this.context,
      required this.repositoryName,
      required this.currentPassword,
      required this.newPassword,
      required this.usesBiometrics,
      Key? key})
      : super(key: key);

  final BuildContext context;
  final String repositoryName;
  final String currentPassword;
  final String? newPassword;
  final bool usesBiometrics;

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> with OuiSyncAppLogger {
  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  final TextEditingController _passwordController =
      TextEditingController(text: null);
  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

  final _passwordFocus = FocusNode();
  final _retypePasswordFocus = FocusNode();
  final _createButtonFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  bool _samePassword = false;
  bool _showSavePasswordWarning = false;

  @override
  void initState() {
    super.initState();

    setState((() => _showSavePasswordWarning = !widget.usesBiometrics));

    if (widget.newPassword == null) return;

    if (widget.newPassword!.isNotEmpty) {
      _initStateValues(widget.newPassword!);
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

  @override
  Widget build(BuildContext context) => Form(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            SingleChildScrollView(
                reverse: true, child: _newRepositoryWidget(widget.context))
          ]));

  Widget _newRepositoryWidget(BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.constrainedText('"${widget.repositoryName}"',
                flex: 0, fontWeight: FontWeight.w400),
            Dimensions.spacingVerticalDouble,
            ..._passwordSection(),
            _manualPasswordWarning(),
            Fields.dialogActions(context, buttons: _actions(context)),
          ]);

  List<Widget> _passwordSection() =>
      [_passwordInputs(), _samePasswordWarning(), _generatePasswordButton()];

  Widget _passwordInputs() => Container(
          child: Column(children: [
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _passwordInputKey,
                  context: context,
                  textEditingController: _passwordController,
                  obscureText: _obscurePassword,
                  label: S.current.labelPassword,
                  subffixIcon: _passwordActions(),
                  hint: S.current.messageRepositoryNewPassword,
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
                  subffixIcon: _retypePasswordActions(),
                  hint: S.current.messageRepositoryNewPassword,
                  onSaved: (_) {},
                  validator: (retypedPassword) => retypedPasswordValidator(
                        password: _passwordController.text,
                        retypedPassword: retypedPassword,
                      ),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _retypePasswordFocus))
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

  Widget _generatePasswordButton() =>
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton.icon(
            onPressed: () {
              final autoPassword = _generateRandomPassword();

              _passwordController.text = autoPassword;
              _retypedPasswordController.text = autoPassword;
            },
            icon: const Icon(Icons.casino_outlined),
            label: Text(S.current.messageGeneratePassword))
      ]);

  String _generateRandomPassword() {
    final password = RandomPasswordGenerator();
    final autogeneratedPassword = password.randomPassword(
        letters: true,
        numbers: true,
        specialChar: true,
        uppercase: true,
        passwordLength: 24);

    return autogeneratedPassword;
  }

  void _scrollToVisible(FocusNode focusNode) => WidgetsBinding.instance
      .addPostFrameCallback((_) => Scrollable.ensureVisible(
            focusNode.context!,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          ));

  Widget _samePasswordWarning() => Visibility(
      visible: _samePassword,
      child: Fields.autosizeText(
          S.current.messageErrorNewPasswordSameOldPassword,
          color: Colors.red,
          maxLines: 10,
          softWrap: true,
          textOverflow: TextOverflow.ellipsis));

  Widget _manualPasswordWarning() => Visibility(
      visible: _showSavePasswordWarning,
      child: Fields.autosizeText(S.current.messageRememberSavePasswordAlert,
          color: Colors.red,
          maxLines: 10,
          softWrap: true,
          textOverflow: TextOverflow.ellipsis));

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null)),
        PositiveButton(
            text: S.current.actionAccept,
            focusNode: _createButtonFocus,
            onPressed: () {
              final password = _passwordController.text;
              _onSaved(widget.repositoryName, password);
            })
      ];

  void _onSaved(String repositoryName, String newPassword) async {
    final isPasswordOk = _passwordInputKey.currentState?.validate() ?? false;
    final isRetypePasswordOk =
        _retypePasswordInputKey.currentState?.validate() ?? false;

    if (!(isPasswordOk && isRetypePasswordOk)) return;

    _passwordInputKey.currentState!.save();
    _retypePasswordInputKey.currentState!.save();

    final isSamePassword =
        widget.currentPassword == _retypedPasswordController.text;
    setState(() => _samePassword = isSamePassword);

    if (_samePassword) return;

    final result = SetPasswordResult(
        repositoryName: repositoryName, newPassword: newPassword, message: '');
    Navigator.of(widget.context).pop(result);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _retypedPasswordController.dispose();

    _passwordFocus.dispose();

    super.dispose();
  }
}

class SetPasswordResult {
  SetPasswordResult(
      {required this.repositoryName,
      required this.newPassword,
      required this.message});

  final String repositoryName;
  final String newPassword;
  final String message;
}
