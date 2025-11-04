import 'dart:io';

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../models/repo_location.dart';
import '../../utils/utils.dart'
    show
        AppThemeExtension,
        Dialogs,
        Fields,
        Strings,
        TextEditingControllerExtension,
        ThemeGetter,
        validateNoEmptyMaybeRegExpr;
import '../widgets.dart' show NegativeButton, PositiveButton;

class RenameRepository extends StatefulWidget {
  RenameRepository(this.location, {super.key});

  final RepoLocation location;

  @override
  State<RenameRepository> createState() => _RenameRepository();
}

class _RenameRepository extends State<RenameRepository> {
  final formKey = GlobalKey<FormState>();
  final newNameController = TextEditingController();
  final newNameFocus = FocusNode();

  var nameTaken = false;

  @override
  void initState() {
    super.initState();

    newNameController.text = widget.location.name;
    newNameController.selectAll();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Fields.constrainedText(
          '"${widget.location.name}"',
          flex: 0,
          style: context.theme.appTextStyle.bodyMedium.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        Fields.formTextField(
          context: context,
          controller: newNameController,
          textInputAction: TextInputAction.done,
          labelText: S.current.labelRenameRepository,
          hintText: S.current.messageRepositoryNewName,
          errorText: nameTaken
              ? S.current.messageErrorRepositoryNameExist
              : null,
          validator: validateNoEmptyMaybeRegExpr(
            emptyError: S.current.messageErrorFormValidatorNameDefault,
            regExp: Strings.entityNameRegExp,
            regExpError: S.current.messageErrorCharactersNotAllowed,
          ),
          focusNode: newNameFocus,
          autofocus: true,
          key: ValueKey('new-name'),
        ),
        Fields.dialogActions(buttons: buildActions(context)),
      ],
    ),
  );

  List<Widget> buildActions(BuildContext context) => [
    Expanded(
      child: NegativeButton(
        text: S.current.actionCancel,
        onPressed: () => Navigator.of(context).maybePop(null),
      ),
    ),
    Expanded(
      child: PositiveButton(
        text: S.current.actionRename,
        onPressed: () => onSubmit(context),
      ),
    ),
  ];

  Future<void> onSubmit(BuildContext context) async {
    if (!(await validate(context))) {
      newNameController.selectAll();
      newNameFocus.requestFocus();

      return;
    }

    final newName = newNameController.text;
    Navigator.of(context).pop(newName);
  }

  Future<bool> validate(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // Check if name is already taken
    final newLocation = widget.location.rename(newNameController.text);
    final exists = await Dialogs.executeFutureWithLoadingDialog(
      context,
      File(newLocation.path).exists(),
    );

    setState(() {
      nameTaken = exists;
    });

    return !exists;
  }
}
