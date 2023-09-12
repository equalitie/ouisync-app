import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/create_repo.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../storage/storage.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryCreation extends HookWidget with AppLogger {
  RepositoryCreation(
      {required this.context,
      required this.cubit,
      this.initialTokenValue,
      required this.isBiometricsAvailable});

  final BuildContext context;
  final ReposCubit cubit;
  final String? initialTokenValue;
  final bool isBiometricsAvailable;

  late final CreateRepositoryCubit createRepoCubit;

  final _scrollKey = GlobalKey();

  final _repositoryNameInputKey = GlobalKey<FormFieldState>();
  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  late TextEditingController nameController;
  late TextEditingController passwordController;
  late TextEditingController retypedPasswordController;

  late FocusNode repositoryNameFocus;
  late FocusNode passwordFocus;
  late FocusNode retryPasswordFocus;

  TextStyle? linkStyle;
  TextStyle? messageSmall;
  TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    _initHooks(context);
    _initTextStyles(context);

    final snapshotCubit = _getCubit();
    if (snapshotCubit.hasData) {
      createRepoCubit = snapshotCubit.data!;

      _populatePasswordControllers(generatePassword: true);

      repositoryNameFocus.requestFocus();
      _addListeners();

      return BlocBuilder<CreateRepositoryCubit, CreateRepositoryState>(
          bloc: createRepoCubit,
          builder: (context, state) => WillPopScope(
              onWillPop: () async {
                if (state.deleteRepositoryBeforePop) {
                  assert(state.repositoryMetaInfo != null,
                      '_repositoryMetaInfo is null');

                  if (state.repositoryMetaInfo == null) {
                    throw ('A repository was created, but saving the password into the '
                        'secure storage failed and it may be lost.\nMost likely this '
                        'repository needs to be deleted.');
                  }

                  final repoName = state.repositoryMetaInfo!.name;
                  final authMode =
                      cubit.settings.getAuthenticationMode(repoName);

                  await cubit.deleteRepository(
                      state.repositoryMetaInfo!, authMode);
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
                        reverse: true,
                        child: _newRepositoryWidget(context, state))
                  ]))));
    } else if (snapshotCubit.hasError) {
      return Container(
          child: Center(
              child: Column(children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Error: ${snapshotCubit.error}'),
        )
      ])));
    } else {
      return Container(
          child: Center(
              child: Column(children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Awaiting result...'),
        )
      ])));
    }
  }

  void _initHooks(BuildContext context) {
    initTextControllers();
    initFocusNodes();
  }

  void initTextControllers() {
    nameController = useTextEditingController.fromValue(TextEditingValue.empty);
    passwordController =
        useTextEditingController.fromValue(TextEditingValue.empty);
    retypedPasswordController =
        useTextEditingController.fromValue(TextEditingValue.empty);
  }

  void initFocusNodes() {
    repositoryNameFocus = useFocusNode(debugLabel: 'name-focus');
    passwordFocus = useFocusNode(debugLabel: 'password-focus');
    retryPasswordFocus = useFocusNode(debugLabel: 'retrypwd-focus');
  }

  AsyncSnapshot<CreateRepositoryCubit> _getCubit() {
    final futureCreateRepoCubit = useMemoized(initCubit);
    final snapshot = useFuture(futureCreateRepoCubit);
    return snapshot;
  }

  void _initTextStyles(BuildContext context) {
    linkStyle = context.theme.appTextStyle.bodySmall
        .copyWith(fontWeight: FontWeight.w500);

    labelStyle = context.theme.appTextStyle.labelMedium
        .copyWith(color: Constants.inputLabelForeColor);

    messageSmall =
        context.theme.appTextStyle.bodySmall.copyWith(color: Colors.black54);
  }

  Future<CreateRepositoryCubit> initCubit() async {
    ShareToken? shareToken;
    if (initialTokenValue != null) {
      shareToken = await _validateToken(initialTokenValue!);
    }

    String suggestedName = '';
    AccessMode? accessMode;

    if (shareToken != null) {
      suggestedName = await shareToken.suggestedName;
      accessMode = await shareToken.mode;
    }

    final showSuggestedName = suggestedName.isNotEmpty;
    final showAccessModeMessage = accessMode != null;

    final state = CreateRepositoryCubit.create(
        reposCubit: cubit,
        isBiometricsAvailable: isBiometricsAvailable,
        shareToken: shareToken,
        isBlindReplica: accessMode == AccessMode.blind,
        accessModeGranted: accessMode,
        suggestedName: suggestedName,
        showSuggestedName: showSuggestedName,
        showAccessModeMessage: showAccessModeMessage);

    return state;
  }

  Future<ShareToken?> _validateToken(String initialToken) async {
    ShareToken? shareToken;

    try {
      shareToken = await ShareToken.fromString(cubit.session, initialToken);

      if (shareToken == null) {
        throw "Failed to construct the token from \"$initialToken\"";
      }
    } catch (e, st) {
      loggy.app('Extract repository token exception', e, st);
      showSnackBar(context, message: S.current.messageErrorTokenInvalid);
    }

    return shareToken;
  }

  void _addListeners() {
    repositoryNameFocus.addListener(() {
      if (initialTokenValue != null && nameController.text.isEmpty) {
        createRepoCubit.showSuggestedName(nameController.text.isEmpty);
      }
    });

    nameController.addListener(() {
      if (initialTokenValue != null && nameController.text.isEmpty) {
        createRepoCubit.showSuggestedName(true);
      }

      createRepoCubit.showRepositoryNameInUseWarning(false);
    });
  }

  Widget _newRepositoryWidget(
          BuildContext context, CreateRepositoryState state) =>
      Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (initialTokenValue?.isNotEmpty ?? false)
              ..._buildTokenLabel(state),
            ..._repositoryName(state),
            if (!state.isBlindReplica) _passwordInputs(state),
            if (state.isBiometricsAvailable &&
                !state.isBlindReplica &&
                !state.addPassword)
              _useBiometricsSwitch(state),
            Dimensions.spacingVertical,
            if (!state.isBlindReplica) _addLocalPassword(state),
            _manualPasswordWarning(context, state),
            Fields.dialogActions(context, buttons: _actions(context, state)),
          ]);

  List<Widget> _buildTokenLabel(CreateRepositoryState state) => [
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
                          flex: 0, style: labelStyle),
                      Dimensions.spacingVerticalHalf,
                      Text(formatShareLinkForDisplay(initialTokenValue ?? ''),
                          style: linkStyle)
                    ]))),
        Visibility(
            visible: state.showAccessModeMessage,
            child: Fields.constrainedText(
                S.current
                    .messageRepositoryAccessMode(state.accessModeGranted.name),
                flex: 0,
                style: messageSmall))
      ];

  List<Widget> _repositoryName(CreateRepositoryState state) => [
        Dimensions.spacingVertical,
        Fields.formTextField(
            key: _repositoryNameInputKey,
            context: context,
            textEditingController: nameController,
            label: S.current.labelName,
            hint: S.current.messageRepositoryName,
            onSaved: (_) {},
            validator:
                validateNoEmpty(S.current.messageErrorFormValidatorNameDefault),
            autovalidateMode: AutovalidateMode.disabled,
            focusNode: repositoryNameFocus),
        _repositoryNameTakenWarning(state),
        Visibility(
            visible: state.showSuggestedName,
            child: GestureDetector(
                onTap: () => _updateNameController(state.suggestedName),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Fields.constrainedText(
                      S.current
                          .messageRepositorySuggestedName(state.suggestedName),
                      style: messageSmall)
                ]))),
        Dimensions.spacingVertical
      ];

  void _updateNameController(String value) {
    nameController.text = value;
    nameController.selection =
        TextSelection(baseOffset: 0, extentOffset: value.length);

    createRepoCubit
        .showSuggestedName(value.isEmpty && initialTokenValue != null);

    final targetContext = _scrollKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(targetContext,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    }
  }

  Widget _repositoryNameTakenWarning(CreateRepositoryState state) => Visibility(
      visible: state.showRepositoryNameInUseWarning,
      child: Fields.autosizeText(S.current.messageErrorRepositoryNameExist,
          style: TextStyle(color: Colors.red),
          maxLines: 10,
          softWrap: true,
          textOverflow: TextOverflow.ellipsis));

  Widget _passwordInputs(CreateRepositoryState state) => Visibility(
      visible: state.addPassword && !state.secureWithBiometrics,
      child: Container(
          child: Column(children: [
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _passwordInputKey,
                  context: context,
                  textEditingController: passwordController,
                  obscureText: state.obscurePassword,
                  label: S.current.labelPassword,
                  suffixIcon: _passwordActions(state),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: validateNoEmpty(
                      Strings.messageErrorRepositoryPasswordValidation),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: passwordFocus))
        ]),
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _retypePasswordInputKey,
                  context: context,
                  textEditingController: retypedPasswordController,
                  obscureText: state.obscureRetypePassword,
                  label: S.current.labelRetypePassword,
                  suffixIcon: _retypePasswordActions(state),
                  hint: S.current.messageRepositoryPassword,
                  onSaved: (_) {},
                  validator: (retypedPassword) => retypedPasswordValidator(
                        password: passwordController.text,
                        retypedPassword: retypedPassword,
                      ),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: retryPasswordFocus))
        ])
      ])));

  Widget _passwordActions(CreateRepositoryState state) => Wrap(children: [
        IconButton(
            onPressed: () =>
                createRepoCubit.obscurePassword(!state.obscurePassword),
            icon: state.obscurePassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final password = passwordController.text;
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

  Widget _retypePasswordActions(CreateRepositoryState state) => Wrap(children: [
        IconButton(
            onPressed: () => createRepoCubit
                .obscureRetypePassword(!state.obscureRetypePassword),
            icon: state.obscureRetypePassword
                ? const Icon(Constants.iconVisibilityOff)
                : const Icon(Constants.iconVisibilityOn),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black),
        IconButton(
            onPressed: () async {
              final retypedPassword = retypedPasswordController.text;
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

  Widget _addLocalPassword(CreateRepositoryState state) => Visibility(
      visible: !state.addPassword,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
            onPressed: state.secureWithBiometrics
                ? null
                : () => _updatePasswordSection(true),
            child: Text(S.current.messageAddLocalPassword))
      ]));

  Widget _useBiometricsSwitch(CreateRepositoryState state) => Container(
      child: SwitchListTile.adaptive(
          value: state.secureWithBiometrics,
          title: Text(S.current.messageSecureUsingBiometrics,
              textAlign: TextAlign.start,
              style: context.theme.appTextStyle.bodyMedium),
          onChanged: (enableBiometrics) {
            createRepoCubit.secureWithBiometrics(enableBiometrics);
            createRepoCubit.showSavePasswordWarning(!enableBiometrics);

            _populatePasswordControllers(generatePassword: true);
          },
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact));

  Widget _manualPasswordWarning(
          BuildContext context, CreateRepositoryState state) =>
      Visibility(
          visible: state.showSavePasswordWarning && state.addPassword,
          child: Fields.autosizeText(S.current.messageRememberSavePasswordAlert,
              style: context.theme.appTextStyle.bodyMedium
                  .copyWith(color: Colors.red),
              maxLines: 10,
              softWrap: true,
              textOverflow: TextOverflow.ellipsis));

  List<Widget> _actions(BuildContext context, CreateRepositoryState state) => [
        NegativeButton(
            text: state.addPassword
                ? S.current.actionBack
                : S.current.actionCancel,
            onPressed: () => state.addPassword
                ? _updatePasswordSection(false)
                : Navigator.of(context).pop(''),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: state.shareToken == null
                ? S.current.actionCreate
                : S.current.actionImport,
            onPressed: () {
              final name = nameController.text;
              final password =
                  state.isBlindReplica ? '' : passwordController.text;

              _onSaved(name, password, state);
            },
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
      ];

  void _updatePasswordSection(bool addPassword) {
    createRepoCubit.addPassword(addPassword);

    // Biometrics used to be the default; now we let the user enable it.
    createRepoCubit.secureWithBiometrics(false);
    createRepoCubit.showSavePasswordWarning(addPassword);

    _populatePasswordControllers(generatePassword: !addPassword);
  }

  void _populatePasswordControllers({required bool generatePassword}) {
    final autoPassword = generatePassword ? generateRandomPassword() : '';

    passwordController.text = autoPassword;
    retypedPasswordController.text = autoPassword;

    if (nameController.text.isEmpty) {
      repositoryNameFocus.requestFocus();
      return;
    }

    if (!generatePassword) {
      passwordFocus.requestFocus();
    }
  }

  void _onSaved(
      String name, String password, CreateRepositoryState state) async {
    final isRepoNameOk =
        _repositoryNameInputKey.currentState?.validate() ?? false;
    final isPasswordOk = _passwordInputKey.currentState?.validate() ?? false;
    final isRetypePasswordOk =
        _retypePasswordInputKey.currentState?.validate() ?? false;

    if (!isRepoNameOk) return;
    _repositoryNameInputKey.currentState!.save();

    if (state.addPassword) {
      if (!(isPasswordOk && isRetypePasswordOk)) return;

      _passwordInputKey.currentState!.save();
      _retypePasswordInputKey.currentState!.save();
    }

    final defaultRepoLocation = await createRepoCubit.defaultRepoLocation;
    final repoMetaInfo = RepoMetaInfo.fromDirAndName(defaultRepoLocation, name);

    final exist = await Dialogs.executeFutureWithLoadingDialog(context,
        f: io.File(repoMetaInfo.path()).exists());
    createRepoCubit.showRepositoryNameInUseWarning(exist);

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
    final savePasswordToSecureStorage = state.isBlindReplica
        ? false
        : state.secureWithBiometrics
            ? true
            : !state.addPassword;

    final authenticationRequired =
        state.secureWithBiometrics ? true : state.addPassword;

    final authenticationMode = savePasswordToSecureStorage
        ? authenticationRequired
            ? AuthMode.version2
            : AuthMode.noLocalPassword
        : AuthMode.manual;

    final repoEntry = await Dialogs.executeFutureWithLoadingDialog(context,
        f: createRepoCubit.createRepository(repoMetaInfo, password,
            state.shareToken, authenticationMode, true));

    if (repoEntry is! OpenRepoEntry) {
      var err = "Unknown";

      if (repoEntry is ErrorRepoEntry) {
        err = repoEntry.error;
      }

      await Dialogs.simpleAlertDialog(
          context: context,
          title: S.current.messsageFailedCreateRepository(name),
          message: err);

      return;
    }

    /// MANUAL PASSWORD - NO BIOMETRICS (ALSO: BLIND REPLICAS)
    /// ====================================================
    if (savePasswordToSecureStorage == false) {
      Navigator.of(context).pop(name);

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
    final savedPassword = await Dialogs.executeFutureWithLoadingDialog<String?>(
        context,
        f: SecureStorage(databaseId: repoEntry.databaseId)
            .saveOrUpdatePassword(value: password));

    if (savedPassword == null || savedPassword.isEmpty) {
      _setDeleteRepoBeforePop(true, repoEntry.metaInfo);

      // TODO: Check if this still can be determined or even occur
      // if (savedPassword.exception is AuthException) {
      //   if ((savedPassword.exception as AuthException).code !=
      //       AuthExceptionCode.userCanceled) {
      //     await Dialogs.simpleAlertDialog(
      //         context: context,
      //         title: S.current.messsageFailedCreateRepository(name),
      //         message: S.current.messageErrorAuthenticatingBiometrics);
      //   }
      // }

      return;
    }

    _setDeleteRepoBeforePop(false, null);

    Navigator.of(context).pop(name);
  }

  void _setDeleteRepoBeforePop(bool delete, RepoMetaInfo? repoMetaInfo) {
    createRepoCubit.deleteRepositoryBeforePop(delete);
    createRepoCubit.repositoryMetaInfo(repoMetaInfo);
  }
}
