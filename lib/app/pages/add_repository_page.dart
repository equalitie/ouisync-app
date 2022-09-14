import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'pages.dart';

class AddRepositoryPage extends StatefulWidget {
  const AddRepositoryPage({
    required this.reposCubit,
    Key? key}) : super(key: key);
  
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
        title: const Text('Add a repository with token'),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        titleTextStyle: const TextStyle(
          fontSize: Dimensions.fontAverage,
          color: Colors.black87
        ),),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child:Center(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildScanQrCode(context),
              _buildOrSeparator(),
              _buildUseToken(context),
            ]),))));
  }

  Widget _buildScanQrCode(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fields.constrainedText(
              'Add a repository using a QR code',
              flex: 0),]),
        Dimensions.spacingVerticalDouble,
        _builScanQRButton(context),
      ],);
  }

  RawMaterialButton _builScanQRButton(BuildContext context) {
    return RawMaterialButton(
      onPressed: () async {
        final data = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return const QRScanner();
          }));

        if (!mounted) return;

        if (data == null) return;

        Navigator.of(context).pop(data);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code_2_outlined),
          Dimensions.spacingHorizontal,
          Text('Scan a QR code'.toUpperCase()),
        ],),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      fillColor: Theme.of(context).primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: Dimensions.borderRadiusDialogPositiveButton),
      textStyle: TextStyle(
        color: Theme.of(context).dialogBackgroundColor,
        fontWeight: FontWeight.w500),);
  }

  Widget _buildOrSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Row(
        children: const [
          Expanded(child: Divider(
            thickness: 1.0,
            endIndent: 20.0,
            color: Colors.black26,)),
          Text('OR',
            style: TextStyle(
              fontWeight: FontWeight.w500
            ),),
          Expanded(child: Divider(
            thickness: 1.0,
            indent: 20.0,
            color: Colors.black26,)),
        ],
      ));
  }

  Widget _buildUseToken(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fields.constrainedText(
              'Add a repository using a token link',
              flex: 0),]),
        Dimensions.spacingVerticalDouble,
        Container(
          padding: Dimensions.paddingItemBox,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
            color: Constants.inputBackgroundColor),
          child: Fields.formTextField(
            context: context,
            textEditingController: _tokenController,
            label: S.current.labelRepositoryLink,
            hint: S.current.messageRepositoryToken,
            onSaved: (value) {},
            validator: _repositoryTokenValidator,
            inputBorder: InputBorder.none
          )),
        _builAddRepositoryButton(context),
      ],);
  }

  String? _repositoryTokenValidator(String? value, { String? error }) {
    if ((value ?? '').isEmpty) {
      return S.current.messageErrorTokenEmpty;
    }

    try {
      final shareToken = ShareToken(widget.reposCubit.session, value!);

      final existingRepo = widget.reposCubit.findById(shareToken.repositoryId());

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
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: RawMaterialButton(
        onPressed: () => _onAddRepo(_tokenController.text),
        child: Text('Add repository'.toUpperCase()),
        constraints: Dimensions.sizeConstrainsDialogAction,
        elevation: Dimensions.elevationDialogAction,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        fillColor: Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: Dimensions.borderRadiusDialogPositiveButton),
        textStyle: TextStyle(
          color: Theme.of(context).dialogBackgroundColor,
          fontWeight: FontWeight.w500),)); 
  }

  void _onAddRepo(String shareLink) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    final token = _validateToken(shareLink);
    try {
      token?.suggestedName;
    } catch (e) {
      loggy.app(e.toString());
      return;
    }

    formKey.currentState!.save();
    Navigator.of(context).pop(shareLink);
  }

  ShareToken? _validateToken(String shareLink) {
    if (shareLink.isEmpty) {
      return null;
    }

    ShareToken? token;
    try {
      token = ShareToken(widget.reposCubit.session, shareLink);
    } catch (e, st) {
      loggy.app('Extract repository token exception', e, st);
      showSnackBar(context, content: Text(S.current.messageErrorTokenInvalid));
    }

    return token;
  }
}