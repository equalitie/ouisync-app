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
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryCreation extends HookWidget with AppLogger {
  RepositoryCreation({
    required this.context,
    required this.cubit,
    this.initialTokenValue,
  });

  final BuildContext context;
  final ReposCubit cubit;
  final String? initialTokenValue;

  late final CreateRepositoryCubit createRepoCubit;

  final _formKey = GlobalKey<FormState>();
  final _scrollKey = GlobalKey();

  final _repositoryNameInputKey = GlobalKey<FormFieldState>();
  final _passwordInputKey = GlobalKey<FormFieldState>();
  final _retypePasswordInputKey = GlobalKey<FormFieldState>();

  late final TextEditingController nameController;
  late final TextEditingController passwordController;
  late final TextEditingController retypedPasswordController;

  late final FocusNode repositoryNameFocus;
  late final FocusNode passwordFocus;
  late final FocusNode retryPasswordFocus;

  late final FocusNode positiveButtonFocus;

  late final TextStyle linkStyle;
  late final TextStyle messageSmall;
  late final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final snapshotCubit = getCubit();
    if (snapshotCubit.hasData) {
      createRepoCubit = snapshotCubit.data!;

      initHooks();
      initTextStyles(context);

      populatePasswordControllers();
      updateNameController(createRepoCubit.state.suggestedName);

      addListeners();

      return BlocBuilder<CreateRepositoryCubit, CreateRepositoryState>(
        bloc: createRepoCubit,
        builder: (context, state) => PopScope(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  reverse: true,
                  child: newRepositoryWidget(context, state),
                ),
              ],
            ),
          ),
        ),
      );
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

  void initHooks() {
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

    positiveButtonFocus = useFocusNode(debugLabel: 'positive-btn-focus');
  }

  AsyncSnapshot<CreateRepositoryCubit> getCubit() {
    final futureCreateRepoCubit = useMemoized(initCubit);
    final snapshot = useFuture(futureCreateRepoCubit);
    return snapshot;
  }

  void initTextStyles(BuildContext context) {
    linkStyle = context.theme.appTextStyle.bodySmall
        .copyWith(fontWeight: FontWeight.w500);

    labelStyle = context.theme.appTextStyle.labelMedium
        .copyWith(color: Constants.inputLabelForeColor);

    messageSmall =
        context.theme.appTextStyle.bodySmall.copyWith(color: Colors.black54);
  }

  Future<CreateRepositoryCubit> initCubit() async {
    final shareToken = await initialTokenValue?.let(validateToken);

    final (accessMode, suggestedName, showAccessModeMessage) =
        (shareToken != null)
            ? (await shareToken.mode, await shareToken.suggestedName, true)
            : (AccessMode.write, '', false);

    final showSuggestedName = suggestedName.isNotEmpty;

    final isBiometricsAvailable = await LocalAuth.canAuthenticate();

    final state = await CreateRepositoryCubit.create(
      reposCubit: cubit,
      isBiometricsAvailable: isBiometricsAvailable,
      shareToken: shareToken,
      accessMode: accessMode,
      suggestedName: suggestedName,
      showSuggestedName: showSuggestedName,
      showAccessModeMessage: showAccessModeMessage,
    );

    return state;
  }

  Future<ShareToken?> validateToken(String initialToken) async {
    ShareToken? shareToken;

    try {
      shareToken = await ShareToken.fromString(cubit.session, initialToken);
    } catch (e, st) {
      loggy.error('Extract repository token exception:', e, st);
      showSnackBar(S.current.messageErrorTokenInvalid);
    }

    return shareToken;
  }

  void addListeners() {
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

  void selectName(String value) {
    nameController.text = value;
    nameController.selectAll();
  }

  void selectPassword(String value) {
    passwordController.text = value;
    passwordController.selectAll();
  }

  void selectRetypedPassword(String value) {
    retypedPasswordController.text = value;
    retypedPasswordController.selectAll();
  }

  Widget newRepositoryWidget(
    BuildContext context,
    CreateRepositoryState state,
  ) =>
      Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (initialTokenValue?.isNotEmpty ?? false)
              ...buildTokenLabel(state),
            ...repositoryName(state),
            if (state.accessMode == AccessMode.write)
              useCacheServersSwitch(state),
            if (state.accessMode != AccessMode.blind) passwordInputs(state),
            if (state.isBiometricsAvailable &&
                !state.addPassword &&
                state.accessMode != AccessMode.blind)
              useBiometricsSwitch(state),
            Dimensions.spacingVertical,
            if (state.accessMode != AccessMode.blind) addLocalPassword(state),
            manualPasswordWarning(context, state),
            Fields.dialogActions(context, buttons: _actions(context, state))
          ]);

  List<Widget> buildTokenLabel(CreateRepositoryState state) => [
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
                S.current.messageRepositoryAccessMode(state.accessMode.name),
                flex: 0,
                style: messageSmall))
      ];

  List<Widget> repositoryName(CreateRepositoryState state) {
    final nameWidget = [
      Dimensions.spacingVertical,
      Fields.formTextField(
          key: _repositoryNameInputKey,
          context: context,
          textEditingController: nameController,
          textInputAction:
              state.addPassword ? TextInputAction.done : TextInputAction.done,
          label: S.current.labelName,
          hint: S.current.messageRepositoryName,
          onFieldSubmitted: (newName) async {
            if (state.addPassword) {
              newName?.isEmpty ?? true
                  ? repositoryNameFocus.requestFocus()
                  : passwordFocus.requestFocus();
              return;
            }

            // This is to support pressing the Enter button to submit creation.
            if (!PlatformValues.isDesktopDevice) return;

            final nameFieldOk = await submitNameField(newName);
            if (!nameFieldOk) return;

            // We know `addPassword` is false from above, so generate the key.
            _onSaved(newName!, LocalSecretKeyAndSalt.random(), state);
          },
          validator: validateNoEmptyMaybeRegExpr(
              emptyError: S.current.messageErrorFormValidatorNameDefault,
              regExp: Strings.entityNameRegExp,
              regExpError: S.current.messageErrorCharactersNotAllowed),
          autovalidateMode: AutovalidateMode.disabled,
          focusNode: repositoryNameFocus),
      repositoryNameTakenWarning(state),
      Visibility(
        visible: state.suggestedName.isNotEmpty,
        child: GestureDetector(
          onTap: () => updateNameController(state.suggestedName),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Fields.constrainedText(
                  S.current.messageRepositorySuggestedName(state.suggestedName),
                  style: messageSmall)
            ],
          ),
        ),
      ),
      Dimensions.spacingVertical
    ];

    return nameWidget;
  }

  Future<bool> submitNameField(String? newName) async {
    final validationOk = await validateNewName(newName ?? '');

    if (!validationOk) {
      selectName(newName ?? '');
      repositoryNameFocus.requestFocus();

      return false;
    }

    if (PlatformValues.isMobileDevice) {
      positiveButtonFocus.requestFocus();
    }

    return true;
  }

  Future<bool> validateNewName(String newName) async {
    if (newName.isEmpty) return false;

    if (!(_formKey.currentState?.validate() ?? false)) return false;

    _formKey.currentState!.save();
    return true;
  }

  void updateNameController(String value) {
    nameController.text = value;
    nameController.selectAll();

    createRepoCubit
        .showSuggestedName(value.isEmpty && initialTokenValue != null);

    final targetContext = _scrollKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(targetContext,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    }
  }

  Widget repositoryNameTakenWarning(CreateRepositoryState state) => Visibility(
      visible: state.showRepositoryNameInUseWarning,
      child: Fields.autosizeText(S.current.messageErrorRepositoryNameExist,
          style: TextStyle(color: Colors.red),
          maxLines: 10,
          softWrap: true,
          textOverflow: TextOverflow.ellipsis));

  Widget useCacheServersSwitch(CreateRepositoryState state) => Container(
        child: SwitchListTile.adaptive(
          value: state.useCacheServers,
          title: Text(
            S.current.messageUseCacheServers,
            textAlign: TextAlign.start,
            style: context.theme.appTextStyle.bodyMedium,
          ),
          onChanged: (value) {
            createRepoCubit.useCacheServers(value);
          },
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      );

  Widget passwordInputs(CreateRepositoryState state) => Visibility(
      visible: state.addPassword && !state.secureWithBiometrics,
      child: Container(
          child: Column(children: [
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _passwordInputKey,
                  context: context,
                  textEditingController: passwordController,
                  textInputAction: TextInputAction.next,
                  obscureText: state.obscurePassword,
                  label: S.current.labelPassword,
                  suffixIcon: passwordActions(state),
                  hint: S.current.messageRepositoryPassword,
                  onFieldSubmitted: (newPassword) =>
                      retryPasswordFocus.requestFocus(),
                  validator: validateNoEmptyMaybeRegExpr(
                      emptyError:
                          S.current.messageErrorRepositoryPasswordValidation),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: passwordFocus))
        ]),
        Row(children: [
          Expanded(
              child: Fields.formTextField(
                  key: _retypePasswordInputKey,
                  context: context,
                  textEditingController: retypedPasswordController,
                  textInputAction: TextInputAction.done,
                  obscureText: state.obscureRetypePassword,
                  label: S.current.labelRetypePassword,
                  suffixIcon: retypePasswordActions(state),
                  hint: S.current.messageRepositoryPassword,
                  onFieldSubmitted: (retypedPassword) async {
                    final submitted =
                        await submitRetypedPasswordField(retypedPassword);
                    if (submitted && PlatformValues.isDesktopDevice) {
                      final newName = nameController.text;
                      _onSaved(newName, LocalPassword(retypedPassword!), state);
                    }
                  },
                  validator: (retypedPassword) => retypedPasswordValidator(
                        password: passwordController.text,
                        retypedPassword: retypedPassword,
                      ),
                  autovalidateMode: AutovalidateMode.disabled,
                  focusNode: retryPasswordFocus))
        ])
      ])));

  Future<bool> submitRetypedPasswordField(String? retypedPassword) async {
    final validationOk = await validateRetypedPassword(retypedPassword ?? '');

    if (!validationOk) {
      final password = passwordController.text;
      if (password.isEmpty) {
        passwordFocus.requestFocus();
        return false;
      }

      selectRetypedPassword(retypedPassword ?? '');
      retryPasswordFocus.requestFocus();

      return false;
    }

    if (PlatformValues.isMobileDevice) {
      positiveButtonFocus.requestFocus();
    }

    return true;
  }

  Future<bool> validateRetypedPassword(String retypedPassword) async {
    if (retypedPassword.isEmpty) return false;

    if (!(_formKey.currentState?.validate() ?? false)) return false;

    _formKey.currentState!.save();
    return true;
  }

  Widget passwordActions(CreateRepositoryState state) => Wrap(children: [
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
              showSnackBar(S.current.messagePasswordCopiedClipboard);
            },
            icon: const Icon(Icons.copy_rounded),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: Colors.black)
      ]);

  Widget retypePasswordActions(CreateRepositoryState state) => Wrap(children: [
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
              showSnackBar(S.current.messagePasswordCopiedClipboard);
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

  Widget addLocalPassword(CreateRepositoryState state) => Visibility(
      visible: !state.addPassword,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
            onPressed: state.secureWithBiometrics
                ? null
                : () => updatePasswordSection(true),
            child: Text(S.current.messageAddLocalPassword))
      ]));

  Widget useBiometricsSwitch(CreateRepositoryState state) => Container(
      child: SwitchListTile.adaptive(
          value: state.secureWithBiometrics,
          title: Text(S.current.messageSecureUsingBiometrics,
              textAlign: TextAlign.start,
              style: context.theme.appTextStyle.bodyMedium),
          onChanged: (enableBiometrics) {
            createRepoCubit.secureWithBiometrics(enableBiometrics);
            createRepoCubit.showSavePasswordWarning(!enableBiometrics);

            populatePasswordControllers();
          },
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact));

  Widget manualPasswordWarning(
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
                ? updatePasswordSection(false)
                : Navigator.of(context).pop(null),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: state.shareToken == null
                ? S.current.actionCreate
                : S.current.actionImport,
            onPressed: () async {
              final newName = nameController.text;

              SetLocalSecret secret;
              bool valuesAreOk;

              if (state.accessMode == AccessMode.blind || !state.addPassword) {
                secret = LocalSecretKeyAndSalt.random();
                valuesAreOk = await submitNameField(newName);
              } else {
                final password = passwordController.text;
                secret = LocalPassword(passwordController.text);
                valuesAreOk = await submitRetypedPasswordField(password);
              }

              if (valuesAreOk) {
                _onSaved(newName, secret, state);
              }
            },
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
            focusNode: positiveButtonFocus)
      ];

  void updatePasswordSection(bool addPassword) {
    createRepoCubit.addPassword(addPassword);

    // Biometrics used to be the default; now we let the user enable it.
    createRepoCubit.secureWithBiometrics(false);
    createRepoCubit.showSavePasswordWarning(addPassword);

    populatePasswordControllers();
  }

  void populatePasswordControllers() {
    passwordController.text = "";
    retypedPasswordController.text = "";

    if (nameController.text.isEmpty) {
      repositoryNameFocus.requestFocus();
      return;
    }

    passwordFocus.requestFocus();
  }

  void _onSaved(
      String name, SetLocalSecret secret, CreateRepositoryState state) async {
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
    final repoLocation = RepoLocation.fromDirAndName(defaultRepoLocation, name);

    final exist = await Dialogs.executeFutureWithLoadingDialog(
      context,
      f: io.File(repoLocation.path).exists(),
    );
    createRepoCubit.showRepositoryNameInUseWarning(exist);

    if (exist) return;

    /// We savePasswordToSecureStorage when: is not a blind replica AND there is
    /// not local secret (authenticationRequired=false) OR using biometric
    /// validation (authenticationRequired=true).
    ///
    /// We authenticationRequired when: there is local secret
    /// (authenticationRequired=false) AND using biometric validation
    /// (authenticationRequired=true).
    ///
    /// Both cases: Autogenerated and saved to secure storage.
    final savePasswordToSecureStorage = state.accessMode == AccessMode.blind
        ? false
        : state.secureWithBiometrics
            ? true
            : !state.addPassword;

    final authenticationRequired =
        state.secureWithBiometrics ? true : state.addPassword;

    final passwordMode = savePasswordToSecureStorage
        ? authenticationRequired
            ? PasswordMode.bio
            : PasswordMode.none
        : PasswordMode.manual;

    final repoEntry = await Dialogs.executeFutureWithLoadingDialog(context,
        f: cubit.createRepository(
          repoLocation,
          secret,
          token: state.shareToken,
          passwordMode: passwordMode,
          useCacheServers: state.useCacheServers,
          setCurrent: true,
        ));

    if (repoEntry is! OpenRepoEntry) {
      var err = "Unknown";

      if (repoEntry is ErrorRepoEntry) {
        err = repoEntry.error;
      }

      await Dialogs.simpleAlertDialog(
        context: context,
        title: S.current.messsageFailedCreateRepository(repoLocation.path),
        message: err,
      );

      return;
    }

    Navigator.of(context).pop(repoLocation);
  }
}
