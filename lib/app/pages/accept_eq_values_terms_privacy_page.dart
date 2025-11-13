import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/stage.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class AcceptEqualitieValuesTermsPrivacyPage extends StatefulWidget {
  const AcceptEqualitieValuesTermsPrivacyPage({
    required this.stage,
    required this.settings,
    required this.onAccept,
    required this.onBack,
  });

  final Stage stage;
  final Settings settings;
  final void Function() onAccept;
  final void Function() onBack;

  @override
  State<AcceptEqualitieValuesTermsPrivacyPage> createState() =>
      _AcceptEqualitieValuesTermsPrivacyPageState();
}

class _AcceptEqualitieValuesTermsPrivacyPageState
    extends State<AcceptEqualitieValuesTermsPrivacyPage> {
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      body: PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: _onBackPressed,
        child: ContentWithStickyFooterState(
          content: _buildContent(context),
          footer: Fields.dialogActions(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            buttons: _buildActions(context),
          ),
        ),
      ),
    ),
  );

  Future<void> _onBackPressed(bool didPop, Object? result) async {
    if (didPop) return;
    widget.onBack();
  }

  Column _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _headerImages(),
        const SizedBox(height: 60.0),
        _introTextSpan(),
        const SizedBox(height: 20.0),
        EqValues(widget.stage),
        EqTermsAndPrivacy(widget.stage),
      ],
    );
  }

  Widget _headerImages() => Column(
    children: [
      const SizedBox(height: 18.0),
      Image.asset(
        Constants.ouisyncLogoFull,
        width: MediaQuery.of(context).size.width * 0.6,
      ),
      Padding(
        padding: EdgeInsetsDirectional.only(bottom: 10.0),
        child: Text(
          S.current.messageBy,
          style: context.theme.appTextStyle.bodyMicro.copyWith(
            color: Colors.black54,
          ),
        ),
      ),
      Image.asset(
        Constants.eQLogo,
        width: MediaQuery.of(context).size.width * 0.2,
      ),
    ],
  );

  Widget _introTextSpan() => RichText(
    textAlign: TextAlign.start,
    text: TextSpan(
      style: context.theme.appTextStyle.bodyMedium,
      children: [
        Fields.boldTextSpan(S.current.titleAppTitle),
        TextSpan(text: ' ${S.current.messageEqualitieValues}'),
      ],
    ),
  );

  List<Widget> _buildActions(BuildContext context) {
    final onBack = widget.onBack;
    return [
      OutlinedButton(
        onPressed: onBack,
        child: Text(S.current.actionBack.toUpperCase()),
      ),
      ElevatedButton(
        onPressed: () async {
          await widget.settings.setEqualitieValues(true);
          widget.onAccept();
        },
        autofocus: true,
        child: Text(S.current.actionIAgree.toUpperCase()),
      ),
    ];
  }
}
