import 'dart:io';

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../models/repo_location.dart';
import '../../utils/stage.dart';
import '../../utils/utils.dart'
    show
        AppThemeExtension,
        Fields,
        Strings,
        TextEditingControllerExtension,
        ThemeGetter,
        validateNoEmptyMaybeRegExpr;
import '../widgets.dart' show NegativeButton, PositiveButton;

class RenameRepository extends StatefulWidget {
  RenameRepository(this.stage, this.location, {super.key});

  final Stage stage;
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
        Fields.dialogActions(buttons: buildActions()),
      ],
    ),
  );

  List<Widget> buildActions() => [
    Expanded(
      child: NegativeButton(
        text: S.current.actionCancel,
        onPressed: () => widget.stage.maybePop(null),
      ),
    ),
    Expanded(
      child: PositiveButton(text: S.current.actionRename, onPressed: onSubmit),
    ),
  ];

  Future<void> onSubmit() async {
    if (!(await validate())) {
      newNameController.selectAll();
      newNameFocus.requestFocus();

      return;
    }

    final newName = newNameController.text;
    await widget.stage.maybePop(newName);
  }

  Future<bool> validate() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // Check if name is already taken
    final newLocation = widget.location.rename(newNameController.text);
    final exists = await widget.stage.loading(File(newLocation.path).exists());

    setState(() {
      nameTaken = exists;
    });

    return !exists;
  }
}
