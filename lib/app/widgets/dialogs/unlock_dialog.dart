import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/repo.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class UnlockDialog<T> extends StatelessWidget with OuiSyncAppLogger {
  UnlockDialog(
      {Key? key,
      required this.context,
      required this.repository,
      required this.manualUnlockCallback})
      : super(key: key);

  final BuildContext context;
  final RepoCubit repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Future<T> Function(RepoCubit repository, {required String password})
      manualUnlockCallback;

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
          Fields.constrainedText('"${repository.name}"',
              flex: 0, fontWeight: FontWeight.w400, color: Colors.black),
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
                              ),
                              color: Colors.black, onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          }),
                          hint: S.current.messageRepositoryPassword,
                          onSaved: (String? password) async =>
                              await _validatePasswordAndReturn(password),
                          validator: validateNoEmpty(
                              Strings.messageErrorRepositoryPasswordValidation),
                          autofocus: true))
                ]);
              }),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  Future<void> _validatePasswordAndReturn(String? password) async {
    final pwd = password;

    if (pwd == null || pwd.isEmpty) {
      return;
    }

    final result = await Dialogs.executeFutureWithLoadingDialog(context,
        f: manualUnlockCallback(repository, password: pwd));

    Navigator.of(context).pop(result);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null)),
        PositiveButton(
            text: S.current.actionUnlock, onPressed: _validatePasswordForm)
      ];

  void _validatePasswordForm() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
  }
}
