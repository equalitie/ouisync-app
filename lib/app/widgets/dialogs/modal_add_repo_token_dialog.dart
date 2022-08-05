import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class AddRepositoryWithToken extends StatefulWidget {
  const AddRepositoryWithToken({
    Key? key,
    required this.context,
    required this.cubit,
    required this.formKey,
    this.initialTokenValue
  }) : super(key: key);

  final BuildContext context;
  final ReposCubit cubit;
  final GlobalKey<FormState> formKey;
  final String? initialTokenValue;

  @override
  State<AddRepositoryWithToken> createState() => _AddRepositoryWithTokenState(initialTokenValue);
}

class _AddRepositoryWithTokenState extends State<AddRepositoryWithToken> with OuiSyncAppLogger {

  _AddRepositoryWithTokenState(String? initialTokenValue) :
      _tokenController = TextEditingController(text: initialTokenValue);

  final TextEditingController _tokenController;
  final TextEditingController _nameController = TextEditingController(text: null);
  final TextEditingController _passwordController = TextEditingController(text: null);
  final TextEditingController _retypedPasswordController = TextEditingController(text: null);

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscurePasswordConfirm = ValueNotifier<bool>(true);

  final ValueNotifier _accessModeNotifier = ValueNotifier<String>('');
  bool _showAccessModeMessage = false;

  String _suggestedName = '';
  bool _showSuggestedName = false;

  bool _requiresPassword = false;

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
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: _buildAddRepoWithTokenWidget(widget.context),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _retypedPasswordController.dispose();

    _obscurePassword.dispose();
    _obscurePasswordConfirm.dispose();

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
          label: S.current.labelRepositoryToken,
          hint: S.current.messageRepositoryToken,
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
                S.current.messageRepositoryAccessMode(message as String? ?? '?'),
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
          label: S.current.labelName,
          hint: S.current.messageRepositoryName,
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
                  S.current.messageRepositorySuggestedName(_repoName ?? ''),
                  flex: 1,
                  fontSize: Dimensions.fontSmall,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54
                )
              ]
            ),
          )
        ),
        Visibility(
          visible: _requiresPassword,
          child: ValueListenableBuilder(
            valueListenable: _obscurePassword,
            builder:(context, value, child) {
              final obscure = value as bool;
              return Row(
                children: [
                  Expanded(
                    child: Fields.formTextField(
                      context: context,
                      textEditingController: _passwordController,
                      obscureText: obscure,
                      label: S.current.labelPassword,
                      hint: S.current.messageRepositoryPassword,
                      onSaved: (_) {},
                      validator: (
                        password,
                        { error = Strings.messageErrorRepositoryPasswordValidation }
                      ) => formNameValidator(password, error: error),
                      autovalidateMode: AutovalidateMode.disabled
                    )
                  ),
                  Fields.actionIcon(
                    Icon(
                      obscure ? Constants.iconVisibilityOn : Constants.iconVisibilityOff,
                      size: Dimensions.sizeIconSmall,
                    ),
                    onPressed: () { _obscurePassword.value = !_obscurePassword.value; }
                  )
                ]
              );
            }
          ),
        ),
        Visibility(
          visible: _requiresPassword,
          child: ValueListenableBuilder(
            valueListenable: _obscurePasswordConfirm,
            builder:(context, value, child) {
              final obscure = value as bool;
              return Row(
                children: [
                  Expanded(
                    child: Fields.formTextField(
                      context: context,
                      textEditingController: _retypedPasswordController,
                      obscureText: obscure,
                      label: S.current.labelRetypePassword,
                      hint: S.current.messageRepositoryPassword,
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
                  ),
                  Fields.actionIcon(
                    Icon(
                      obscure ? Constants.iconVisibilityOn : Constants.iconVisibilityOff,
                      size: Dimensions.sizeIconSmall,
                    ),
                    onPressed: () { _obscurePasswordConfirm.value = !_obscurePasswordConfirm.value; }
                  )
                ]
              );
            }
          ),
        ),
        Fields.dialogActions(
          context,
          buttons: _actions(context)
        ),
      ]
    );
  }

  _updateNameController(String? value) {
    _nameController.text = value ?? '';
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
      _shareToken = ShareToken(widget.cubit.session, token);
    } catch (e, st) {
      loggy.app('Extract repository token exception', e, st);
      showSnackBar(context, content: Text(S.current.messageErrorTokenInvalid));

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

      _requiresPassword = _shareToken!.mode != AccessMode.blind;
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

  String? _repositoryTokenValidator(String? value, { String? error }) {
    if ((value ?? '').isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    try {
      final shareToken = ShareToken(widget.cubit.session, value!);

      _suggestedName = shareToken.suggestedName;
      _accessModeNotifier.value = shareToken.mode.name;
    } catch (e) {
      _suggestedName = '';
      _accessModeNotifier.value = '';

      return error ?? S.current.messageErrorTokenValidator;
    }

    return null;
  }

  List<Widget> _actions(context) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => Navigator.of(context).pop('')),
    PositiveButton(
      text: S.current.actionCreate,
      onPressed: _createRepo)
  ];

  void _createRepo() {
    final newRepositoryName = _nameController.text;
    final password = _passwordController.text;

    _onSaved(widget.cubit, newRepositoryName, password);
  }

  void _onSaved(ReposCubit cubit, String name, String password) async {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    widget.formKey.currentState!.save();
    cubit.openRepository(name, password: password, token: _shareToken, setCurrent: true);

    Navigator.of(widget.context).pop(name);
  }
}
