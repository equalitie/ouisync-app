import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:random_password_generator/random_password_generator.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SetPassword extends StatefulWidget {
  SetPassword(
      {required this.context,
      required this.cubit,
      required this.repositoryName,
      required this.currentPassword,
      required this.newPassword,
      required this.generated,
      Key? key})
      : super(key: key);

  final BuildContext context;
  final ReposCubit cubit;
  final String repositoryName;
  final String currentPassword;
  final String? newPassword;
  final bool generated;

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

  bool _generatePassword = true;
  String? _password;
  bool _previewPassword = false;

  bool _samePassword = false;

  @override
  void initState() {
    widget.newPassword?.isEmpty ?? true
        ? _configureInputs(generatePassword: true)
        : _initStateValues(widget.newPassword!, widget.generated);

    super.initState();
  }

  void _initStateValues(String password, bool generated) {
    setState(() {
      _generatePassword = generated;

      _setPassword(password);

      if (!generated) {
        _passwordFocus.requestFocus();

        _passwordController.text.isEmpty
            ? _scrollToVisible(_passwordFocus)
            : _retypePasswordFocus.requestFocus();
      }
    });
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
            _generatePassword ? _passwordLabel() : _passwordInputs(),
            _generatePasswordSwitch(),
            _samePasswordWarning(),
            Fields.dialogActions(context, buttons: _actions(context)),
          ]);

  Widget _passwordLabel() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Expanded(
          flex: 1,
          child: Fields.autosizeText(
              _formattPassword(_password, mask: !_previewPassword))),
      Expanded(
          flex: 0,
          child: IconButton(
              onPressed: _password?.isNotEmpty ?? false
                  ? () => setState(() => _previewPassword = !_previewPassword)
                  : null,
              icon: _previewPassword
                  ? const Icon(Constants.iconVisibilityOff)
                  : const Icon(Constants.iconVisibilityOn),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact)),
      Expanded(
          flex: 0,
          child: IconButton(
              onPressed: _password?.isNotEmpty ?? false
                  ? () async {
                      if (_password == null) return;

                      await copyStringToClipboard(_password!);
                      showSnackBar(context,
                          content:
                              Text(S.current.messagePasswordCopiedClipboard));
                    }
                  : null,
              icon: const Icon(Icons.copy_rounded),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact))
    ]);
  }

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
                  subffixIcon: Fields.actionIcon(
                      Icon(
                          _obscurePassword
                              ? Constants.iconVisibilityOn
                              : Constants.iconVisibilityOff,
                          size: Dimensions.sizeIconSmall), onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  hint: 'New password',
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
                  subffixIcon: Fields.actionIcon(
                      Icon(
                          _obscureRetypePassword
                              ? Constants.iconVisibilityOn
                              : Constants.iconVisibilityOff,
                          size: Dimensions.sizeIconSmall), onPressed: () {
                    setState(
                        () => _obscureRetypePassword = !_obscureRetypePassword);
                  }),
                  hint: 'New password',
                  onSaved: (_) {},
                  validator: (retypedPassword) => retypedPasswordValidator(
                        password: _passwordController.text,
                        retypedPassword: retypedPassword,
                      ),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _retypePasswordFocus))
        ])
      ]));

  String? retypedPasswordValidator(
      {required String password, required String? retypedPassword}) {
    if (retypedPassword == null || password != retypedPassword) {
      return S.current.messageErrorRetypePassword;
    }

    return null;
  }

  String _formattPassword(String? password, {bool mask = true}) =>
      (mask ? "*" * (password ?? '').length : password) ?? '';

  Widget _generatePasswordSwitch() => Container(
      child: SwitchListTile.adaptive(
          value: _generatePassword,
          title:
              Text(S.current.messageGeneratePassword, textAlign: TextAlign.end),
          onChanged: (generatePassword) {
            setState(() => _generatePassword = generatePassword);

            _configureInputs(generatePassword: _generatePassword);
          },
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact));

  void _configureInputs({required bool generatePassword}) {
    String newPassword = '';
    if (generatePassword) {
      newPassword = _generatePassword ? _generateRandomPassword() : '';
      _createButtonFocus.requestFocus();
    }

    _setPassword(newPassword);
    _passwordFocus.requestFocus();

    _passwordController.text.isEmpty
        ? _scrollToVisible(_passwordFocus)
        : _retypePasswordFocus.requestFocus();
  }

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

  void _setPassword(String newPassword) {
    setState(() => _password = newPassword);

    _passwordController.text = newPassword;
    _retypedPasswordController.text = newPassword;
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
          'The new password is the same as the old password',
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
            onPressed: () {
              final password = _passwordController.text;
              _onSaved(widget.cubit, widget.repositoryName, password);
            })
      ];

  void _onSaved(
      ReposCubit cubit, String repositoryName, String newPassword) async {
    final isPasswordOk = _passwordInputKey.currentState?.validate() ?? false;
    final isRetypePasswordOk =
        _retypePasswordInputKey.currentState?.validate() ?? false;

    if (!_generatePassword) {
      if (!(isPasswordOk && isRetypePasswordOk)) return;

      _passwordInputKey.currentState!.save();
      _retypePasswordInputKey.currentState!.save();
    }

    final isSamePassword =
        widget.currentPassword == _retypedPasswordController.text;
    setState(() => _samePassword = isSamePassword);

    if (_samePassword) return;

    final result = SetPasswordResult(
        repositoryName: repositoryName,
        newPassword: newPassword,
        generated: _generatePassword,
        message: '');
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
      required this.generated,
      required this.message});

  final String repositoryName;
  final String newPassword;
  final bool generated;
  final String message;
}
