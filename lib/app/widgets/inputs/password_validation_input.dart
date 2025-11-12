import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

import '../../../generated/l10n.dart';
import '../../utils/stage.dart';
import '../../utils/utils.dart';

class PasswordValidation extends StatefulWidget {
  PasswordValidation({
    required this.onChanged,
    required this.stage,
    this.required = true,
  });

  final void Function(String?) onChanged;
  final bool required;
  final Stage stage;

  @override
  State<PasswordValidation> createState() => _PasswordValidationState();
}

class _PasswordValidationState<PasswordResult> extends State<PasswordValidation>
    with AppLogger {
  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  String? _password;
  String? _retypedPassword;

  String? _passwordStrength;
  Color? _passwordStrengthColorValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(top: 24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Fields.formTextField(
                  context: context,
                  key: Key('password'),
                  obscureText: _obscurePassword,
                  labelText: S.current.labelPassword,
                  hintText: S.current.messageRepositoryPassword,
                  suffixIcon: _passwordActions(),
                  onSaved: (_) {},
                  onChanged: (value) =>
                      _passwordChanged(value, _retypedPassword),
                  validator: (password) => passwordValidator(password),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Expanded(
                child: Fields.formTextField(
                  context: context,
                  key: Key('retype-password'),
                  obscureText: _obscureRetypePassword,
                  labelText: S.current.labelRetypePassword,
                  hintText: S.current.messageRepositoryPassword,
                  suffixIcon: _retypePasswordActions(),
                  onSaved: (_) {},
                  onChanged: (value) => _passwordChanged(_password, value),
                  validator: (retypedPassword) =>
                      retypedPasswordValidator(_password, retypedPassword),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Text(
                '${S.current.messagePasswordStrength}:',
                style: context.theme.appTextStyle.bodySmall.copyWith(
                  color: Colors.black54,
                ),
              ),
              Dimensions.spacingHorizontalHalf,
              Text(
                _passwordStrength ?? '',
                style: context.theme.appTextStyle.bodySmall.copyWith(
                  color: _passwordStrengthColorValue,
                ),
              ),
            ],
          ),
          Dimensions.spacingVertical,
          FlutterPasswordStrength(
            password: _password,
            strengthCallback: _updatePasswordStrengthMessage,
          ),
          Dimensions.spacingVerticalDouble,
        ],
      ),
    );
  }

  void _updatePasswordStrengthMessage(double strength) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(
        () => _passwordStrength = strength > 0.0
            ? _passwordStrengthString(strength)
            : '',
      );
      _passwordStrengthColorValue = strength > 0.0
          ? _passwordStrengthColor(strength)
          : null;
    });
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

  Widget _passwordActions() => Wrap(
    children: [
      IconButton(
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        icon: _obscurePassword
            ? const Icon(Constants.iconVisibilityOff)
            : const Icon(Constants.iconVisibilityOn),
        padding: EdgeInsetsDirectional.zero,
        visualDensity: VisualDensity.compact,
        color: Colors.black,
      ),
      IconButton(
        onPressed: () async {
          await copyStringToClipboard(_password ?? "");
          widget.stage.showSnackBar(S.current.messagePasswordCopiedClipboard);
        },
        icon: const Icon(Icons.copy_rounded),
        padding: EdgeInsetsDirectional.zero,
        visualDensity: VisualDensity.compact,
        color: Colors.black,
      ),
    ],
  );

  Widget _retypePasswordActions() => Wrap(
    children: [
      IconButton(
        onPressed: () =>
            setState(() => _obscureRetypePassword = !_obscureRetypePassword),
        icon: _obscureRetypePassword
            ? const Icon(Constants.iconVisibilityOff)
            : const Icon(Constants.iconVisibilityOn),
        padding: EdgeInsetsDirectional.zero,
        visualDensity: VisualDensity.compact,
        color: Colors.black,
      ),
      IconButton(
        onPressed: () async {
          await copyStringToClipboard(_retypedPassword ?? "");
          widget.stage.showSnackBar(S.current.messagePasswordCopiedClipboard);
        },
        icon: const Icon(Icons.copy_rounded),
        padding: EdgeInsetsDirectional.zero,
        visualDensity: VisualDensity.compact,
        color: Colors.black,
      ),
    ],
  );

  String? passwordValidator(String? password) {
    if (widget.required && (password == null || password.isEmpty)) {
      return S.current.messageErrorRepositoryPasswordValidation;
    }

    return null;
  }

  String? retypedPasswordValidator(String? password, String? retypedPassword) {
    // We don't want this validation to trigger when both fields are null/empty.

    if ((password ?? '') != (retypedPassword ?? '')) {
      return S.current.messageErrorRetypePassword;
    }

    return null;
  }

  void _passwordChanged(String? password, String? retypedPassword) {
    if (passwordValidator(password) == null &&
        retypedPasswordValidator(password, retypedPassword) == null) {
      widget.onChanged(password);
    } else {
      widget.onChanged(null);
    }

    setState(() {
      _password = password;
      _retypedPassword = retypedPassword;
    });
  }
}
