import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RenameRepository extends HookWidget {
  RenameRepository({required this.parentContext, required this.oldName});

  final BuildContext parentContext;
  final String oldName;

  final formKey = GlobalKey<FormState>();

  late final TextEditingController newNameController;

  late final FocusNode newNameTextFieldFocus;
  late final FocusNode positiveButtonFocus;

  @override
  Widget build(BuildContext context) {
    initHooks();
    selectNewName(oldName);

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.constrainedText('"$oldName"',
                flex: 0,
                style: context.theme.appTextStyle.bodyMedium
                    .copyWith(fontWeight: FontWeight.w400)),
            Fields.formTextField(
                context: context,
                controller: newNameController,
                textInputAction: TextInputAction.done,
                labelText: S.current.labelRenameRepository,
                hintText: S.current.messageRepositoryNewName,
                onFieldSubmitted: (newName) {
                  final submitted = submitField(newName);
                  if (submitted && PlatformValues.isDesktopDevice) {
                    Navigator.of(context).pop(newName);
                  }
                },
                validator: validateNoEmptyMaybeRegExpr(
                    emptyError: S.current.messageErrorFormValidatorNameDefault,
                    regExp: Strings.entityNameRegExp,
                    regExpError: S.current.messageErrorCharactersNotAllowed),
                focusNode: newNameTextFieldFocus,
                autofocus: true),
            Fields.dialogActions(context, buttons: _actions(context)),
          ]),
    );
  }

  void initHooks() {
    newNameController =
        useTextEditingController.fromValue(TextEditingValue.empty);

    newNameTextFieldFocus = useFocusNode(debugLabel: 'name-txt-focus');
    positiveButtonFocus = useFocusNode(debugLabel: 'positive-btn-focus');
  }

  void selectNewName(String value) {
    newNameController.text = value;
    newNameController.selectAll();
  }

  bool submitField(String? newName) {
    final validationOk = _validateNewName(newName ?? '');
    if (!validationOk) {
      selectNewName(newName ?? '');
      newNameTextFieldFocus.requestFocus();

      return false;
    }

    if (PlatformValues.isMobileDevice) {
      positiveButtonFocus.requestFocus();
    }

    return true;
  }

  bool _validateNewName(String newName) {
    if (newName.isEmpty || newName == oldName) return false;

    if (!(formKey.currentState?.validate() ?? false)) return false;

    formKey.currentState!.save();
    return true;
  }

  List<Widget> _actions(BuildContext context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(''),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionRename,
            onPressed: () => onSaved(context, newNameController.text),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
            focusNode: positiveButtonFocus)
      ];

  void onSaved(BuildContext context, String? newName) {
    final submitted = submitField(newName);
    if (submitted) {
      Navigator.of(context).pop(newName);
    }
  }
}
