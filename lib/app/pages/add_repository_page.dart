import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import 'pages.dart';

class AddRepositoryPage extends StatefulWidget {
  const AddRepositoryPage({required this.reposCubit});

  final ReposCubit reposCubit;

  @override
  State<AddRepositoryPage> createState() => _AddRepositoryPageState();
}

class _AddRepositoryPageState extends State<AddRepositoryPage> with AppLogger {
  final formKey = GlobalKey<FormState>();

  final _tokenController = TextEditingController(text: '');

  final _isDesktop = PlatformValues.isDesktopDevice;

  @override
  Widget build(BuildContext context) {
    final noReposImageHeight = MediaQuery.of(context).size.height * 0.2;

    final children = [
      Fields.placeholderWidget(
          assetName: Constants.assetPathAddWithQR,
          assetHeight: noReposImageHeight),
      _buildScanQrCode(context),
      _buildOrSeparator(),
      _buildUseToken(context),
    ];

    if (PlatformValues.isDesktopDevice) {
      children
        ..add(_buildOrSeparator())
        ..add(_buildImportOuisyncDb(context));
    }

    return Scaffold(
        appBar: AppBar(
            title: Text(S.current.titleAddRepoToken),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            titleTextStyle: context.theme.appTextStyle.titleMedium),
        body: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Center(
                child: SingleChildScrollView(
              padding: Dimensions.paddingAll20,
              child: Column(children: children),
            ))));
  }

  Widget _buildScanQrCode(BuildContext context) => Column(
        children: [
          Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(children: [
                  Fields.constrainedText(S.current.messageAddRepoQR, flex: 0)
                ]),
                if (_isDesktop)
                  Row(children: [
                    Fields.constrainedText(
                        '(${S.current.messageAvailableOnMobile})',
                        flex: 0,
                        style: context.theme.appTextStyle.bodySmall
                            .copyWith(fontWeight: FontWeight.w700))
                  ])
              ]),
          Dimensions.spacingVerticalDouble,
          _builScanQRButton(context),
        ],
      );

  /// We don't support QR reading for desktop at the moment, just mobile.
  /// TODO: Find a plugin for reading QR with support for Windows, Linux
  Widget _builScanQRButton(BuildContext context) => Fields.inPageButton(
      onPressed: _isDesktop
          ? null
          : () async {
              final permissionGranted =
                  await _checkPermission(Permission.camera);

              if (!permissionGranted) return;

              final data = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return QRScanner(widget.reposCubit.session);
              }));

              if (!mounted) return;
              if (data == null) return;

              final tokenValidationError =
                  await widget.reposCubit.validateTokenLink(data);

              if (tokenValidationError != null) {
                showSnackBar(tokenValidationError);

                return;
              }

              Navigator.of(context).pop(data);
            },
      leadingIcon: const Icon(Icons.qr_code_2_outlined),
      text: S.current.actionScanQR.toUpperCase());

  Future<bool> _checkPermission(Permission permission) async {
    final status = await Permissions.requestPermission(context, permission);
    return status == PermissionStatus.granted;
  }

  Widget _buildOrSeparator() {
    return Padding(
        padding: Dimensions.paddingVertical20,
        child: Row(
          children: [
            const Expanded(
                child: Divider(
                    thickness: 1.0, endIndent: 20.0, color: Colors.black26)),
            Text(
              S.current.messageOr.toUpperCase(),
              style: context.theme.appTextStyle.bodySmall
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Expanded(
                child: Divider(
                    thickness: 1.0, indent: 20.0, color: Colors.black26)),
          ],
        ));
  }

  Widget _buildUseToken(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fields.constrainedText(S.current.messageAddRepoLink,
                textAlign: TextAlign.center),
          ],
        ),
        Dimensions.spacingVerticalDouble,
        Container(
          decoration: const BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
            color: Constants.inputBackgroundColor,
          ),
          child: Fields.formTextField(
              context: context,
              controller: _tokenController,
              labelText: S.current.labelRepositoryLink,
              hintText: S.current.messageRepositoryToken,
              suffixIcon: const Icon(Icons.key_rounded),
              validator: _repositoryTokenValidator),
        ),
        _builAddRepositoryButton(),
      ],
    );
  }

  Widget _buildImportOuisyncDb(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fields.constrainedText(S.current.messageAddRepoDb,
                textAlign: TextAlign.center),
          ],
        ),
        Dimensions.spacingVerticalDouble,
        _buildButton(S.current.buttonLocateRepository, () async {
          final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: [
                RepoLocation.defaultExtension,
                RepoLocation.legacyExtension
              ]);
          if (result == null) return;
          for (final path in result.paths) {
            if (path == null) continue;
            await widget.reposCubit
                .importRepoFromLocation(RepoLocation.fromDbPath(path));
          }
          Navigator.of(context).pop();
        }),
      ],
    );
  }

  Future<String?> _repositoryTokenValidator(String? value) async {
    if (value == null || value.isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    try {
      final shareToken =
          await ShareToken.fromString(widget.reposCubit.session, value);

      final existingRepo =
          widget.reposCubit.findByInfoHash(await shareToken.infoHash);

      if (existingRepo != null) {
        return S.current.messageRepositoryAlreadyExist(existingRepo.name);
      }
    } catch (e) {
      return S.current.messageErrorTokenValidator;
    }

    return null;
  }

  Widget _builAddRepositoryButton() => _buildButton(
      S.current.actionAddRepository.toUpperCase(),
      () async => _onAddRepo(_tokenController.text));

  Widget _buildButton(String text, Future<void> Function() onPressed) =>
      Padding(
          padding: Dimensions.paddingVertical20,
          child: Fields.inPageButton(onPressed: () => onPressed(), text: text));

  void _onAddRepo(String shareLink) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();
    Navigator.of(context).pop(shareLink);
  }
}
