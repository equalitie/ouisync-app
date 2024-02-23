import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class PasswordValidation extends StatefulWidget {
  PasswordValidation({required this.onPasswordChange});

  final void Function(String?) onPasswordChange;

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
  String? _retypedPassword;

  String? _passwordStrength;
  Color? _passwordStrengthColorValue;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Row(children: [
        Expanded(
            child: Fields.formTextField(
                context: context,
                obscureText: _obscurePassword,
                label: S.current.labelPassword,
                suffixIcon: _passwordActions(),
                hint: S.current.messageRepositoryPassword,
                onSaved: (_) {},
                onChanged: (value) => _passwordChanged(value, _retypedPassword),
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
                context: context,
                obscureText: _obscureRetypePassword,
                label: S.current.labelRetypePassword,
                suffixIcon: _retypePasswordActions(),
                hint: S.current.messageRepositoryPassword,
                onSaved: (_) {},
                onChanged: (value) => _passwordChanged(_password, value),
                validator: (retypedPassword) => retypedPasswordValidator(
                      _password,
                      retypedPassword,
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
    ]));
  }

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
              await copyStringToClipboard(_password ?? "");
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
              await copyStringToClipboard(_retypedPassword ?? "");

              showSnackBar(context,
                  message: S.current.messagePasswordCopiedClipboard);
            },
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black)
      ]);

  String? retypedPasswordValidator(String? password, String? retypedPassword) {
    if (password == null ||
        retypedPassword == null ||
        password != retypedPassword) {
      return S.current.messageErrorRetypePassword;
    }

    return null;
  }

  void _passwordChanged(String? password, String? retypedPassword) {
    if (retypedPasswordValidator(password, retypedPassword) == null) {
      widget.onPasswordChange(password);
    } else {
      widget.onPasswordChange(null);
    }

    setState(() {
      _password = password;
      _retypedPassword = retypedPassword;
    });
  }

  @override
  void dispose() {
    _passwordFocus.dispose();
    _retypePasswordFocus.dispose();

    super.dispose();
  }
}
