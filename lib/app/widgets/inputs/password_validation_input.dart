import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';

class PasswordValidation extends StatefulWidget {
  PasswordValidation(
      {required this.passwordMode,
      required this.passwordInputKey,
      required this.retypePasswordInputKey,
      required this.passwordController,
      required this.retypedPasswordController,
      required this.actions});

  final PasswordMode passwordMode;

  final GlobalKey<FormFieldState> passwordInputKey;
  final GlobalKey<FormFieldState> retypePasswordInputKey;

  final TextEditingController passwordController;
  final TextEditingController retypedPasswordController;

  final Widget Function() actions;

  @override
  State<PasswordValidation> createState() => _PasswordValidationState();
}

class _PasswordValidationState<PasswordResult> extends State<PasswordValidation>
    with AppLogger {
  final _passwordFocus = FocusNode();
  final _retypePasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  String? _password;

  String? _passwordStrength;
  Color? _passwordStrengthColorValue;

  @override
  void initState() {
    widget.passwordController.addListener(
        () => setState(() => _password = widget.passwordController.text));

    super.initState();
  }

  double _inputOpacity() => widget.passwordMode != PasswordMode.bio ? 1 : 0.5;

  bool _inputEnabled() => widget.passwordMode != PasswordMode.bio;

  @override
  Widget build(BuildContext) => Opacity(
      opacity: _inputOpacity(),
      child: Container(
          child: Column(children: [
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: widget.passwordInputKey,
                  context: context,
                  textEditingController: widget.passwordController,
                  enabled: _inputEnabled(),
                  obscureText: _obscurePassword,
                  label: S.current.labelPassword,
                  suffixIcon: _passwordActions(),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: validateNoEmptyMaybeRegExpr(
                      emptyError:
                          S.current.messageErrorRepositoryPasswordValidation),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _passwordFocus))
        ]),
        Dimensions.spacingVertical,
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: widget.retypePasswordInputKey,
                  context: context,
                  textEditingController: widget.retypedPasswordController,
                  enabled: _inputEnabled(),
                  obscureText: _obscureRetypePassword,
                  label: S.current.labelRetypePassword,
                  suffixIcon: _retypePasswordActions(),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: (retypedPassword) => retypedPasswordValidator(
                        password: widget.passwordController.text,
                        retypedPassword: retypedPassword,
                      ),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _retypePasswordFocus))
        ]),
        Dimensions.spacingVertical,
        Row(children: [
          Text('${S.current.messagePasswordStrength}:',
              style: context.theme.appTextStyle.bodySmall
                  .copyWith(color: Colors.black54)),
          Dimensions.spacingHorizontalHalf,
          Text(_passwordStrength ?? '',
              style: context.theme.appTextStyle.bodySmall
                  .copyWith(color: _passwordStrengthColorValue))
        ]),
        Dimensions.spacingVertical,
        FlutterPasswordStrength(
            password: _password,
            strengthCallback: _updatePasswordStrengthMessage),
        Dimensions.spacingVerticalDouble,
        widget.actions()
      ])));

  void _updatePasswordStrengthMessage(double strength) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _passwordStrength =
          strength > 0.0 ? _passwordStrengthString(strength) : '');
      _passwordStrengthColorValue =
          strength > 0.0 ? _passwordStrengthColor(strength) : null;
    });

    loggy.app('Strength: $_passwordStrength ($strength)');
  }

  String _passwordStrengthString(double strength) {
    if (strength <= 0.25) {
      return S.current.messageWeak;
    } else if (strength <= 0.5) {
      return S.current.messageMedium;
    } else if (strength <= 0.75) {
      return S.current.messageGood;
    } else {
      return S.current.messageStrong;
    }
  }

  Color _passwordStrengthColor(double strength) {
    if (strength <= 0.25) {
      return Colors.red;
    } else if (strength <= 0.5) {
      return Colors.yellow.shade800;
    } else if (strength <= 0.75) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
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
              final password = widget.passwordController.text;
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
              final retypedPassword = widget.retypedPasswordController.text;
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

  @override
  void dispose() {
    widget.passwordController.dispose();
    widget.retypedPasswordController.dispose();

    _passwordFocus.dispose();
    _retypePasswordFocus.dispose();

    super.dispose();
  }
}
