import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../models/item.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class Rename extends StatefulWidget {
  const Rename({
    Key? key,
    required this.context,
    required this.entryData,
    required this.hint,
    required this.formKey,
  }) : super(key: key);

  final BuildContext context;
  final BaseItem entryData;
  final String hint;
  final GlobalKey<FormState> formKey;

  @override
  State<Rename> createState() => _RenameState();
}

class _RenameState extends State<Rename> {
  late String _oldName;

  final _newNameController = TextEditingController();

  late String _originalExtension;

  late bool _isFile;

  @override
  void initState() {
    selectEntryName();

    super.initState();
  }

  @override
  void dispose() {
    _newNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildRenameEntryWidget(widget.context),
    );
  }

  void selectEntryName() {
    _oldName = getBasename(widget.entryData.path);
    _originalExtension = getFileExtension(widget.entryData.path);

    _isFile = widget.entryData is FileItem;
    final fileExtensionOffset = _isFile ? _originalExtension.length : 0;

    _newNameController.text = _oldName;
    _newNameController.selection = TextSelection(
        baseOffset: 0, extentOffset: _oldName.length - fileExtensionOffset);
  }

  Widget _buildRenameEntryWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.constrainedText('"$_oldName"',
              flex: 0, fontWeight: FontWeight.w400),
          Dimensions.spacingVerticalDouble,
          Fields.formTextField(
              context: context,
              textEditingController: _newNameController,
              label: S.current.labelName,
              hint: widget.hint,
              onSaved: (newName) => Navigator.of(context).pop(newName),
              validator: _validateEntryName(
                  emptyError: S.current.messageErrorFormValidatorNameDefault,
                  regExp: '.*[/\\\\].*',

                  /// No / nor \ allowed
                  regExpError: S.current.messageErrorCharactersNotAllowed),
              autofocus: true),
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
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
            onPressed: () => Navigator.of(context).pop('')),
        PositiveButton(
            text: S.current.actionRename,
            onPressed: () async =>
                await _validateNewName(_newNameController.text))
      ];

  Future<void> _validateNewName(String newName) async {
    if (!(widget.formKey.currentState?.validate() ?? false)) return;

    if (_isFile) {
      final extensionValidationOK = await _validateExtension(newName);
      if (!extensionValidationOK) return;
    }

    widget.formKey.currentState!.save();
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
        context: widget.context,
        title: title,
        body: [
          Text(message)
        ],
        actions: [
          TextButton(
            child: Text(S.current.actionRename.toUpperCase()),
            onPressed: () => Navigator.of(widget.context).pop(true),
          ),
          TextButton(
            child: Text(S.current.actionCancelCapital),
            onPressed: () => Navigator.of(widget.context).pop(false),
          )
        ]);

    return continueAnyway ?? false;
  }
}
