import 'package:flutter/material.dart';

import '../../cubits/repo.dart';
import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class UnlockDialog<T> extends StatelessWidget with OuiSyncAppLogger {
  UnlockDialog(
      {Key? key,
      required this.context,
      required this.repo,
      required this.unlockCallback})
      : super(key: key);

  final BuildContext context;
  final RepoCubit repo;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Future<T> Function(RepoCubit repo, {required String password})
      unlockCallback;

  final TextEditingController _passwordController =
      TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildUnlockRepositoryWidget(this.context),
      );

  Widget _buildUnlockRepositoryWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText('"${repo.name}"',
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
                          suffixIcon: Fields.actionIcon(
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
                            await _unlockRepository(password);
                          },
                          validator: validateNoEmpty(
                              Strings.messageErrorRepositoryPasswordValidation),
                          autofocus: true))
                ]);
              }),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Future<void> _unlockRepository(String? password) async {
    final pwd = password;

    if (pwd == null || pwd.isEmpty) {
      return;
    }

    final result = await Dialogs.executeFutureWithLoadingDialog(context,
        f: unlockCallback(repo, password: pwd));

    Navigator.of(context).pop(result);
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
