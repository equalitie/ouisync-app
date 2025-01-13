import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path/path.dart' as p;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show RepoCubit;
import '../../utils/platform/platform.dart' show PlatformValues;
import '../../utils/utils.dart'
    show
        AppLogger,
        AppThemeExtension,
        Dialogs,
        Dimensions,
        Fields,
        TextEditingControllerExtension,
        Strings,
        ThemeGetter,
        validateNoEmptyMaybeRegExpr;
import '../widgets.dart' show NegativeButton, PositiveButton;

class RenameEntry extends HookWidget with AppLogger {
  RenameEntry({
    required this.parentContext,
    required this.repoCubit,
    required this.parent,
    required this.oldName,
    required this.originalExtension,
    required this.isFile,
    required this.hint,
  });

  final BuildContext parentContext;
  final RepoCubit repoCubit;
  final String parent;
  final String oldName;
  final String originalExtension;
  final bool isFile;
  final String hint;

  final formKey = GlobalKey<FormState>();

  late final TextEditingController _newNameController;

  late final FocusNode _nameTextFieldFocus;
  late final FocusNode _positiveButtonFocus;

  late final ValueNotifier<String> _errorMessage;

  @override
  Widget build(BuildContext context) {
    initHooks();
    selectEntryName(oldName, originalExtension, isFile);

    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildRenameEntryWidget(context));
  }

  void initHooks() {
    _newNameController =
        useTextEditingController.fromValue(TextEditingValue.empty);

    _newNameController.addListener(() {
      if (_newNameController.text.isEmpty ||
          _newNameController.text == oldName) {
        _errorMessage.value = '';
      }
    });

    _nameTextFieldFocus = useFocusNode(debugLabel: 'name-txt-focus');
    _positiveButtonFocus = useFocusNode(debugLabel: 'positive-btn-focus');

    _errorMessage = useValueNotifier('');
  }

  void selectEntryName(String value, String extension, bool isFile) {
    final fileExtensionOffset = isFile ? extension.length : 0;

    _newNameController.text = value;
    _newNameController.selectAll(extentOffset: fileExtensionOffset);
  }

  Widget _buildRenameEntryWidget(BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.constrainedText(
              '"$oldName"',
              flex: 0,
              style: context.theme.appTextStyle.bodyMedium
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            Dimensions.spacingVerticalDouble,
            ValueListenableBuilder(
              valueListenable: _errorMessage,
              builder: (context, errorMessage, child) {
                return Fields.formTextField(
                  context: context,
                  controller: _newNameController,
                  textInputAction: TextInputAction.done,
                  labelText: S.current.labelName,
                  hintText: hint,
                  errorText:
                      _newNameController.text.isEmpty ? '' : errorMessage,
                  onFieldSubmitted: (newName) async {
                    final submitted = await _submitField(parent, newName);
                    if (submitted && PlatformValues.isDesktopDevice) {
                      await Navigator.of(context).maybePop(newName);
                    }
                  },
                  validator: validateNoEmptyMaybeRegExpr(
                      emptyError:
                          S.current.messageErrorFormValidatorNameDefault,
                      regExp: Strings.entityNameRegExp,
                      regExpError: S.current.messageErrorCharactersNotAllowed),
                  focusNode: _nameTextFieldFocus,
                  autofocus: true,
                );
              },
            ),
            Fields.dialogActions(buttons: _actions(context)),
          ]);

  Future<bool> _submitField(String parent, String? newName) async {
    if (newName == null) return false;

    if (newName == oldName) {
      _errorMessage.value = S.current.messageEnterDifferentName;
      _nameTextFieldFocus.requestFocus();

      return false;
    }

    final validationOk = await _validateNewName(parent, newName);
    if (!validationOk) {
      final newExtension = p.extension(newName);
      selectEntryName(newName, newExtension, isFile);

      _nameTextFieldFocus.requestFocus();

      return false;
    }

    if (PlatformValues.isMobileDevice) {
      _positiveButtonFocus.requestFocus();
    }

    return true;
  }

  Future<bool> _validateNewName(String parent, String newName) async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    if (isFile) {
      final extensionValidationOK = await _validateExtension(newName);
      if (!extensionValidationOK) return false;
    }

    final newPathExistOk = await _validateNewNameDoNotExists(parent, newName);
    if (!newPathExistOk) return false;

    formKey.currentState!.save();
    return true;
  }

  Future<bool> _validateExtension(String name) async {
    final fileExtension = p.extension(name);

    /// If there was not extension originally, then no need to have or validate
    /// a new one
    if (originalExtension.isEmpty) return true;

    String title = '';
    String message = S.current.messageChangeExtensionAlert;

    if (fileExtension != originalExtension) {
      title = S.current.titleFileExtensionChanged;
    }

    if (fileExtension.isEmpty) {
      title = S.current.titleFileExtensionMissing;
    }

    if (title.isEmpty) return true;

    final continueAnyway = await Dialogs.alertDialogWithActions(
        context: parentContext,
        title: title,
        body: [
          Text(message)
        ],
        actions: [
          TextButton(
            child: Text(S.current.actionRename.toUpperCase()),
            onPressed: () async =>
                await Navigator.of(parentContext).maybePop(true),
          ),
          TextButton(
            child: Text(S.current.actionCancelCapital),
            onPressed: () async =>
                await Navigator.of(parentContext).maybePop(false),
          )
        ]);

    return continueAnyway ?? false;
  }

  Future<bool> _validateNewNameDoNotExists(
    String parent,
    String newName,
  ) async {
    final newPath = p.join(parent, newName);
    final exist = await repoCubit.entryExists(newPath);
    if (exist) {
      _errorMessage.value = S.current.messageEntryAlreadyExist(newName);
      return false;
    }

    _errorMessage.value = '';
    return true;
  }

  List<Widget> _actions(BuildContext context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () async => await Navigator.of(context).maybePop('')),
        PositiveButton(
            text: S.current.actionRename,
            onPressed: () async =>
                await _onSaved(context, parent, _newNameController.text),
            focusNode: _positiveButtonFocus)
      ];

  Future<void> _onSaved(
    BuildContext context,
    String parent,
    String? newName,
  ) async {
    final submitted = await _submitField(parent, newName);
    if (submitted) {
      await Navigator.of(context).maybePop(newName);
    }
  }
}
