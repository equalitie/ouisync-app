import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.settings,
  });

  final Settings settings;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  final buttonStyle = TextStyle(fontWeight: FontWeight.w600);

  double _imageWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _imageWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
        titleTextStyle: context.theme.appTextStyle.titleLarge,
        bodyAlignment: Alignment.center,
        bodyTextStyle: context.theme.appTextStyle.bodyMedium,
        bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        imagePadding: EdgeInsets.zero);

    return IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
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
        onSkip: () async =>
            await _onIntroEnd(context), // You can override onSkip callback
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: true,
        rtl: Directionality.of(context) == TextDirection.rtl,
        back: _buildButton(S.current.actionBack),
        next: _buildButton(S.current.actionNext),
        done: _buildButton(S.current.actionDone),
        curve: Curves.fastLinearToSlowEaseIn,
        dotsDecorator: DotsDecorator(
          size: Size(10.0, 10.0),
          color: Theme.of(context).colorScheme.surfaceDim,
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ));
  }

  Future<void> _onIntroEnd(context) async {
    await widget.settings.setShowOnboarding(false);
    Navigator.of(context).pop(null);
  }

  Widget _buildImage(String assetName) => Image.asset(
        'assets/$assetName',
        width: _imageWidth * 0.6,
      );

  Widget _buildButton(String text) => Fields.inPageButton(
        text: text,
        size: Dimensions.sizeInPageButtonMicro,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        foregroundColor: Theme.of(context).colorScheme.surfaceTint,
        onPressed: null,
      );
}
