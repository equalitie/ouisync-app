import 'dart:async';
import 'dart:io' as io;

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

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
  final _retryPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  bool _isBlindReplica = false;

  bool _addPassword = false;

  bool _isBiometricsAvailable = false;
  bool _secureWithBiometrics = false;

  bool _deleteRepositoryBeforePop = false;
  RepoMetaInfo? _repositoryMetaInfo;

  final ValueNotifier _accessModeNotifier = ValueNotifier<String>('');
  bool _showAccessModeMessage = false;

  String _suggestedName = '';
  bool _showSuggestedName = false;

  bool _showSavePasswordWarning = false;

  bool _showRepositoryNameInUseWarning = false;

  @override
  void initState() {
    unawaited(_init());

    _repositoryNameFocus.requestFocus();
    _addListeners();

    super.initState();
  }

  Future<void> _init() async {
    await _validateToken();

    final accessModeFuture = _shareToken?.mode;
    final accessMode =
        (accessModeFuture != null) ? await accessModeFuture : null;

    setState(() {
      _isBlindReplica = accessMode == AccessMode.blind;
      _isBiometricsAvailable = widget.isBiometricsAvailable;
    });

    _populatePasswordControllers(generatePassword: true);
  }

  Future<void> _validateToken() async {
    final token = widget.initialTokenValue;
    if (token == null) return;

    try {
      _shareToken = await ShareToken.fromString(widget.cubit.session, token);

      if (_shareToken == null) {
        throw "Failed to construct the token from \"$token\"";
      }
    } catch (e, st) {
      loggy.app('Extract repository token exception', e, st);
      showSnackBar(context, message: S.current.messageErrorTokenInvalid);

      cleanupFormOnEmptyToken();
    }

    if (_shareToken == null) return;

    _suggestedName = await _shareToken!.suggestedName;
    _accessModeNotifier.value = (await _shareToken!.mode).name;

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
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        if (_deleteRepositoryBeforePop) {
          assert(_repositoryMetaInfo != null, '_repositoryMetaInfo is null');

          if (_repositoryMetaInfo == null) {
            throw ('A repository was created, but saving the password into the '
                'secure storage failed and it may be lost.\nMost likely this '
                'repository needs to be deleted.');
          }

          final repoName = _repositoryMetaInfo!.name;
          final authMode =
              widget.cubit.settings.getAuthenticationMode(repoName) ??
                  Constants.authModeVersion1;

          await widget.cubit.deleteRepository(_repositoryMetaInfo!, authMode);
        }

        return true;
      },
      child: Form(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            SingleChildScrollView(
                reverse: true, child: _newRepositoryWidget(widget.context))
          ])));

  Widget _newRepositoryWidget(BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.initialTokenValue?.isNotEmpty ?? false)
              ..._buildTokenLabel(),
            ..._repositoryName(),
            if (!_isBlindReplica) ..._passwordSection(),
            if (_isBiometricsAvailable && !_isBlindReplica && _addPassword)
              _useBiometricsSwitch(),
            _manualPasswordWarning(),
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

  List<Widget> _passwordSection() => [_passwordInputs(), _addLocalPassword()];

  Widget _passwordInputs() => Visibility(
      visible: _addPassword && !_secureWithBiometrics,
      child: Container(
          child: Column(children: [
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _passwordInputKey,
                  context: context,
                  textEditingController: _passwordController,
                  obscureText: _obscurePassword,
                  label: S.current.labelPassword,
                  suffixIcon: _passwordActions(),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: validateNoEmpty(
                      Strings.messageErrorRepositoryPasswordValidation),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _passwordFocus))
        ]),
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _retypePasswordInputKey,
                  context: context,
                  textEditingController: _retypedPasswordController,
                  obscureText: _obscureRetypePassword,
                  label: S.current.labelRetypePassword,
                  suffixIcon: _retypePasswordActions(),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: (retypedPassword) => retypedPasswordValidator(
                        password: _passwordController.text,
                        retypedPassword: retypedPassword,
                      ),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: _retryPasswordFocus))
        ])
      ])));

  Widget _passwordActions() => Wrap(children: [
        IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: _obscurePassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final password = _passwordController.text;
              if (password.isEmpty) return;

              await copyStringToClipboard(password);
              showSnackBar(context,
                  message: S.current.messagePasswordCopiedClipboard);
            },
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black)
      ]);

  Widget _retypePasswordActions() => Wrap(children: [
        IconButton(
            onPressed: () => setState(
                () => _obscureRetypePassword = !_obscureRetypePassword),
            icon: _obscureRetypePassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final retypedPassword = _retypedPasswordController.text;
              if (retypedPassword.isEmpty) return;

              await copyStringToClipboard(retypedPassword);
              showSnackBar(context,
                  message: S.current.messagePasswordCopiedClipboard);
            },
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black)
      ]);

  String? retypedPasswordValidator(
      {required String password, required String? retypedPassword}) {
    if (retypedPassword == null || password != retypedPassword) {
      return S.current.messageErrorRetypePassword;
    }

    return null;
  }

  Widget _addLocalPassword() => Visibility(
      visible: !_addPassword,
      child: Row(children: [
        TextButton(
            onPressed: () => _updatePasswordSection(true),
            child: Text(S.current.messageAddLocalPassword))
      ]));

  Widget _useBiometricsSwitch() => Container(
      child: SwitchListTile.adaptive(
          value: _secureWithBiometrics,
          title: Text(S.current.messageSecureUsingBiometrics,
              textAlign: TextAlign.end),
          onChanged: (enableBiometrics) {
            setState(() {
              _secureWithBiometrics = enableBiometrics;

              _showSavePasswordWarning = !enableBiometrics;

              _populatePasswordControllers(generatePassword: enableBiometrics);
            });
          },
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact));

  Widget _manualPasswordWarning() => Visibility(
      visible: _showSavePasswordWarning && _addPassword,
      child: Fields.autosizeText(S.current.messageRememberSavePasswordAlert,
          color: Colors.red,
          maxLines: 10,
          softWrap: true,
          fontSize: Dimensions.fontSmall,
          textOverflow: TextOverflow.ellipsis));

  List<Widget> _actions(context) => [
        NegativeButton(
            text: _addPassword ? S.current.actionBack : S.current.actionCancel,
            onPressed: () => _addPassword
                ? _updatePasswordSection(false)
                : Navigator.of(context).pop('')),
        PositiveButton(
            text: _shareToken == null
                ? S.current.actionCreate
                : S.current.actionImport,
            onPressed: () {
              final name = _nameController.text;
              final password = _isBlindReplica ? '' : _passwordController.text;

              _onSaved(widget.cubit, name, password);
            })
      ];

  void _updatePasswordSection(bool addPassword) {
    setState(() {
      _addPassword = addPassword;

      // We used make biometrics the default; now we let the user enable it.
      _secureWithBiometrics = false;
      _showSavePasswordWarning = addPassword;
    });

    _populatePasswordControllers(generatePassword: !addPassword);
  }

  void _populatePasswordControllers({required bool generatePassword}) {
    final autoPassword = generatePassword ? generateRandomPassword() : '';

    _passwordController.text = autoPassword;
    _retypedPasswordController.text = autoPassword;

    if (_nameController.text.isEmpty) {
      _repositoryNameFocus.requestFocus();
      return;
    }

    if (!generatePassword) {
      _passwordFocus.requestFocus();
    }
  }

  void _onSaved(ReposCubit cubit, String name, String password) async {
    final isRepoNameOk =
        _repositoryNameInputKey.currentState?.validate() ?? false;
    final isPasswordOk = _passwordInputKey.currentState?.validate() ?? false;
    final isRetypePasswordOk =
        _retypePasswordInputKey.currentState?.validate() ?? false;

    if (!isRepoNameOk) return;
    _repositoryNameInputKey.currentState!.save();

    // A blind replica has no password
    if (!_isBlindReplica && _addPassword && !_secureWithBiometrics) {
      if (!(isPasswordOk && isRetypePasswordOk)) return;

      _passwordInputKey.currentState!.save();
      _retypePasswordInputKey.currentState!.save();
    }

    final info = RepoMetaInfo.fromDirAndName(
        await cubit.settings.defaultRepoLocation(), name);

    final exist = await Dialogs.executeFutureWithLoadingDialog(context,
        f: io.File(info.path()).exists());
    setState(() => _showRepositoryNameInUseWarning = exist);

    if (exist) return;

    /// We savePasswordToSecureStorage when: is not a blind replica AND there is
    /// not local password (authenticationRequired=false) OR using biometric
    /// validation (authenticationRequired=true).
    ///
    /// We authenticationRequired when: there is local password
    /// (authenticationRequired=false) AND using biometric validation
    /// (authenticationRequired=true).
    ///
    /// Both cases: Autogenerated and saved to secure storage.
    final savePasswordToSecureStorage = _isBlindReplica
        ? false
        : _addPassword
            ? _secureWithBiometrics
            : true;

    final authenticationRequired = _addPassword ? _secureWithBiometrics : false;

    final authenticationMode = authenticationRequired
        ? Constants.authModeVersion2
        : savePasswordToSecureStorage
            ? Constants.authModeNoLocalPassword
            : Constants.authModeManual;

    final repoEntry = await Dialogs.executeFutureWithLoadingDialog(context,
        f: cubit.createRepository(info,
            password: password,
            setCurrent: true,
            token: _shareToken,
            authenticationMode: authenticationMode));

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

    /// MANUAL PASSWORD - NO BIOMETRICS (ALSO: BLIND REPLICAS)
    /// ====================================================
    if (savePasswordToSecureStorage == false) {
      Navigator.of(widget.context).pop(name);

      return;
    }

    /// NO LOCAL PASSWORD (MAYBE BIOMETRICS) - AUTOGENERATED PASSWORD
    /// ====================================================

    /// We need to first create the repository (above), before saving the
    /// password to the secure storage, because we need the repository's
    /// database ID.
    ///
    /// If adding the password to the secure storage fail, we stay in the
    /// dialog, the user then can try again, or if the issue persist, opt out
    /// from using biometrics.
    ///
    /// If the issue is not related to the biometric authentication
    /// (StorageFileInitOptions.authenticationRequired = false), but saving the
    /// data to the secure storage all together, and since we already created
    /// the repository, we need to delete the repository before leaving this
    /// dialog if the user tap the CANCEL button, hence this:
    /// _deleteRepositoryBeforePop = true;
    final secureStorageResult = await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: SecureStorage.addRepositoryPassword(
            databaseId: repoEntry.databaseId,
            password: password,
            authMode: authenticationMode));

    if (secureStorageResult.exception != null) {
      loggy.app(secureStorageResult.exception);

      _setDeleteRepoBeforePop(true, repoEntry.metaInfo);

      if (secureStorageResult.exception is AuthException) {
        if ((secureStorageResult.exception as AuthException).code !=
            AuthExceptionCode.userCanceled) {
          await Dialogs.simpleAlertDialog(
              context: widget.context,
              title: S.current.messsageFailedCreateRepository(name),
              message: S.current.messageErrorAuthenticatingBiometrics);
        }
      }

      return;
    }

    _setDeleteRepoBeforePop(false, null);

    Navigator.of(widget.context).pop(name);
  }

  void _setDeleteRepoBeforePop(bool delete, RepoMetaInfo? repoMetaInfo) =>
      setState(() {
        _deleteRepositoryBeforePop = delete;
        _repositoryMetaInfo = repoMetaInfo;
      });

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
