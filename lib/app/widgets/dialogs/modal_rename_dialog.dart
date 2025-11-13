import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show RepoCubit;
import '../../utils/dialogs.dart';
import '../../utils/platform/platform.dart' show PlatformValues;
import '../../utils/stage.dart';
import '../../utils/utils.dart'
    show
        AppLogger,
        AppThemeExtension,
        Dimensions,
        Fields,
        TextEditingControllerExtension,
        Strings,
        ThemeGetter,
        validateNoEmptyMaybeRegExpr;
import '../widgets.dart' show NegativeButton, PositiveButton;

class RenameEntry extends StatefulWidget {
  RenameEntry({
    required this.stage,
    required this.repoCubit,
    required this.parent,
    required this.oldName,
    required this.originalExtension,
    required this.isFile,
    required this.hint,
  });

  final Stage stage;
  final RepoCubit repoCubit;
  final String parent;
  final String oldName;
  final String originalExtension;
  final bool isFile;
  final String hint;

  @override
  State<RenameEntry> createState() => _RenameEntryState();
}

class _RenameEntryState extends State<RenameEntry> with AppLogger {
  final formKey = GlobalKey<FormState>();

  final _newNameController = TextEditingController.fromValue(
    TextEditingValue.empty,
  );

  final _nameTextFieldFocus = FocusNode(debugLabel: 'name-txt-focus');
  final _positiveButtonFocus = FocusNode(debugLabel: 'positive-btn-focus');

  final _errorMessage = ValueNotifier('');

  @override
  void initState() {
    super.initState();

    _newNameController.addListener(() {
      if (_newNameController.text.isEmpty ||
          _newNameController.text == widget.oldName) {
        _errorMessage.value = '';
      }
    });

    selectEntryName(widget.oldName, widget.originalExtension, widget.isFile);
  }

  @override
  void dispose() {
    _errorMessage.dispose();
    _positiveButtonFocus.dispose();
    _nameTextFieldFocus.dispose();
    _newNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildRenameEntryWidget(context),
    );
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
        '"${widget.oldName}"',
        flex: 0,
        style: context.theme.appTextStyle.bodyMedium.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
      Dimensions.spacingVerticalDouble,
      ValueListenableBuilder(
        valueListenable: _errorMessage,
        builder: (context, errorMessage, child) => Fields.formTextField(
          context: context,
          controller: _newNameController,
          textInputAction: TextInputAction.done,
          labelText: S.current.labelName,
          hintText: widget.hint,
          errorText: _newNameController.text.isEmpty ? '' : errorMessage,
          onFieldSubmitted: (newName) async {
            final submitted = await _submitField(widget.parent, newName);
            if (submitted && PlatformValues.isDesktopDevice) {
              await widget.stage.maybePop(newName);
            }
          },
          validator: validateNoEmptyMaybeRegExpr(
            emptyError: S.current.messageErrorFormValidatorNameDefault,
            regExp: Strings.entityNameRegExp,
            regExpError: S.current.messageErrorCharactersNotAllowed,
          ),
          focusNode: _nameTextFieldFocus,
          autofocus: true,
        ),
      ),
      Fields.dialogActions(buttons: _actions()),
    ],
  );

  Future<bool> _submitField(String parent, String? newName) async {
    if (newName == null) return false;

    if (newName == widget.oldName) {
      _errorMessage.value = S.current.messageEnterDifferentName;
      _nameTextFieldFocus.requestFocus();

      return false;
    }

    final validationOk = await _validateNewName(parent, newName);
    if (!validationOk) {
      final newExtension = p.extension(newName);
      selectEntryName(newName, newExtension, widget.isFile);

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

    if (widget.isFile) {
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
    if (widget.originalExtension.isEmpty) return true;

    String title = '';
    String message = S.current.messageChangeExtensionAlert;

    if (fileExtension != widget.originalExtension) {
      title = S.current.titleFileExtensionChanged;
    }

    if (fileExtension.isEmpty) {
      title = S.current.titleFileExtensionMissing;
    }

    if (title.isEmpty) return true;

    final continueAnyway = await AlertDialogWithActions.show(
      widget.stage,
      title: title,
      body: [Text(message)],
      actions: [
        TextButton(
          child: Text(S.current.actionRename.toUpperCase()),
          onPressed: () => widget.stage.maybePop(true),
        ),
        TextButton(
          child: Text(S.current.actionCancelCapital),
          onPressed: () => widget.stage.maybePop(false),
        ),
      ],
    );

    return continueAnyway ?? false;
  }

  Future<bool> _validateNewNameDoNotExists(
    String parent,
    String newName,
  ) async {
    final newPath = p.join(parent, newName);
    final exist = await widget.repoCubit.entryExists(newPath);
    if (exist) {
      _errorMessage.value = S.current.messageEntryAlreadyExist(newName);
      return false;
    }

    _errorMessage.value = '';
    return true;
  }

  List<Widget> _actions() => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => widget.stage.maybePop(''),
    ),
    PositiveButton(
      text: S.current.actionRename,
      onPressed: () => _onSaved(widget.parent, _newNameController.text),
      focusNode: _positiveButtonFocus,
    ),
  ];

  Future<void> _onSaved(String parent, String? newName) async {
    final submitted = await _submitField(parent, newName);
    if (submitted) {
      await widget.stage.maybePop(newName);
    }
  }
}
