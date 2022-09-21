import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'pages.dart';

class AddRepositoryPage extends StatefulWidget {
  const AddRepositoryPage({required this.reposCubit, Key? key})
      : super(key: key);

  final ReposCubit reposCubit;

  @override
  State<AddRepositoryPage> createState() => _AddRepositoryPageState();
}

class _AddRepositoryPageState extends State<AddRepositoryPage>
    with OuiSyncAppLogger {
  final formKey = GlobalKey<FormState>();

  final _tokenController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
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
                _buildScanQrCode(context),
                _buildOrSeparator(),
                _buildUseToken(context),
              ]),
            ))));
  }

  Widget _buildScanQrCode(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Fields.constrainedText(S.current.messageAddRepoQR, flex: 0),
        ]),
        Dimensions.spacingVerticalDouble,
        _builScanQRButton(context),
      ],
    );
  }

  RawMaterialButton _builScanQRButton(BuildContext context) {
    return RawMaterialButton(
      onPressed: () async {
        final data =
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const QRScanner();
        }));

        if (!mounted) return;

        if (data == null) return;

        final tokenValidationError = widget.reposCubit.validateTokenLink(data);

        if (tokenValidationError != null) {
          showSnackBar(context, content: Text(tokenValidationError));

          return;
        }

        Navigator.of(context).pop(data);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code_2_outlined),
          Dimensions.spacingHorizontal,
          Text(S.current.actionScanQR.toUpperCase()),
        ],
      ),
      padding: Dimensions.paddingPageButtonIcon,
      fillColor: Theme.of(context).primaryColor,
      shape: const RoundedRectangleBorder(
          borderRadius: Dimensions.borderRadiusDialogPositiveButton),
      textStyle: TextStyle(
          color: Theme.of(context).dialogBackgroundColor,
          fontWeight: FontWeight.w500),
    );
  }

  Widget _buildOrSeparator() {
    return Padding(
        padding: Dimensions.paddingVertical40,
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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Fields.constrainedText(S.current.messageAddRepoLink, flex: 0),
        ]),
        Dimensions.spacingVerticalDouble,
        Container(
            padding: Dimensions.paddingItemBox,
            decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                color: Constants.inputBackgroundColor),
            child: Fields.formTextField(
                context: context,
                textEditingController: _tokenController,
                label: S.current.labelRepositoryLink,
                hint: S.current.messageRepositoryToken,
                onSaved: (value) {},
                validator: _repositoryTokenValidator,
                inputBorder: InputBorder.none)),
        _builAddRepositoryButton(context),
      ],
    );
  }

  String? _repositoryTokenValidator(String? value, {String? error}) {
    if ((value ?? '').isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    try {
      final shareToken = ShareToken(widget.reposCubit.session, value!);

      final existingRepo =
          widget.reposCubit.findById(shareToken.repositoryId());

      if (existingRepo != null) {
        return S.current.messageRepositoryAlreadyExist(existingRepo.name);
      }
    } catch (e) {
      return error ?? S.current.messageErrorTokenValidator;
    }

    return null;
  }

  Widget _builAddRepositoryButton(BuildContext context) {
    return Padding(
        padding: Dimensions.paddingVertical20,
        child: RawMaterialButton(
          onPressed: () => _onAddRepo(_tokenController.text),
          child: Text(S.current.actionAddRepository.toUpperCase()),
          constraints: Dimensions.sizeConstrainsDialogAction,
          elevation: Dimensions.elevationDialogAction,
          padding: Dimensions.paddingPageButton,
          fillColor: Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
              borderRadius: Dimensions.borderRadiusDialogPositiveButton),
          textStyle: TextStyle(
              color: Theme.of(context).dialogBackgroundColor,
              fontWeight: FontWeight.w500),
        ));
  }

  void _onAddRepo(String shareLink) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();
    Navigator.of(context).pop(shareLink);
  }
}
