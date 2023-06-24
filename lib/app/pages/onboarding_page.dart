import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../app.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.ouisyncAppHome});

  final OuiSyncApp ouisyncAppHome;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final onboardingKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
        bodyTextStyle: bodyStyle,
        bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        pageColor: Colors.white,
        imagePadding: EdgeInsets.zero);

    return IntroductionScreen(
        key: onboardingKey,
        globalBackgroundColor: Colors.white,
        allowImplicitScrolling: true,
        autoScrollDuration: 3000,
        infiniteAutoScroll: true,
        globalHeader: Align(
            alignment: Alignment.topRight,
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: _buildImage('eq_logo.png', 100)))),
        globalFooter: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
                child: const Text('Let\'s go right away!',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                onPressed: () => _onIntroEnd(context))),
        pages: [
          PageViewModel(
              title: 'Send and receive files securely',
              body: 'All files and folders added to OuiSync are securely '
                  'encrypted by default, both in transit and at rest.',
              image: _buildImage('01_onboarding_send_receive_files.png'),
              decoration: pageDecoration),
          PageViewModel(
              title:
                  'Set permissions to collaborate, broadcast, or simply store',
              body: 'Repositories can be shared as read-write, read-only, or '
                  'blind (you store files for others, but cannot access them)',
              image: _buildImage('02_onboarding_permissions_collaborate.png'),
              decoration: pageDecoration),
          PageViewModel(
              title: 'Access files from multiple devices',
              body: 'Share files to all of your devices or with others and '
                  'build your own secure cloud!',
              image: _buildImage('03_onboarding_access_multiple_devices.png'),
              decoration: pageDecoration)
        ],
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: false,
        //rtl: true, // Display as right-to-left
        back: const Icon(Icons.arrow_back),
        skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Color(0xFFBDBDBD),
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))),
        dotsContainerDecorator: const ShapeDecoration(
            color: Colors.black87,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)))));
  }

  void _onIntroEnd(context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => widget.ouisyncAppHome));
  }

  // Widget _buildFullscreenImage() {
  //   return Image.asset('assets/fullscreen.jpg',
  //       fit: BoxFit.cover,
  //       height: double.infinity,
  //       width: double.infinity,
  //       alignment: Alignment.center);
  // }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }
}
