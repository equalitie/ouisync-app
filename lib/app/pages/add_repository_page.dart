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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Fields.constrainedText(S.current.messageAddRepoQR, flex: 0),
        ]),
        Dimensions.spacingVerticalDouble,
        _builScanQRButton(context),
      ],
    );
  }

  Widget _builScanQRButton(BuildContext context) => Fields.inPageButton(
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
      leadingIcon: const Icon(Icons.qr_code_2_outlined),
      text: S.current.actionScanQR.toUpperCase());

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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Fields.constrainedText(S.current.messageAddRepoLink, flex: 0),
        ]),
        Dimensions.spacingVerticalDouble,
        Container(
            decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                color: Constants.inputBackgroundColor),
            child: Fields.formTextField(
                context: context,
                textEditingController: _tokenController,
                label: S.current.labelRepositoryLink,
                subffixIcon: const Icon(Icons.key_rounded),
                hint: S.current.messageRepositoryToken,
                onSaved: (value) {},
                validator: _repositoryTokenValidator)),
        _builAddRepositoryButton(context),
      ],
    );
  }

  String? _repositoryTokenValidator(String? value, {String? error}) {
    if (value == null || value.isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    try {
      final shareToken = ShareToken.fromString(value);

      if (shareToken == null) {
        return S.current.messageErrorTokenValidator;
      }

      final existingRepo =
          widget.reposCubit.findByInfoHash(shareToken.infoHash);

      if (existingRepo != null) {
        return S.current.messageRepositoryAlreadyExist(existingRepo.name);
      }
    } catch (e) {
      return error ?? S.current.messageErrorTokenValidator;
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
