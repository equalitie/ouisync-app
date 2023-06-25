import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.settings, required this.ouisyncAppHome});

  final Settings settings;
  final Widget ouisyncAppHome;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  final buttonStyle = TextStyle(fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        allowImplicitScrolling: true,
        autoScrollDuration: 3000,
        freeze: true,
        pages: [
          PageViewModel(
            title: S.current.titleOnboardingShare,
            body: S.current.messageOnboardingShare,
            image: _buildImage(Constants.onboardingShareImage),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: S.current.titleOnboardingPermissions,
            body: S.current.messageOnboardingPermissions,
            image: _buildImage(Constants.onboardingPermissionsImage),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: S.current.titleOnboardingAccess,
            body: S.current.messageOnboardingAccess,
            image: _buildImage(Constants.onboardingAccessImage),
            decoration: pageDecoration,
          ),
        ],
        onDone: () async => await _onIntroEnd(context),
        onSkip: () async => await _onIntroEnd(context), // You can override onSkip callback
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: true,
        rtl: Directionality.of(context) == TextDirection.rtl,
        back: _buildButton(S.current.actionBack),
        next: _buildButton(S.current.actionNext),
        done: _buildButton(S.current.actionDone),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ));
  }

  Future<void> _onIntroEnd(context) async {
    await widget.settings.setShowOnboarding(false);

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.ouisyncAppHome),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) =>
      Image.asset('assets/$assetName', width: width);

  Widget _buildButton(String text) =>
      Text(text.toUpperCase(), style: buttonStyle);
}
