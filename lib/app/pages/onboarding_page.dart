import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'language_picker_page.dart';
import 'accept_eq_values_terms_privacy_page.dart';
import '../../generated/l10n.dart';
import '../cubits/locale.dart';
import '../utils/utils.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage(this._localeCubit, this.settings, {required this.mainPage});

  final LocaleCubit _localeCubit;
  final Settings settings;
  final Widget mainPage;
  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState(
    onboardingShown: !settings.getShowOnboarding(),
    acceptedTerms: settings.getEqualitieValues(),
  );
}

class _OnboardingPageState extends State<OnboardingPage> {
  _OnboardingPageState({
    required this.onboardingShown,
    required this.acceptedTerms,
  });

  final introKey = GlobalKey<IntroductionScreenState>();
  IntroductionScreenState? get intro => introKey.currentState;

  int _pageIndex = 0;
  int _introPageIndex = 0;
  bool onboardingShown;
  bool acceptedTerms;

  double _imageWidth = 0;

  // Ideally, we would get this value from `intro.currentState.getPagesLength() - 1`,
  // but the introduction page screen's state gets deleted when the introduction
  // screen is done.
  int _lastIntroPageIndex() => 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _imageWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    if (onboardingShown && acceptedTerms) {
      return widget.mainPage;
    }

    if (_pageIndex == 0) {
      return LanguagePicker(
        localeCubit: widget._localeCubit,
        canPop: false,
        onSelect: () {
          setState(() {
            _pageIndex += 1;
          });
        },
      );
    }
    if (_pageIndex == 1) {
      return _buildIntroduction(context);
    } else if (_pageIndex == 2) {
      return AcceptEqualitieValuesTermsPrivacyPage(
        settings: widget.settings,
        onAccept: () {
          setState(() {
            acceptedTerms = true;
            _pageIndex += 1;
          });
        },
        onBack: () {
          setState(() {
            _pageIndex -= 1;
            _introPageIndex = _lastIntroPageIndex();
          });
        },
      );
    } else {
      return widget.mainPage;
    }
  }

  Widget _buildIntroduction(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: context.theme.appTextStyle.titleLarge,
      bodyAlignment: Alignment.center,
      bodyTextStyle: context.theme.appTextStyle.bodyMedium,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) => _onBackPressed(),
      child: Stack(
        children: [
          IntroductionScreen(
            key: introKey,
            initialPage: _introPageIndex,
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
            onChange: (index) => setState(() => _introPageIndex = index),
            onDone: () async => await _onIntroEnd(),
            onSkip: () async => await _onIntroEnd(),
            skipOrBackFlex: 0,
            nextFlex: 0,
            showBackButton: true,
            rtl: Directionality.of(context) == TextDirection.rtl,
            back: const Icon(
              Icons.arrow_back,
              textDirection: TextDirection.ltr,
            ),
            next: const Icon(
              Icons.arrow_forward,
              textDirection: TextDirection.ltr,
            ),
            done: const Icon(
              Icons.arrow_forward,
              textDirection: TextDirection.ltr,
            ),
            curve: Curves.fastLinearToSlowEaseIn,
            dotsDecorator: DotsDecorator(
              size: Size(10.0, 10.0),
              color: Theme.of(context).colorScheme.surfaceDim,
              activeSize: Size(22.0, 10.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.all(
                  Radius.circular(25.0),
                ),
              ),
            ),
            safeAreaList: const [false, false, false, true],
          ),
        ],
      ),
    );
  }

  Future<void> _onBackPressed() async {
    setState(() {
      if (_introPageIndex > 0) {
        _introPageIndex -= 1;
        introKey.currentState?.previous();
      } else {
        _pageIndex -= 1;
      }
    });
  }

  Future<void> _onIntroEnd() async {
    await widget.settings.setShowOnboarding(false);
    setState(() {
      _pageIndex += 1;
      _introPageIndex = _lastIntroPageIndex();
    });
  }

  Widget _buildImage(String assetName) =>
      Image.asset('assets/$assetName', width: _imageWidth * 0.6);

  // For debugging
  //@override
  //String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
  //    "OnboardingPageState("
  //    "_pageIndex:$_pageIndex, "
  //    "_introPageIndex:$_introPageIndex, "
  //    "onboardingShown:$onboardingShown, "
  //    "acceptedTerms:$acceptedTerms)";
}
