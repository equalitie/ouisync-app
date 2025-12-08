import 'package:flutter/material.dart';

import 'constants.dart';

class Dimensions {
  Dimensions._();

  static const Size sizeInPageButtonMicro = Size(80.0, 50.0);
  static const Size sizeInPageButtonSmall = Size(120.0, 50.0);
  static const Size sizeInPageButtonRegular = Size(150.0, 50.0);
  static const Size sizeInPageButtonLong = Size(240.0, 50.0);

  static const Size sizeCircularProgressIndicatorSmall = Size(14.0, 14.0);
  static const Size sizeCircularProgressIndicatorAverage = Size(50.0, 50.0);
  static const double strokeCircularProgressIndicatorSmall = 2.0;

  static const double sizeIconExtraBig = 100.0;
  static const double sizeIconBig = 35.0;
  static const double sizeIconAverage = 30.0;
  static const double sizeIconSmall = 25.0;
  static const double sizeIconMicro = 20.0;
  static const double sizeIconBadge = 12.0;

  static const double sizeModalDialogWidthDesktop = 400.0;

  static const BoxConstraints sizeConstrainsDialogAction = BoxConstraints(
    minWidth: 98,
    minHeight: 40.0,
  );
  static const BoxConstraints sizeConstrainsBottomDialogAction = BoxConstraints(
    minWidth: 98,
    minHeight: 46.0,
  );

  static const EdgeInsetsDirectional paddingContents =
      EdgeInsetsDirectional.symmetric(vertical: 5.0, horizontal: 10.0);
  static const EdgeInsetsDirectional paddingDialog =
      EdgeInsetsDirectional.fromSTEB(15.0, 20.0, 15.0, 10.0);
  static const EdgeInsetsDirectional paddingBottomSheet =
      EdgeInsetsDirectional.symmetric(vertical: 10.0, horizontal: 20.0);
  static const EdgeInsetsDirectional paddingBottomSheetActions =
      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0);
  static const EdgeInsetsDirectional paddingIconButton =
      EdgeInsetsDirectional.all(2.0);
  static const EdgeInsetsDirectional paddingActionButton =
      EdgeInsetsDirectional.symmetric(vertical: 10.0, horizontal: 4.0);
  static const EdgeInsetsDirectional paddingBox = EdgeInsetsDirectional.only(
    top: 10.0,
    bottom: 10.0,
  );
  static const EdgeInsetsDirectional paddingRepositoryBar =
      EdgeInsetsDirectional.symmetric(vertical: 0.0, horizontal: 5.0);
  static const EdgeInsetsDirectional paddingRepositoryPicker =
      EdgeInsetsDirectional.symmetric(vertical: 0.0, horizontal: 2.0);
  static const EdgeInsetsDirectional paddingInPageMain =
      EdgeInsetsDirectional.symmetric(horizontal: 5.0, vertical: 0.0);
  static const EdgeInsetsDirectional paddingInPageSecondary =
      EdgeInsetsDirectional.symmetric(horizontal: 10.0, vertical: 0.0);
  static const EdgeInsetsDirectional paddingBottomSheetTitle =
      EdgeInsetsDirectional.only(bottom: 20.0);
  static const EdgeInsetsDirectional paddingFormTextField =
      EdgeInsetsDirectional.only(bottom: 10.0);
  static const EdgeInsetsDirectional paddingActionsSection =
      EdgeInsetsDirectional.only(top: 20.0);
  static const EdgeInsetsDirectional paddingActionBox =
      EdgeInsetsDirectional.all(5.0);
  static const EdgeInsetsDirectional paddingActionBoxTop =
      EdgeInsetsDirectional.only(top: 10.0, bottom: 5.0);
  static const EdgeInsetsDirectional paddingActionBoxRight =
      EdgeInsetsDirectional.only(end: 5.0, bottom: 10.0);
  static const EdgeInsetsDirectional paddingListItem =
      EdgeInsetsDirectional.fromSTEB(8.0, 10.0, 2.0, 10.0);
  static const EdgeInsetsDirectional paddingItem = EdgeInsetsDirectional.only(
    start: 10.0,
  );
  static const EdgeInsetsDirectional paddingItemBox =
      EdgeInsetsDirectional.symmetric(horizontal: 10.0, vertical: 5.0);
  static const EdgeInsetsDirectional paddingItemBoxLoose =
      EdgeInsetsDirectional.symmetric(vertical: 20.0, horizontal: 10.0);
  static const EdgeInsetsDirectional paddingGreyBox =
      EdgeInsetsDirectional.symmetric(vertical: 5.0, horizontal: 5.0);
  static const EdgeInsetsDirectional paddingLinearProgressIndicator =
      EdgeInsetsDirectional.symmetric(horizontal: 10.0, vertical: 2.0);
  static const EdgeInsetsDirectional paddingAll20 = EdgeInsetsDirectional.all(
    20.0,
  );
  static const EdgeInsetsDirectional paddingVertical10 =
      EdgeInsetsDirectional.symmetric(vertical: 10.0);
  static const EdgeInsetsDirectional paddingVertical20 =
      EdgeInsetsDirectional.symmetric(vertical: 20.0);
  static const EdgeInsetsDirectional paddingVertical40 =
      EdgeInsetsDirectional.symmetric(vertical: 40.0);
  static const EdgeInsetsDirectional paddingTop40 = EdgeInsetsDirectional.only(
    top: 40.0,
  );
  static const EdgeInsetsDirectional paddingShareLinkBox =
      EdgeInsetsDirectional.symmetric(vertical: 15.0, horizontal: 10.0);
  static const EdgeInsetsDirectional paddingPageButton =
      EdgeInsetsDirectional.symmetric(horizontal: 20.0, vertical: 20.0);
  static const EdgeInsetsDirectional paddingPageButtonIcon =
      EdgeInsetsDirectional.symmetric(horizontal: 20.0, vertical: 15.0);

  static const EdgeInsetsDirectional marginQRCodeImage =
      EdgeInsetsDirectional.all(20.0);

  static const double actionsDialogPadding = 20.0;
  static const double actionsDialogAvatarRadius = 10.0;

  static const double defaultListBottomPadding = 2.0;

  static const AlignmentGeometry alignmentIconButton =
      AlignmentDirectional.center;

  static const Widget spacingVerticalHalf = SizedBox(height: 5.0);
  static const Widget spacingVertical = SizedBox(height: 10.0);
  static const Widget spacingVerticalDouble = SizedBox(height: 20.0);
  static const Widget spacingHorizontalHalf = SizedBox(width: 5.0);
  static const Widget spacingHorizontal = SizedBox(width: 10.0);
  static const Widget spacingHorizontalDouble = SizedBox(width: 20.0);
  static const Widget spacingActionsVertical = SizedBox(height: 5.0);
  static const Widget spacingActionsHorizontal = SizedBox(width: 20.0);

  static const double borderQRCodeImage = 4.0;

  static const double radiusBig = 20.0;
  static const double radiusAverage = 16.0;
  static const double radiusSmall = 5.0;
  static const double radiusMicro = 2.0;

  static const double elevationDialogAction = 0.0;

  static const TextStyle textStyleDialogNegativeButton = TextStyle(
    color: Color.fromARGB(255, 97, 97, 97),
    fontWeight: FontWeight.w500,
  );
  static const EdgeInsetsDirectional marginDialogNegativeButton =
      EdgeInsetsDirectional.only(end: 10.0);

  static const BorderRadiusDirectional borderRadiusDialogPositiveButton =
      BorderRadiusDirectional.all(Radius.circular(5.0));
  static const EdgeInsetsDirectional marginDialogPositiveButton =
      EdgeInsetsDirectional.only(start: 10.0);

  static const RoundedRectangleBorder borderBottomSheetTop =
      RoundedRectangleBorder(borderRadius: boderRadiusBottomSheetTop);

  static const RoundedRectangleBorder borderBottomSheetAlternate =
      RoundedRectangleBorder(borderRadius: boderRadiusBottomSheetTop);

  static const BorderRadiusDirectional boderRadiusBottomSheetTop =
      BorderRadiusDirectional.only(
        topStart: Radius.circular(Dimensions.radiusAverage),
        topEnd: Radius.circular(Dimensions.radiusAverage),
        bottomStart: Radius.zero,
        bottomEnd: Radius.zero,
      );

  static const BoxDecoration decorationBottomSheetAlternative = BoxDecoration(
    borderRadius: Dimensions.boderRadiusBottomSheetTop,
    color: Constants.modalBottomSheetBackgroundColor,
  );

  static const Divider desktopSettingDivider = Divider(height: 30.0);
}
