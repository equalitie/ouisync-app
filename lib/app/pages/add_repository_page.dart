import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/platform/platform.dart';
import '../utils/utils.dart';
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

    return Scaffold(
        appBar: AppBar(
          title: Text(S.current.titleAddRepoToken),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: const TextStyle(
              fontSize: Dimensions.fontAverage, color: Colors.black87),
        ),
        body: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Center(
                child: SingleChildScrollView(
              padding: Dimensions.paddingAll20,
              child: Column(children: [
                Fields.placeholderWidget(
                    assetName: Constants.assetPathAddWithQR,
                    assetHeight: noReposImageHeight),
                _buildScanQrCode(context),
                _buildOrSeparator(),
                _buildUseToken(context),
              ]),
            ))));
  }

  Widget _buildScanQrCode(BuildContext context) {
    return Column(
      children: [
        Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(children: [
                Fields.constrainedText(S.current.messageAddRepoQR,
                    flex: 0, color: Colors.black)
              ]),
              if (_isDesktop)
                Row(children: [
                  Fields.constrainedText('(Available on mobile)',
                      flex: 0, fontWeight: FontWeight.w200, color: Colors.black)
                ])
            ]),
        Dimensions.spacingVerticalDouble,
        _builScanQRButton(context),
      ],
    );
  }

  /// We don't support QR reading for desktop at the moment, just mobile.
  /// TODO: Find a plugin for reading QR with support for Windows, Linux
  Widget _builScanQRButton(BuildContext context) => Fields.inPageButton(
      onPressed: _isDesktop
          ? null
          : () async {
              final permissionName = S.current.messageCamera;
              final permissionGranted =
                  await _checkPermission(Permission.camera, permissionName);

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
                showSnackBar(context, message: tokenValidationError);

                return;
              }

              Navigator.of(context).pop(data);
            },
      leadingIcon: const Icon(Icons.qr_code_2_outlined),
      text: S.current.actionScanQR.toUpperCase());

  Future<bool> _checkPermission(
      Permission permission, String permissionName) async {
    final result = await Permissions.requestPermission(
        context, permission, permissionName);

    if (result.status != PermissionStatus.granted) {
      loggy.app(result.resultMessage);
      return false;
    }

    return true;
  }

  Widget _buildOrSeparator() {
    return Padding(
        padding: Dimensions.paddingVertical20,
        child: Row(
          children: [
            const Expanded(
                child: Divider(
              thickness: 1.0,
              endIndent: 20.0,
              color: Colors.black26,
            )),
            Text(
              S.current.messageOr.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Expanded(
                child: Divider(
              thickness: 1.0,
              indent: 20.0,
              color: Colors.black26,
            )),
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
                flex: 0, color: Colors.black),
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
              textEditingController: _tokenController,
              label: S.current.labelRepositoryLink,
              suffixIcon: const Icon(Icons.key_rounded),
              hint: S.current.messageRepositoryToken,
              validator: _repositoryTokenValidator),
        ),
        _builAddRepositoryButton(context),
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

  Widget _builAddRepositoryButton(BuildContext context) => Padding(
      padding: Dimensions.paddingVertical20,
      child: Fields.inPageButton(
          onPressed: () => _onAddRepo(_tokenController.text),
          text: S.current.actionAddRepository.toUpperCase()));

  void _onAddRepo(String shareLink) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();
    Navigator.of(context).pop(shareLink);
  }
}
