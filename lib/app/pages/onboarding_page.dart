import 'dart:io';

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'language_picker_page.dart';
import 'accept_eq_values_terms_privacy_page.dart';
import '../../generated/l10n.dart';
import '../utils/click_counter.dart';
import '../cubits/locale.dart';
import '../utils/utils.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage(
    this._localeCubit,
    this.settings, {
    required this.mainPage,
  });

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
  _OnboardingPageState(
      {required this.onboardingShown, required this.acceptedTerms});

  final introKey = GlobalKey<IntroductionScreenState>();
  IntroductionScreenState? get intro => introKey.currentState;

  int _pageIndex = 0;
  int _introPageIndex = 0;
  bool onboardingShown;
  bool acceptedTerms;

  double _imageWidth = 0;

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
          });
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
              _introPageIndex = (intro?.getPagesLength() ?? 1) - 1;
            });
          });
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
        imagePadding: EdgeInsets.zero);

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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBackPressed() async {
    setState(() {
      if (_introPageIndex > 0) {
        _introPageIndex -= 1;
        intro?.previous();
      } else {
        _pageIndex -= 1;
      }
    });
  }

  Future<void> _onIntroEnd() async {
    await widget.settings.setShowOnboarding(false);
    setState(() {
      _pageIndex += 1;
    });
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
