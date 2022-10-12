import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class AddRepositoryWithToken extends StatefulWidget {
  const AddRepositoryWithToken({
    required this.context,
    required this.cubit,
    required this.formKey,
    this.initialTokenValue,
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final ReposCubit cubit;
  final GlobalKey<FormState> formKey;
  final String? initialTokenValue;

  @override
  State<AddRepositoryWithToken> createState() => _AddRepositoryWithTokenState(
        cubit,
        initialTokenValue,
      );
}

class _AddRepositoryWithTokenState extends State<AddRepositoryWithToken>
    with OuiSyncAppLogger {
  _AddRepositoryWithTokenState(
    this._repos,
    String? initialTokenValue,
  ) : _tokenController = TextEditingController(text: initialTokenValue);

  final scrollKey = GlobalKey();
  final ReposCubit _repos;

  final TextEditingController _tokenController;
  final TextEditingController _nameController =
      TextEditingController(text: null);
  final TextEditingController _passwordController =
      TextEditingController(text: null);
  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

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
  final FocusNode _nameFocus = FocusNode(debugLabel: 'NameTextField');

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
    _nameFocus.dispose();

    super.dispose();
  }

  Widget _buildAddRepoWithTokenWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tokenController.text.isEmpty
              ? Fields.formTextField(
                  context: context,
                  textEditingController: _tokenController,
                  label: S.current.labelRepositoryLink,
                  hint: S.current.messageRepositoryToken,
                  onSaved: (value) {},
                  validator: _repositoryTokenValidator,
                  autofocus: true,
                  focusNode: _tokenFocus,
                  maxLines: null,
                )
              : _buildTokenLabel(),
          ValueListenableBuilder(
            valueListenable: _accessModeNotifier,
            builder: (
              context,
              message,
              child,
            ) =>
                Visibility(
              visible: _showAccessModeMessage,
              child: Fields.constrainedText(
                S.current
                    .messageRepositoryAccessMode(message as String? ?? '?'),
                flex: 0,
                fontSize: Dimensions.fontSmall,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ),
          Fields.formTextField(
            context: context,
            textEditingController: _nameController,
            label: S.current.labelName,
            hint: S.current.messageRepositoryName,
            onSaved: (_) {},
            validator:
                validateNoEmpty(S.current.messageErrorFormValidatorNameDefault),
            autofocus: true,
            focusNode: _nameFocus,
            autovalidateMode: AutovalidateMode.disabled,
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
                      color: Colors.black54,
                    ),
                  ],
                ),
              )),
          Visibility(
            visible: _requiresPassword,
            child: ValueListenableBuilder(
                valueListenable: _obscurePassword,
                builder: (
                  context,
                  value,
                  child,
                ) {
                  final obscure = value;
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
                          validator: validateNoEmpty(
                              Strings.messageErrorRepositoryPasswordValidation),
                          autovalidateMode: AutovalidateMode.disabled,
                        ),
                      ),
                      Fields.actionIcon(
                          Icon(
                            obscure
                                ? Constants.iconVisibilityOn
                                : Constants.iconVisibilityOff,
                            size: Dimensions.sizeIconSmall,
                          ), onPressed: () {
                        _obscurePassword.value = !_obscurePassword.value;
                      }),
                    ],
                  );
                }),
          ),
          Visibility(
            visible: _requiresPassword,
            child: ValueListenableBuilder(
                valueListenable: _obscurePasswordConfirm,
                builder: (
                  context,
                  value,
                  child,
                ) {
                  final obscure = value;
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
                          validator: (retypedPassword) =>
                              retypedPasswordValidator(
                            password: _passwordController.text,
                            retypedPassword: retypedPassword,
                          ),
                          autovalidateMode: AutovalidateMode.disabled,
                        ),
                      ),
                      Fields.actionIcon(
                          Icon(
                            obscure
                                ? Constants.iconVisibilityOn
                                : Constants.iconVisibilityOff,
                            size: Dimensions.sizeIconSmall,
                          ), onPressed: () {
                        _obscurePasswordConfirm.value =
                            !_obscurePasswordConfirm.value;
                      }),
                    ],
                  );
                }),
          ),
          Fields.dialogActions(
            context,
            buttons: _actions(context),
          ),
        ]);
  }

  Widget _buildTokenLabel() {
    _validateToken();

    final targetContext = scrollKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    return Padding(
      padding: Dimensions.paddingVertical10,
      child: Container(
        padding: Dimensions.paddingShareLinkBox,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(Dimensions.radiusSmall),
          ),
          color: Constants.inputBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Fields.constrainedText(
              S.current.labelRepositoryLink,
              flex: 0,
              fontSize: Dimensions.fontMicro,
              fontWeight: FontWeight.normal,
              color: Constants.inputLabelForeColor,
            ),
            Dimensions.spacingVerticalHalf,
            Text(
              formatShareLinkForDisplay(_tokenController.text),
              style: const TextStyle(
                fontSize: Dimensions.fontAverage,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _updateNameController(String? value) {
    _nameController.text = value ?? '';
  }

  String? retypedPasswordValidator({
    required String password,
    required String? retypedPassword,
  }) {
    if (retypedPassword == null || password != retypedPassword) {
      return S.current.messageErrorRetypePassword;
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
      _shareToken = ShareToken(
        _repos.session,
        token,
      );
    } catch (e, st) {
      loggy.app('Extract repository token exception', e, st);
      showSnackBar(
        context,
        content: Text(S.current.messageErrorTokenInvalid),
      );

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

  String? _repositoryTokenValidator(
    String? value, {
    String? error,
  }) {
    if ((value ?? '').isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    try {
      final shareToken = ShareToken(
        _repos.session,
        value!,
      );

      _suggestedName = shareToken.suggestedName;
      _accessModeNotifier.value = shareToken.mode.name;

      final existingRepo = _repos.findById(shareToken.repositoryId());

      if (existingRepo != null) {
        return S.current.messageRepositoryAlreadyExist(existingRepo.name);
      }
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
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop('')),
        PositiveButton(
          text: S.current.actionCreate,
          onPressed: _createRepo,
        )
      ];

  void _createRepo() {
    final newRepositoryName = _nameController.text;
    final password = _passwordController.text;

    _onSaved(newRepositoryName, password);
  }

  void _onSaved(String name, String password) async {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final info = _repos.internalRepoMetaInfo(name);

    widget.formKey.currentState!.save();
    final repoEntry = await _repos.createRepository(
      info,
      password: password,
      token: _shareToken,
      setCurrent: true,
    );

    if (repoEntry is ErrorRepoEntry) {
      Dialogs.simpleAlertDialog(
        context: context,
        title: S.current.messsageFailedAddRepository(name),
        message: repoEntry.error,
      );
      return;
    }

    Navigator.of(widget.context).pop(name);
  }
}
