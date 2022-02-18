import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Dimensions {
  Dimensions._();

  static const double fontBig = 22.0;
  static const double fontAverage = 18.0;
  static const double fontSmall = 14.0;

  static const Size sizeInPageButtonRegular = Size(150.0, 60.0);
  static const Size sizeInPageButtonLong = Size(250.0, 60.0);

  static const Size sizeCircularProgressIndicatorSmall = Size(14.0, 14.0);
  static const Size sizeCircularProgressIndicatorAverage = Size(50.0, 50.0);
  static const double strokeCircularProgressIndicatorSmall = 2.0;

  static const double sizeIconExtraBig = 100.0;
  static const double sizeIconBig = 35.0;
  static const double sizeIconAverage = 30.0;
  static const double sizeIconSmall = 25.0;

  static const EdgeInsets paddingContents = const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0);
  static const EdgeInsets paddingDialog = const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 20.0);
  static const EdgeInsets paddingBottomSheet = const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);
  static const EdgeInsets paddingBottomSheetActions = const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0);
  static const EdgeInsets paddingIconButton = const EdgeInsets.all(2.0);
  static const EdgeInsets paddingActionButton = const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0);
  static const EdgeInsets paddingBox = const EdgeInsets.only(top: 10.0, bottom: 10.0);
  static const EdgeInsets paddingRepositoryBar = const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0);
  static const EdgeInsets paddingepositoryPicker = const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0);
  static const EdgeInsets paddingInPageMain = const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0);
  static const EdgeInsets paddingInPageSecondary = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0);
  static const EdgeInsets paddingBottomSheetTitle = const EdgeInsets.only(bottom: 20.0);
  static const EdgeInsets paddingFormTextField = const EdgeInsets.only(bottom: 10.0);
  static const EdgeInsets paddingActionsSection = const EdgeInsets.only(top: 20.0);
  static const EdgeInsets paddingActionBox = const EdgeInsets.all(5.0);

  static const double actionsDialogPadding = 20.0;
  static const double actionsDialogAvatarRadius = 10.0;

  static const double paddingBottomWithFloatingButtonExtra = 48.0;
  static const double paddingBottomWithBottomSheetExtra = 130.0;

  static const AlignmentGeometry alignmentIconButton = Alignment.center;

  static const double spacingAppBarTitle = 0.0;
  static const Widget spacingVerticalHalf = SizedBox(height: 5.0);
  static const Widget spacingVertical = SizedBox(height: 10.0);
  static const Widget spacingVerticalDouble = SizedBox(height: 20.0);
  static const Widget spacingHorizontalHalf = SizedBox(width: 5.0);
  static const Widget spacingHorizontal = SizedBox(width: 10.0);
  static const Widget spacingActionsVertical = SizedBox(height: 20.0);
  static const Widget spacingActionsHorizontal = SizedBox(width: 20.0);

  static const double radiusBig = 20.0;
  static const double radiusAverage = 16.0;
  static const double radiusSmall = 5.0;
  static const double radiusMicro = 2.0;
}