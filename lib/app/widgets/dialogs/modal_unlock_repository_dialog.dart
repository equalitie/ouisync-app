import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class UnlockRepository extends StatelessWidget {
  UnlockRepository(
      {Key? key,
      required this.context,
      required this.formKey,
      required this.repositoryName,
      required this.unlockRepositoryCallback})
      : super(key: key);

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final String repositoryName;
  final Future<AccessMode?> Function(
      {required String repositoryName,
      required String password}) unlockRepositoryCallback;

  final TextEditingController _passwordController =
      TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _useBiometrics = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildUnlockRepositoryWidget(this.context),
    );
  }

  Widget _buildUnlockRepositoryWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText('"$repositoryName"',
              flex: 0, fontWeight: FontWeight.w400),
          Dimensions.spacingVerticalDouble,
          ValueListenableBuilder(
              valueListenable: _obscurePassword,
              builder: (context, value, child) {
                final obscure = value;
                return Row(children: [
                  Expanded(
                      child: Fields.formTextField(
                          context: context,
                          textEditingController: _passwordController,
                          obscureText: obscure,
                          label: S.current.labelTypePassword,
                          subffixIcon: Fields.actionIcon(
                              Icon(
                                obscure
                                    ? Constants.iconVisibilityOn
                                    : Constants.iconVisibilityOff,
                                size: Dimensions.sizeIconSmall,
                              ), onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          }),
                          hint: S.current.messageRepositoryPassword,
                          onSaved: (String? password) async {
                            await _returnPassword(password);
                          },
                          validator: validateNoEmpty(
                              Strings.messageErrorRepositoryPasswordValidation),
                          autofocus: true))
                ]);
              }),
          _useBiometricsCheckbox(),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Widget _useBiometricsCheckbox() => ValueListenableBuilder(
      valueListenable: _useBiometrics,
      builder: (context, useBiometrics, child) {
        return SwitchListTile.adaptive(
            value: useBiometrics,
            title: Text('Secure using biometrics'),
            onChanged: (enableBiometrics) {
              _useBiometrics.value = enableBiometrics;
            },
            contentPadding: EdgeInsets.zero);
      });

  Future<void> _returnPassword(String? password) async {
    if (password?.isEmpty ?? true) {
      return;
    }

    final accessMode = await unlockRepositoryCallback.call(
        repositoryName: repositoryName, password: password!);

    // Only if the password successfuly unlocked the repo, then we add it
    // to the biometrics store -if the user selected the option.
    if ((accessMode ?? AccessMode.blind) != AccessMode.blind) {
      if (_useBiometrics.value) {
        await Biometrics.addRepositoryPassword(
            repositoryName: repositoryName, password: password);
      }
    }

    Navigator.of(context).pop();
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null)),
        PositiveButton(
            text: S.current.actionUnlock, onPressed: _validatePassword)
      ];

  void _validatePassword() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}
