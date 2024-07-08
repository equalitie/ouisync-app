import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FolderCreation extends HookWidget {
  FolderCreation({required this.cubit, required this.parent});

  final RepoCubit cubit;
  final String parent;

  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;

  late final FocusNode nameTextFieldFocus;
  late final FocusNode positiveButtonFocus;

  late final ValueNotifier<String> errorMessage;

  @override
  Widget build(BuildContext context) {
    initHooks();

    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Dimensions.spacingVerticalDouble,
              ValueListenableBuilder(
                valueListenable: errorMessage,
                builder: (context, errorMessage, child) {
                  return Fields.formTextField(
                      context: context,
                      controller: nameController,
                      textInputAction: TextInputAction.done,
                      labelText: S.current.labelName,
                      hintText: S.current.messageFolderName,
                      errorText:
                          nameController.text.isEmpty ? '' : errorMessage,
                      onFieldSubmitted: (newFolderName) async {
                        final submitted =
                            await submitField(parent, newFolderName);
                        if (submitted && PlatformValues.isDesktopDevice) {
                          final newFolderPath =
                              repo_path.join(parent, newFolderName!);
                          Navigator.of(context).pop(newFolderPath);
                        }
                      },
                      validator: validateNoEmptyMaybeRegExpr(
                          emptyError:
                              S.current.messageErrorFormValidatorNameDefault,
                          regExp: Strings.entityNameRegExp,
                          regExpError:
                              S.current.messageErrorCharactersNotAllowed),
                      autofocus: true,
                      focusNode: nameTextFieldFocus);
                },
              ),
              Fields.dialogActions(context, buttons: _actions(context, parent)),
            ]));
  }

  void initHooks() {
    nameController = useTextEditingController.fromValue(TextEditingValue.empty);

    nameController.addListener(() {
      if (nameController.text.isEmpty) {
        errorMessage.value = '';
      }
    });

    nameTextFieldFocus = useFocusNode(debugLabel: 'name-txt-focus');
    positiveButtonFocus = useFocusNode(debugLabel: 'positive-btn-focus');

    errorMessage = useValueNotifier('');
  }

  void selectEntryName(String value) {
    nameController.text = value;
    nameController.selectAll();
  }

  Future<bool> submitField(String parent, String? newName) async {
    final validationOk = await validateNewName(parent, newName ?? '');

    if (!validationOk) {
      selectEntryName(newName ?? '');
      nameTextFieldFocus.requestFocus();

      return false;
    }

    if (PlatformValues.isMobileDevice) {
      positiveButtonFocus.requestFocus();
    }

    return true;
  }

  Future<bool> validateNewName(String parent, String newName) async {
    if (newName.isEmpty) return false;

    if (!(formKey.currentState?.validate() ?? false)) return false;

    final newFolderPath = repo_path.join(parent, newName);
    if (await cubit.exists(newFolderPath)) {
      errorMessage.value = S.current.messageEntryAlreadyExist(newName);
      return false;
    } else {
      errorMessage.value = '';
    }

    formKey.currentState!.save();
    return true;
  }

  List<Widget> _actions(BuildContext context, String parent) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(''),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionCreate,
            onPressed: () => onSaved(context, parent, nameController.text),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
            focusNode: positiveButtonFocus)
      ];

  void onSaved(
      BuildContext context, String parent, String newFolderName) async {
    final submitted = await submitField(parent, newFolderName);
    if (submitted) {
      final newFolderPath = repo_path.join(parent, newFolderName);
      Navigator.of(context).pop(newFolderPath);
    }
  }
}
