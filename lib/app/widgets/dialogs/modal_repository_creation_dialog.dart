import 'dart:io' as io;

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:random_password_generator/random_password_generator.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryCreation extends StatefulWidget {
  const RepositoryCreation(
      {required this.context,
      required this.cubit,
      this.initialTokenValue,
      required this.isBiometricsAvailable,
      Key? key})
      : super(key: key);

  final BuildContext context;
  final ReposCubit cubit;
  final String? initialTokenValue;
  final bool isBiometricsAvailable;

  @override
  State<RepositoryCreation> createState() => _RepositoryCreationState();
}

class _RepositoryCreationState extends State<RepositoryCreation>
    with OuiSyncAppLogger {
  ShareToken? _shareToken;
  final _scrollKey = GlobalKey();

  final _repositoryNameInputKey = GlobalKey<FormFieldState>();
  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  final TextEditingController _nameController =
      TextEditingController(text: null);
  final TextEditingController _passwordController =
      TextEditingController(text: null);
  final TextEditingController _retypedPasswordController =
      TextEditingController(text: null);

  final _repositoryNameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  bool _showPasswordInput = false;
  bool _showRetypePasswordInput = false;

  bool _isBlindReplica = false;
  bool _generatePassword = true;

  bool _isBiometricsAvailable = false;
  bool _secureWithBiometrics = false;

  final ValueNotifier _accessModeNotifier = ValueNotifier<String>('');
  bool _showAccessModeMessage = false;

  String _suggestedName = '';
  bool _showSuggestedName = false;

  bool _showRepositoryNameInUseWarning = false;

  @override
  void initState() {
    _validateToken();

    setState(() => _isBlindReplica =
        _shareToken == null ? false : _shareToken!.mode == AccessMode.blind);

    _setupBiometrics();

    _repositoryNameFocus.requestFocus();
    _addListeners();

    super.initState();
  }

  void _validateToken() {
    final token = widget.initialTokenValue;

    if (token == null) return;

    try {
      _shareToken = ShareToken.fromString(token);

      if (_shareToken == null) {
        throw "Failed to construct the token from \"$token\"";
      }
    } catch (e, st) {
      loggy.app('Extract repository token exception', e, st);
      showSnackBar(
        context,
        content: Text(S.current.messageErrorTokenInvalid),
      );

      cleanupFormOnEmptyToken();
    }

    if (_shareToken == null) return;

    _suggestedName = _shareToken!.suggestedName;
    _accessModeNotifier.value = _shareToken!.mode.name;

    _updateNameController(_suggestedName);

    setState(() {
      _showAccessModeMessage = _accessModeNotifier.value.toString().isNotEmpty;
      _showSuggestedName = _nameController.text.isEmpty;
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

  void _updateNameController(String? value) {
    _nameController.text = value ?? '';
    _nameController.selection =
        TextSelection(baseOffset: 0, extentOffset: _suggestedName.length);

    setState(() => _showSuggestedName = _nameController.text.isEmpty);

    final targetContext = _scrollKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(targetContext,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    }
  }

  Future<void> _setupBiometrics() async {
    setState(() {
      _isBiometricsAvailable = widget.isBiometricsAvailable;
      _secureWithBiometrics = widget.isBiometricsAvailable;
    });

    _configureInputs(_generatePassword, _secureWithBiometrics);
  }

  void _addListeners() {
    _repositoryNameFocus.addListener(() {
      if (widget.initialTokenValue != null && _nameController.text.isEmpty) {
        setState(() => _showSuggestedName = _nameController.text.isEmpty);
      }
    });

    _nameController.addListener(() {
      if (widget.initialTokenValue != null && _nameController.text.isEmpty) {
        setState(() => _showSuggestedName = true);
      }

      setState(() => _showRepositoryNameInUseWarning = false);
    });
  }

  @override
  Widget build(BuildContext context) => Form(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            SingleChildScrollView(
                reverse: true, child: _newRepositoryWidget(widget.context))
          ]));

  Widget _newRepositoryWidget(BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.initialTokenValue?.isNotEmpty ?? false)
              ..._buildTokenLabel(),
            ..._repositoryName(),
            if (!_isBlindReplica) ..._passwordSection(),
            if (_isBiometricsAvailable && !_isBlindReplica)
              ..._biometricsSection(),
            Fields.dialogActions(context, buttons: _actions(context)),
          ]);

  List<Widget> _buildTokenLabel() => [
        Padding(
            padding: Dimensions.paddingVertical10,
            child: Container(
                padding: Dimensions.paddingShareLinkBox,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(Dimensions.radiusSmall)),
                    color: Constants.inputBackgroundColor),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Fields.constrainedText(S.current.labelRepositoryLink,
                          flex: 0,
                          fontSize: Dimensions.fontMicro,
                          fontWeight: FontWeight.normal,
                          color: Constants.inputLabelForeColor),
                      Dimensions.spacingVerticalHalf,
                      Text(
                          formatShareLinkForDisplay(
                              widget.initialTokenValue ?? ''),
                          style: const TextStyle(
                              fontSize: Dimensions.fontAverage,
                              fontWeight: FontWeight.w500))
                    ]))),
        ValueListenableBuilder(
            valueListenable: _accessModeNotifier,
            builder: (context, message, child) => Visibility(
                visible: _showAccessModeMessage,
                child: Fields.constrainedText(
                    S.current
                        .messageRepositoryAccessMode(message as String? ?? '?'),
                    flex: 0,
                    fontSize: Dimensions.fontSmall,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54)))
      ];

  List<Widget> _repositoryName() => [
        Dimensions.spacingVertical,
        Fields.formTextField(
            key: _repositoryNameInputKey,
            context: context,
            textEditingController: _nameController,
            label: S.current.labelName,
            hint: S.current.messageRepositoryName,
            onSaved: (_) {},
            validator:
                validateNoEmpty(S.current.messageErrorFormValidatorNameDefault),
            autovalidateMode: AutovalidateMode.disabled,
            focusNode: _repositoryNameFocus),
        _repositoryNameTakenWarning(),
        Visibility(
            visible: _showSuggestedName,
            child: GestureDetector(
                onTap: () => _updateNameController(_suggestedName),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Fields.constrainedText(
                    S.current.messageRepositorySuggestedName(_suggestedName),
                    flex: 1,
                    fontSize: Dimensions.fontSmall,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  )
                ]))),
        Dimensions.spacingVertical
      ];

  Widget _repositoryNameTakenWarning() => Visibility(
      visible: _showRepositoryNameInUseWarning,
      child: Fields.autosizeText(S.current.messageErrorRepositoryNameExist,
          color: Colors.red,
          maxLines: 10,
          softWrap: true,
          textOverflow: TextOverflow.ellipsis));

  List<Widget> _passwordSection() =>
      [_passwordInputs(), _generatePasswordSwitch()];

  Widget _passwordInputs() => Container(
          child: Column(children: [
        Visibility(
            visible: _showPasswordInput,
            child: Row(children: [
              Expanded(
                  child: Fields.formTextField(
                      key: _passwordInputKey,
                      context: context,
                      textEditingController: _passwordController,
                      obscureText: _obscurePassword,
                      label: S.current.labelPassword,
                      subffixIcon: Fields.actionIcon(
                          Icon(
                              _obscurePassword
                                  ? Constants.iconVisibilityOn
                                  : Constants.iconVisibilityOff,
                              size: Dimensions.sizeIconSmall), onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      }),
                      hint: S.current.messageRepositoryPassword,
                      onSaved: (_) {},
                      validator: validateNoEmpty(
                          Strings.messageErrorRepositoryPasswordValidation),
                      autovalidateMode: AutovalidateMode.disabled,
                      focusNode: _passwordFocus))
            ])),
        Visibility(
            visible: _showRetypePasswordInput,
            child: Row(children: [
              Expanded(
                  child: Fields.formTextField(
                      key: _retypePasswordInputKey,
                      context: context,
                      textEditingController: _retypedPasswordController,
                      obscureText: _obscureRetypePassword,
                      label: S.current.labelRetypePassword,
                      subffixIcon: Fields.actionIcon(
                          Icon(
                              _obscureRetypePassword
                                  ? Constants.iconVisibilityOn
                                  : Constants.iconVisibilityOff,
                              size: Dimensions.sizeIconSmall), onPressed: () {
                        setState(() =>
                            _obscureRetypePassword = !_obscureRetypePassword);
                      }),
                      hint: S.current.messageRepositoryPassword,
                      onSaved: (_) {},
                      validator: (retypedPassword) => retypedPasswordValidator(
                            password: _passwordController.text,
                            retypedPassword: retypedPassword,
                          ),
                      autovalidateMode: AutovalidateMode.disabled))
            ]))
      ]));

  String? retypedPasswordValidator(
      {required String password, required String? retypedPassword}) {
    if (retypedPassword == null || password != retypedPassword) {
      return S.current.messageErrorRetypePassword;
    }

    return null;
  }

  Widget _generatePasswordSwitch() => Container(
      child: SwitchListTile.adaptive(
          value: _generatePassword,
          title:
              Text(S.current.messageGeneratePassword, textAlign: TextAlign.end),
          onChanged: (generatePassword) {
            setState(() => _generatePassword = generatePassword);

            _configureInputs(_generatePassword, _secureWithBiometrics);
          },
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact));

  List<Widget> _biometricsSection() =>
      [_useBiometricsSwitch(), _manualPasswordWarning()];

  Widget _useBiometricsSwitch() => Container(
      child: SwitchListTile.adaptive(
          value: _secureWithBiometrics,
          title: Text(S.current.messageSecureUsingBiometrics,
              textAlign: TextAlign.end),
          onChanged: (enableBiometrics) {
            setState(() => _secureWithBiometrics = enableBiometrics);

            _configureInputs(_generatePassword, _secureWithBiometrics,
                preservePassword: true);
          },
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact));

  Widget _manualPasswordWarning() => Visibility(
      visible: !_secureWithBiometrics,
      child: Fields.autosizeText(S.current.messageRememberSavePasswordAlert,
          color: Colors.red,
          maxLines: 10,
          softWrap: true,
          textOverflow: TextOverflow.ellipsis));

  void _configureInputs(bool generatePassword, bool secureWithBiometrics,
      {bool preservePassword = false}) {
    setState(() {
      _showPasswordInput = !(generatePassword && secureWithBiometrics);
      _showRetypePasswordInput = !generatePassword && _showPasswordInput;

      // If for some reason the user decides to keep the autogenerated password,
      // but not to use biometrics, we make the password visible to signal the user
      // that the password need to be saved manually -just as it is stated in the
      // message explaning this, made visible at the same time.
      if (generatePassword && !secureWithBiometrics) {
        _obscurePassword = false;
      }
    });

    if (!preservePassword) {
      // Generate password or clean controllers if manual was selected by the user
      final password = _generatePassword ? _generateRandomPassword() : '';

      _passwordController.text = password;
      _retypedPasswordController.text = password;
    }

    // Set the fos and scroll to make the focused input visible
    generatePassword
        ? _scrollToVisible(_repositoryNameFocus)
        : _nameController.text.isEmpty
            ? _scrollToVisible(_repositoryNameFocus)
            : _passwordFocus.requestFocus();
  }

  String _generateRandomPassword() {
    final password = RandomPasswordGenerator();
    final autogeneratedPassword = password.randomPassword(
        letters: true,
        numbers: true,
        specialChar: true,
        uppercase: true,
        passwordLength: 24);

    return autogeneratedPassword;
  }

  void _scrollToVisible(FocusNode focusNode) => WidgetsBinding.instance
      .addPostFrameCallback((_) => Scrollable.ensureVisible(
            focusNode.context!,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          ));

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop('')),
        PositiveButton(
            text: S.current.actionCreate,
            onPressed: () {
              final name = _nameController.text;
              final password = _isBlindReplica ? '' : _passwordController.text;

              _onSaved(widget.cubit, name, password);
            })
      ];

  void _onSaved(ReposCubit cubit, String name, String password) async {
    final isRepoNameOk =
        _repositoryNameInputKey.currentState?.validate() ?? false;
    final isPasswordOk = _passwordInputKey.currentState?.validate() ?? false;
    final isRetypePasswordOk =
        _retypePasswordInputKey.currentState?.validate() ?? false;

    if (!isRepoNameOk) return;
    _repositoryNameInputKey.currentState!.save();

    // A blind replica has no password
    if (!_isBlindReplica) {
      // We created the password, no need for checking equality
      if (!_generatePassword) {
        if (!(isPasswordOk && isRetypePasswordOk)) return;

        _passwordInputKey.currentState!.save();
        _retypePasswordInputKey.currentState!.save();
      }
    }

    final info = RepoMetaInfo.fromDirAndName(
        await cubit.settings.defaultRepoLocation(), name);

    final exist = await Dialogs.executeFutureWithLoadingDialog(context,
        f: io.File(info.path()).exists());
    setState(() => _showRepositoryNameInUseWarning = exist);

    if (exist) return;

    final repoEntry = await Dialogs.executeFutureWithLoadingDialog(context,
        f: cubit.createRepository(info,
            password: password, setCurrent: true, token: _shareToken));

    if (repoEntry is! OpenRepoEntry) {
      var err = "Unknown";

      if (repoEntry is ErrorRepoEntry) {
        err = repoEntry.error;
      }

      await Dialogs.simpleAlertDialog(
          context: widget.context,
          title: S.current.messsageFailedCreateRepository(name),
          message: err);

      return;
    }

    // We add the password to the biometric storage before creating the repo.
    // The reason for this is that in case of the user canceling the biometric
    // authentication, we can just stay in the dialog, before even creating the
    // repo.
    // If instead we first create the repo, then add biometrics and there is an
    // exception  (most likely the user canceling the validation), we would
    // have the repo, but no biometrics, which would be confusiong for the user.
    if (_secureWithBiometrics) {
      final biometricsResult = await Dialogs.executeFutureWithLoadingDialog(
          context,
          f: Biometrics.addRepositoryPassword(
              databaseId: repoEntry.databaseId, password: password));

      if (biometricsResult.exception != null) {
        loggy.app(biometricsResult.exception);

        if (biometricsResult.exception is AuthException) {
          if ((biometricsResult.exception as AuthException).code !=
              AuthExceptionCode.userCanceled) {
            await Dialogs.simpleAlertDialog(
                context: widget.context,
                title: S.current.messsageFailedCreateRepository(name),
                message: S.current.messageErrorAuthenticatingBiometrics);
          }
        }

        await cubit.deleteRepository(repoEntry.metaInfo);

        return;
      }
    }

    Navigator.of(widget.context).pop(name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _retypedPasswordController.dispose();

    _repositoryNameFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }
}
