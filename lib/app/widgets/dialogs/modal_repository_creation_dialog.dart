import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryCreation extends StatefulWidget {
  RepositoryCreation({
    required this.reposCubit,
    this.initialTokenValue,
  });

  final ReposCubit reposCubit;
  final String? initialTokenValue;

  @override
  State<RepositoryCreation> createState() => _RepositoryCreationState();
}

class _RepositoryCreationState extends State<RepositoryCreation>
    with AppLogger {
  late Future<void> init = _init();

  var isBiometricsAvailable = false;
  ShareToken? shareToken;
  var accessMode = AccessMode.blind;
  var localSecretMode = LocalSecretMode.randomStored;
  LocalPassword? localPassword;
  final nameController = TextEditingController();
  var nameSuggestion = '';
  var nameTaken = false;
  var useCacheServers = false;

  final formKey = GlobalKey<FormState>();

  String get name => nameController.text;

  TextStyle smallMessageStyle(BuildContext context) =>
      context.theme.appTextStyle.bodySmall.copyWith(color: Colors.black54);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: init,
      builder: (context, snapshot) =>
          // NOTE: Can't use `hasData` because the future returns void.
          (snapshot.connectionState == ConnectionState.done)
              ? Form(
                  key: formKey,
                  child: PopScope(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SingleChildScrollView(
                          reverse: true,
                          child: _buildContent(context),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(S.current.messageAwaitingResult),
                        )
                      ],
                    ),
                  ),
                ));

  Future<void> _init() async {
    final shareToken = await widget.initialTokenValue?.let(_validateToken);

    if (shareToken != null) {
      accessMode = await shareToken.mode;
      nameSuggestion = await shareToken.suggestedName;
    } else {
      accessMode = AccessMode.write;
      nameSuggestion = '';
    }

    this.shareToken = shareToken;

    isBiometricsAvailable = await LocalAuth.canAuthenticate();

    // When importing existing repository check if the cache servers have been already enabled.
    useCacheServers =
        (shareToken != null) ? await shareToken.isCacheServersEnabled() : true;
  }

  Future<ShareToken?> _validateToken(String initialToken) async {
    try {
      return await ShareToken.fromString(
        widget.reposCubit.session,
        initialToken,
      );
    } catch (e, st) {
      loggy.error('Extract repository token exception:', e, st);
      showSnackBar(S.current.messageErrorTokenInvalid);

      return null;
    }
  }

  Widget _buildContent(BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.initialTokenValue?.isNotEmpty ?? false)
              ..._buildTokenLabel(context),
            ..._buildNameField(context),
            if (accessMode == AccessMode.write)
              _buildUseCacheServersSwitch(context),
            RepoSecurity(
              localSecretMode: localSecretMode,
              isBiometricsAvailable: isBiometricsAvailable,
              passwordLabel: S.current.messageAddLocalPassword,
              onChanged: _onLocalSecretChanged,
            ),
            Fields.dialogActions(
              context,
              buttons: _buildActions(context),
            )
          ]);

  List<Widget> _buildTokenLabel(BuildContext context) => [
        Padding(
          padding: Dimensions.paddingVertical10,
          child: Container(
            padding: Dimensions.paddingShareLinkBox,
            decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
              color: Constants.inputBackgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Fields.constrainedText(
                  S.current.labelRepositoryLink,
                  flex: 0,
                  style: context.theme.appTextStyle.labelMedium
                      .copyWith(color: Constants.inputLabelForeColor),
                ),
                Dimensions.spacingVerticalHalf,
                Text(
                  formatShareLinkForDisplay(widget.initialTokenValue ?? ''),
                  style: context.theme.appTextStyle.bodySmall
                      .copyWith(fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ),
        Fields.constrainedText(
          S.current.messageRepositoryAccessMode(accessMode.name),
          flex: 0,
          style: smallMessageStyle(context),
        ),
      ];

  List<Widget> _buildNameField(BuildContext context) => [
        Padding(
          padding: Dimensions.paddingVertical10,
          child: Fields.formTextField(
            context: context,
            controller: nameController,
            labelText: S.current.labelName,
            hintText: S.current.messageRepositoryName,
            errorText:
                nameTaken ? S.current.messageErrorRepositoryNameExist : null,
            validator: _nameValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
        ),
        Visibility(
          visible: nameSuggestion.isNotEmpty,
          child: GestureDetector(
            onTap: () {
              nameController.text = nameSuggestion;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Fields.constrainedText(
                  S.current.messageRepositorySuggestedName(nameSuggestion),
                  style: smallMessageStyle(context),
                )
              ],
            ),
          ),
        ),
      ];

  Widget _buildUseCacheServersSwitch(BuildContext context) =>
      SwitchListTile.adaptive(
        value: useCacheServers,
        title: Text(
          S.current.messageUseCacheServers,
          textAlign: TextAlign.start,
          style: context.theme.appTextStyle.bodyMedium,
        ),
        onChanged: (value) => setState(() {
          useCacheServers = value;
        }),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );

  List<Widget> _buildActions(BuildContext context) => [
        NegativeButton(
          text: S.current.actionBack,
          onPressed: () => Navigator.of(context).pop(null),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        ),
        PositiveButton(
          text: shareToken == null
              ? S.current.actionCreate
              : S.current.actionImport,
          onPressed: () => _onSubmit(context),
          buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
        ),
      ];

  void _onLocalSecretChanged(
    LocalSecretMode localSecretMode,
    LocalPassword? localPassword,
  ) {
    setState(() {
      this.localSecretMode = localSecretMode;
      this.localPassword = localPassword;
    });
  }

  Future<void> _onSubmit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // NOTE: We do the uniqueness validation here instead of using the field validator because to
    // perform it we need to first construct the `RepoLocation` object which we also need here. If
    // we did it in the validator there would be no way to pass that object to here and we would
    // have to construct it again which would be sad.

    final defaultLocation =
        await widget.reposCubit.settings.defaultRepoLocation();
    final location = RepoLocation.fromDirAndName(defaultLocation, name);

    final exists = await Dialogs.executeFutureWithLoadingDialog(
      context,
      f: io.File(location.path).exists(),
    );

    setState(() {
      nameTaken = exists;
    });

    if (exists) {
      return;
    }

    final localSecret = (accessMode == AccessMode.blind ||
            localSecretMode.origin == SecretKeyOrigin.random)
        ? LocalSecretKeyAndSalt.random()
        : localPassword;

    if (localSecret == null) {
      return;
    }

    final repoEntry = await Dialogs.executeFutureWithLoadingDialog(context,
        f: widget.reposCubit.createRepository(
          location,
          localSecret,
          token: shareToken,
          localSecretMode: localSecretMode,
          useCacheServers: useCacheServers,
          setCurrent: true,
        ));

    switch (repoEntry) {
      case OpenRepoEntry():
        Navigator.of(context).pop(location);
      case ErrorRepoEntry():
        await Dialogs.simpleAlertDialog(
          context: context,
          title: S.current.messsageFailedCreateRepository(location.path),
          message: repoEntry.error,
        );

        return;
      case LoadingRepoEntry():
      case MissingRepoEntry():
        throw 'unreachable code';
    }
  }

  String? _nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.messageErrorFormValidatorNameDefault;
    }

    if (value.contains(RegExp(Strings.entityNameRegExp))) {
      return S.current.messageErrorCharactersNotAllowed;
    }

    return null;
  }
}
