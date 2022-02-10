import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../cubit/cubits.dart';
import '../../utils/utils.dart';

class AddRepositoryWithToken extends StatefulWidget {
  const AddRepositoryWithToken({
    Key? key,
    required this.context,
    required this.cubit,
    required this.formKey
  }) : super(key: key);

  final BuildContext context;
  final RepositoriesCubit cubit;
  final GlobalKey<FormState> formKey;

  @override
  State<AddRepositoryWithToken> createState() => _AddRepositoryWithTokenState();
}

class _AddRepositoryWithTokenState extends State<AddRepositoryWithToken> {

  final TextEditingController _tokenController = TextEditingController(text: null);
  final TextEditingController _nameController = TextEditingController(text: null);
  final TextEditingController _passwordController = new TextEditingController(text: null);
  final TextEditingController _retypedPasswordController = new TextEditingController(text: null);

  ValueNotifier _accessModeNotifier = ValueNotifier<String>('');
  bool _showAccessModeMessage = false;

  String _suggestedName = '';
  bool _showSuggestedName = false;

  ShareToken? _shareToken;
  String? _repoName;

  final FocusNode _tokenFocus = FocusNode(debugLabel: 'TokenTextField');

  @override
  void initState() {
    _tokenFocus.addListener(() {
      if (!_tokenFocus.hasFocus) {
        _validateToken();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: this.widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: _buildAddRepoWithTokenWidget(this.widget.context),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _retypedPasswordController.dispose();

    _accessModeNotifier.dispose();
    
    _tokenFocus.dispose();

    super.dispose();
  }

  Widget _buildAddRepoWithTokenWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Fields.formTextField(
          context: context,
          textEditingController: _tokenController,
          label: Strings.labelRepositoryToken,
          hint: Strings.messageRepositoryToken,
          onSaved: (value) {},
          validator: _repositoryTokenValidator,
          autofocus: true,
          focusNode: _tokenFocus,
          maxLines: null,
        ),
        ValueListenableBuilder(
          valueListenable: _accessModeNotifier,
          builder: (context, message, child) => 
            Visibility(
              visible: _showAccessModeMessage,
              child: Fields.constrainedText(
                Strings.messageRepositoryAccessMode
                .replaceAll(Strings.replacementAccess, message as String? ?? '?'),
                flex: 0,
                fontSize: Dimensions.fontSmall,
                fontWeight: FontWeight.normal,
                color: Colors.black54
              )
            )
        ),
        Fields.formTextField(
          context: context,
          textEditingController: _nameController,
          label: Strings.labelName,
          hint: Strings.messageRepositoryName,
          onSaved: (_) {},
          validator: formNameValidator,
          autovalidateMode: AutovalidateMode.disabled
        ),
        Visibility(
          visible: _showSuggestedName,
          child: GestureDetector(
            onTap: () => _updateNameController(_suggestedName),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Fields.constrainedText(
                  Strings.messageRepositorySuggestedName
                    .replaceAll(Strings.replacementName, _repoName ?? ''),
                  flex: 1,
                  fontSize: Dimensions.fontSmall,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54
                )
              ]
            ),
          )
        ),
        Fields.formTextField(
          context: context,
          textEditingController: _passwordController,
          obscureText: true,
          label: Strings.labelPassword,
          hint: Strings.messageRepositoryPassword,
          onSaved: (_) {},
          validator: (
            password,
            { error = Strings.messageErrorRepositoryPasswordValidation }
          ) => formNameValidator(password, error: error),
          autovalidateMode: AutovalidateMode.disabled
        ),
        Fields.formTextField(
          context: context,
          textEditingController: _retypedPasswordController,
          obscureText: true,
          label: Strings.labelRetypePassword,
          hint: Strings.messageRepositoryPassword,
          onSaved: (_) {},
          validator: (
            retypedPassword,
            { error = Strings.messageErrorRetypePassword }
          ) => retypedPasswordValidator(
              password: _passwordController.text,
              retypedPassword: retypedPassword!,
              error: error
            ),
          autovalidateMode: AutovalidateMode.disabled
        ),
        Fields.actionsSection(
          context,
          buttons: _actions(context)
        ),
      ]
    );
  }

  _updateNameController(String? value) {
    _nameController.text = value ?? '';
    // _nameController.selection = TextSelection.collapsed(offset: value?.length ?? 0);
  }

  String? retypedPasswordValidator({
    required String password,
    required String retypedPassword,
    required String error
  }) {
    if (password != retypedPassword) {
      return error;
    }

    return null;
  }

  _validateToken() {
    if (_tokenController.text.isEmpty) {
      cleanupFormOnEmptyToken();
      return;
    }

    final token = _tokenController.text;
    try {
      _shareToken = ShareToken(this.widget.cubit.session, token);
    } catch (e) {
      print('Error extracting the repository token:\n${e.toString()}');                
      showToast(Strings.messageErrorTokenInvalid);

      cleanupFormOnEmptyToken();
    }

    if (_shareToken == null) {
      return;
    }

    _suggestedName = _shareToken!.suggestedName; 
    _accessModeNotifier.value = _shareToken!.mode.name;

    if (_suggestedName.isNotEmpty) {
      _repoName = _suggestedName;
    }

    setState(() { 
      _showSuggestedName = _suggestedName.isNotEmpty; 
      _showAccessModeMessage = _accessModeNotifier.value.toString().isNotEmpty;
    });
  }

  void cleanupFormOnEmptyToken() {
    setState(() { 
        _showSuggestedName = false; 
        _showAccessModeMessage = false;
      });

      _suggestedName = '';
      _repoName = '';

      _accessModeNotifier.value = '';

      _updateNameController(null);
  }

  String? _repositoryTokenValidator(String? value, { String error = Strings.messageErrorTokenValidator}) {
    if ((value ?? '').isEmpty) {
      return Strings.messageErrorTokenEmpty;
    }

    try {
      final shareToken = ShareToken(this.widget.cubit.session, value!);
      
      _suggestedName = shareToken.suggestedName;
      _accessModeNotifier.value = shareToken.mode.name;
    } catch (e) {
      _suggestedName = '';
      _accessModeNotifier.value = '';

      return error;
    }

    return null;
  }

  void _onSaved(RepositoriesCubit cubit, String name, String password) async {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    widget.formKey.currentState!.save();
    cubit.openRepository(name: name, password: password, shareToken: _shareToken);

    Navigator.of(this.widget.context).pop(name);
  }

  List<Widget> _actions(context) => [
    ElevatedButton(
      onPressed: () {
        final newRepositoryName = _nameController.text;
        final password = _passwordController.text;

        _onSaved(widget.cubit, newRepositoryName, password);
      },
      child: Text(Strings.actionCreate)
    ),
    Dimensions.spacingActionsHorizontal,
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text(Strings.actionCancel)
    ),
  ];
}