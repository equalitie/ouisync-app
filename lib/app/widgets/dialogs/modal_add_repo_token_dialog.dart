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
  );

  final scrollKey = GlobalKey();
  final ReposCubit _repos;

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

  final FocusNode _nameFocus = FocusNode(debugLabel: 'NameTextField');

  @override
  void initState() {
    _nameFocus.addListener(() async {
      if (_nameController.text.isEmpty) {
        setState(() => _showSuggestedName = _nameController.text.isEmpty);
      }
    });

    _validateToken();

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
    _nameController.dispose();
    _passwordController.dispose();
    _retypedPasswordController.dispose();

    _obscurePassword.dispose();
    _obscurePasswordConfirm.dispose();

    _accessModeNotifier.dispose();

    _nameFocus.dispose();

    super.dispose();
  }

  Widget _buildAddRepoWithTokenWidget(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTokenLabel(),
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
            key: scrollKey,
            context: context,
            textEditingController: _nameController,
            label: S.current.labelName,
            hint: S.current.messageRepositoryName,
            onSaved: (_) {},
            onChanged: (value) =>
                setState(() => _showSuggestedName = value.isEmpty),
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
                      S.current.messageRepositorySuggestedName(_suggestedName),
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
                  return Row(children: [
                    Expanded(
                      child: Fields.formTextField(
                        context: context,
                        textEditingController: _passwordController,
                        obscureText: obscure,
                        label: S.current.labelPassword,
                        subffixIcon: Fields.actionIcon(
                            Icon(
                              obscure
                                  ? Constants.iconVisibilityOn
                                  : Constants.iconVisibilityOff,
                              size: Dimensions.sizeIconSmall,
                            ), onPressed: () {
                          _obscurePassword.value = !_obscurePassword.value;
                        }),
                        hint: S.current.messageRepositoryPassword,
                        onSaved: (_) {},
                        validator: validateNoEmpty(
                            Strings.messageErrorRepositoryPasswordValidation),
                        autovalidateMode: AutovalidateMode.disabled,
                      ),
                    )
                  ]);
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
                  return Row(children: [
                    Expanded(
                      child: Fields.formTextField(
                        context: context,
                        textEditingController: _retypedPasswordController,
                        obscureText: obscure,
                        label: S.current.labelRetypePassword,
                        subffixIcon: Fields.actionIcon(
                            Icon(
                              obscure
                                  ? Constants.iconVisibilityOn
                                  : Constants.iconVisibilityOff,
                              size: Dimensions.sizeIconSmall,
                            ), onPressed: () {
                          _obscurePasswordConfirm.value =
                              !_obscurePasswordConfirm.value;
                        }),
                        hint: S.current.messageRepositoryPassword,
                        onSaved: (_) {},
                        validator: (retypedPassword) =>
                            retypedPasswordValidator(
                          password: _passwordController.text,
                          retypedPassword: retypedPassword,
                        ),
                        autovalidateMode: AutovalidateMode.disabled,
                      ),
                    )
                  ]);
                }),
          ),
          Fields.dialogActions(
            context,
            buttons: _actions(context),
          ),
        ]);
  }

  Widget _buildTokenLabel() {
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
              formatShareLinkForDisplay(widget.initialTokenValue ?? ''),
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
    _nameController.selection =
        TextSelection(baseOffset: 0, extentOffset: _suggestedName.length);

    setState(() => _showSuggestedName = _nameController.text.isEmpty);

    final targetContext = scrollKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(targetContext,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    }
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
    if (widget.initialTokenValue == null) return;
    try {
      _shareToken = ShareToken(
        _repos.session,
        widget.initialTokenValue!,
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

    _updateNameController(_suggestedName);

    setState(() {
      _showSuggestedName = _nameController.text.isEmpty;

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

    _accessModeNotifier.value = '';

    _updateNameController(null);
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
