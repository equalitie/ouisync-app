import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';

class Dimensions {
  Dimensions._();

  static const double fontBig = 20.0;
  static const double fontAverage = 16.0;
  static const double fontSmall = 14.0;
  static const double fontMicro = 12.0;

  static const Size sizeInPageButtonRegular = Size(150.0, 60.0);
  static const Size sizeInPageButtonLong = Size(250.0, 60.0);

  static const Size sizeCircularProgressIndicatorSmall = Size(14.0, 14.0);
  static const Size sizeCircularProgressIndicatorAverage = Size(50.0, 50.0);
  static const double strokeCircularProgressIndicatorSmall = 2.0;

  static const double sizeIconExtraBig = 100.0;
  static const double sizeIconBig = 35.0;
  static const double sizeIconAverage = 30.0;
  static const double sizeIconSmall = 25.0;
  static const double sizeIconMicro = 20.0;
  static const double sizeIconBadge = 12.0;

  static const EdgeInsets paddingContents = EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0);
  static const EdgeInsets paddingDialog = EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 20.0);
  static const EdgeInsets paddingBottomSheet = EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);
  static const EdgeInsets paddingBottomSheetActions = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0);
  static const EdgeInsets paddingIconButton = EdgeInsets.all(2.0);
  static const EdgeInsets paddingActionButton = EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0);
  static const EdgeInsets paddingBox = EdgeInsets.only(top: 10.0, bottom: 10.0);
  static const EdgeInsets paddingRepositoryBar = EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0);
  static const EdgeInsets paddingepositoryPicker = EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0);
  static const EdgeInsets paddingInPageMain = EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0);
  static const EdgeInsets paddingInPageSecondary = EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0);
  static const EdgeInsets paddingBottomSheetTitle = EdgeInsets.only(bottom: 20.0);
  static const EdgeInsets paddingFormTextField = EdgeInsets.only(bottom: 10.0);
  static const EdgeInsets paddingActionsSection = EdgeInsets.only(top: 20.0);
  static const EdgeInsets paddingActionBox = EdgeInsets.all(5.0);
  static const EdgeInsets paddingListItem = EdgeInsets.fromLTRB(8.0, 10.0, 2.0, 10.0) ;
  static const EdgeInsets paddingItem = EdgeInsets.only(left: 10.0);
  static const EdgeInsets paddingItemBox = EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0);
  static const EdgeInsets paddingGreyBox = EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0);
  
  static const double actionsDialogPadding = 20.0;
  static const double actionsDialogAvatarRadius = 10.0;

  static const double paddingBottomWithFloatingButtonExtra = 48.0;
  static const double paddingBottomWithBottomSheetExtra = 130.0;

  static const AlignmentGeometry alignmentIconButton = Alignment.center;

  static const Widget spacingVerticalHalf = SizedBox(height: 5.0);
  static const Widget spacingVertical = SizedBox(height: 10.0);
  static const Widget spacingVerticalDouble = SizedBox(height: 20.0);
  static const Widget spacingHorizontalHalf = SizedBox(width: 5.0);
  static const Widget spacingHorizontal = SizedBox(width: 10.0);
  static const Widget spacingHorizontalDouble = SizedBox(width: 20.0);
  static const Widget spacingActionsVertical = SizedBox(height: 20.0);
  static const Widget spacingActionsHorizontal = SizedBox(width: 20.0);

  static const double radiusBig = 20.0;
  static const double radiusAverage = 16.0;
  static const double radiusSmall = 5.0;
  static const double radiusMicro = 2.0;

  static const BoxConstraints sizeConstrainsDialogAction = BoxConstraints(minWidth: 98, minHeight: 46.0);
  static const double elevationDialogAction = 0.0;
  
  static const TextStyle textStyleDialogNegativeButton = TextStyle(color: Color.fromARGB(255, 97, 97, 97), fontWeight: FontWeight.w500);
  static const EdgeInsets marginDialogNegativeButton = EdgeInsets.only(right: 10.0);

  static const BorderRadius borderRadiusDialogPositiveButton = BorderRadius.all(Radius.circular(5.0));
  static const EdgeInsets marginDialogPositiveButton = EdgeInsets.only(left: 10.0);

  static const RoundedRectangleBorder borderBottomSheetTop = RoundedRectangleBorder(
    borderRadius: boderRadiusBottomSheetTop);

  static const RoundedRectangleBorder borderBottomSheetAlternate = RoundedRectangleBorder(
    borderRadius: boderRadiusBottomSheetTop);

  static const BorderRadius boderRadiusBottomSheetTop = BorderRadius.only(
    topLeft: Radius.circular(Dimensions.radiusAverage),
    topRight: Radius.circular(Dimensions.radiusAverage),
    bottomLeft: Radius.zero,
    bottomRight: Radius.zero
  );

  static const BoxDecoration decorationBottomSheetAlternative = BoxDecoration(
    borderRadius: Dimensions.boderRadiusBottomSheetTop,
    color: Constants.modalBottomSheetBackgroundColor
  );
}
