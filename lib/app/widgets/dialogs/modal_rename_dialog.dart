import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../generated/l10n.dart';
import '../../models/item.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class Rename extends HookWidget with AppLogger {
  Rename({
    Key? key,
    required this.parentContext,
    required this.entryData,
    required this.hint,
    required this.formKey,
  }) : super(key: key);

  final BuildContext parentContext;
  final BaseItem entryData;
  final String hint;
  final GlobalKey<FormState> formKey;

  String _oldName = '';
  String _originalExtension = '';

  bool _isFile = false;

  late TextEditingController _newNameController;

  late FocusNode _nameTextFieldFocus;
  late FocusNode _positiveButtonFocus;

  @override
  Widget build(BuildContext context) {
    initHooks();
    initForm();

    final bodyStyle = initTextStyle(context);
    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _buildRenameEntryWidget(context, bodyStyle));
  }

  void initHooks() {
    _newNameController =
        useTextEditingController.fromValue(TextEditingValue.empty);

    _nameTextFieldFocus = useFocusNode(debugLabel: 'name-txt-focus');
    _positiveButtonFocus = useFocusNode(debugLabel: 'positive-btn-focus');
  }

  void initForm() {
    _oldName = getBasename(entryData.path);
    _originalExtension = getFileExtension(entryData.path);

    _isFile = entryData is FileItem;
    selectEntryName(_oldName, _originalExtension, _isFile);
  }

  TextStyle initTextStyle(BuildContext context) {
    final bodyStyle = context.theme.appTextStyle.bodyMedium
        .copyWith(fontWeight: FontWeight.w400);
    return bodyStyle;
  }

  Widget _buildRenameEntryWidget(BuildContext context, TextStyle bodyStyle) =>
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.constrainedText('"$_oldName"', flex: 0, style: bodyStyle),
            Dimensions.spacingVerticalDouble,
            Fields.formTextField(
                context: context,
                textEditingController: _newNameController,
                textInputAction: TextInputAction.done,
                label: S.current.labelName,
                hint: hint,
                onFieldSubmitted: (newName) async =>
                    await _validateFieldSubmitted(context),
                validator: _validateEntryName(
                    emptyError: S.current.messageErrorFormValidatorNameDefault,
                    regExp: '.*[/\\\\].*',

                    /// No / nor \ allowed
                    regExpError: S.current.messageErrorCharactersNotAllowed),
                focusNode: _nameTextFieldFocus,
                autofocus: true),
            Fields.dialogActions(context, buttons: _actions(context)),
          ]);

  void selectEntryName(String value, String extension, bool isFile) {
    final fileExtensionOffset = isFile ? extension.length : 0;

    _newNameController.text = value;
    _newNameController.selection = TextSelection(
        baseOffset: 0, extentOffset: value.length - fileExtensionOffset);
  }

  Future<void> _validateFieldSubmitted(BuildContext context) async {
    final newName = _newNameController.text;
    final newExtension = getFileExtension(_newNameController.text);
    final validationOk = await _validateNewName(newName);

    validationOk
        ? {
            PlatformValues.isDesktopDevice
                ? formKey.currentState!.save()
                : _positiveButtonFocus.requestFocus(),
            Navigator.of(context).pop(newName)
          }
        : {
            selectEntryName(newName, newExtension, _isFile),
            _nameTextFieldFocus.requestFocus()
          };
  }

  String? Function(String?) _validateEntryName(
          {String? emptyError, String? regExp, String? regExpError}) =>
      (String? newName) {
        if (newName?.isEmpty ?? true) return emptyError;
        if (newName!.contains(RegExp(regExp!))) return regExpError;

        return null;
      };

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(''),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionRename,
            onPressed: () async => await _validateFieldSubmitted(context),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
            focusNode: _positiveButtonFocus)
      ];

  Future<bool> _validateNewName(String newName) async {
    if (newName.isEmpty || newName == _oldName) return false;

    if (!(formKey.currentState?.validate() ?? false)) return false;

    if (_isFile) {
      final extensionValidationOK = await _validateExtension(newName);
      if (!extensionValidationOK) return false;
    }

    formKey.currentState!.save();
    return true;
  }

  Future<bool> _validateExtension(String name) async {
    final fileExtension = getFileExtension(name);

    /// If there was not extension originally, then no need to have or validate a new one
    if (_originalExtension.isEmpty) return true;

    String title = '';
    String message = S.current.messageChangeExtensionAlert;

    if (fileExtension != _originalExtension) {
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
            onPressed: () => Navigator.of(parentContext).pop(true),
          ),
          TextButton(
            child: Text(S.current.actionCancelCapital),
            onPressed: () => Navigator.of(parentContext).pop(false),
          )
        ]);

    return continueAnyway ?? false;
  }
}
