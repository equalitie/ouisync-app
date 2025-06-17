import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class InfoBuble extends StatelessWidget {
  const InfoBuble({
    required this.child,
    required this.title,
    required this.description,
    this.bgColor = Colors.white,
    this.bubbleWidth = 300.0,
    this.bubblePadding = 32.0,
    this.bubbleTipWidth = 22.0,
    this.bubbleTipHeight = 12.0,
  });

  final Widget child;

  final String title;
  final List<TextSpan> description;
  final Color bgColor;
  final double bubbleWidth;
  final double bubblePadding;
  final double bubbleTipWidth;
  final double bubbleTipHeight;

  @override
  Widget build(BuildContext context) {
    final focusableWidgetKey = GlobalKey();

    return Wrap(
      spacing: 1.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        child,
        GestureDetector(
          onTap:
              () => _showInfoBubble(
                title,
                description,
                focusableWidgetKey,
                bgColor,
              ),
          child: Icon(
            Icons.info_outline_rounded,
            key: focusableWidgetKey,
            size: Dimensions.sizeIconMicro,
          ),
        ),
      ],
    );
  }

  void _showInfoBubble(
    String title,
    List<TextSpan> description,
    GlobalKey focusableWidgetKey,
    Color bgColor, {
    double bubbleWidth = 300.0,
    double bubblePadding = 32.0,
    double bubbleTipWidth = 22.0,
    double bubbleTipHeight = 12.0,
  }) => showDialog(
    context: focusableWidgetKey.currentContext!,
    builder:
        (BuildContext context) => _InfoBubbleDialog(
          focusableWidgetKey: focusableWidgetKey,
          title: title,
          description: description,
          bgColor: bgColor,
          bubbleWidth: bubbleWidth,
          bubblePadding: bubblePadding,
          bubbleTipWidth: bubbleTipWidth,
          bubbleTipHeight: bubbleTipHeight,
        ),
  );
}

class _InfoBubbleDialog extends StatefulWidget {
  const _InfoBubbleDialog({
    required this.focusableWidgetKey,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.bubbleWidth,
    required this.bubblePadding,
    required this.bubbleTipHeight,
    required this.bubbleTipWidth,
  });

  final GlobalKey focusableWidgetKey;

  final String title;
  final List<TextSpan> description;

  final Color bgColor;

  final double bubbleWidth;
  final double bubblePadding;
  final double bubbleTipHeight;
  final double bubbleTipWidth;

  @override
  State<_InfoBubbleDialog> createState() => _InfoBubbleDialogState();
}

class _InfoBubbleDialogState extends State<_InfoBubbleDialog> {
  double get screenWidth =>
      MediaQuery.of(widget.focusableWidgetKey.currentContext!).size.width;
  double get screenHeight =>
      MediaQuery.of(widget.focusableWidgetKey.currentContext!).size.height;

  double? leftPosition;
  double? rightPosition;
  double? topPosition;
  double? bottomPosition;

  Rect? widgetConstraints;

  double bubbleTipLeftPadding = 0.0;
  late double bubbleTipHalfWidth;

  Timer? animationTimer;

  var animationTopHeight = 0.0;
  var animationBottomHeight = 0.0;
  final animationDuration = const Duration(milliseconds: 900);
  final animationVerticalMotionHeight = 4.0;

  late bool showBubbleAboveWidget;
  late bool showBubbleLeftWidget;

  // animateBubble() {
  //   if (animationTopHeight == 0) {
  //     animationTopHeight = animationVerticalMotionHeight;
  //     animationBottomHeight = animationVerticalMotionHeight;
  //   } else {
  //     animationTopHeight = 0;
  //     animationBottomHeight = 0;
  //   }
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    initBubblePosition();

    ///Initialize animation
    // Future.delayed(const Duration(milliseconds: 100)).then(
    //   (value) => animateBubble(),
    // );
    // animationTimer = Timer.periodic(animationDuration, (_) => animateBubble());
  }

  initBubblePosition() {
    widgetConstraints = widget.focusableWidgetKey.globalPaintBounds;
    var bubbleTipHalfWidth = widget.bubbleTipWidth / 2;
    var screenYCenter = screenHeight / 2;
    var screenXCenter = screenWidth / 2;
    var widgetLeft = widgetConstraints?.left ?? 0;
    var widgetTop = widgetConstraints?.top ?? 0;
    var widgetRight = widgetConstraints?.right ?? 0;
    var widgetCenterX = widgetLeft + ((widgetRight - widgetLeft) / 2);

    showBubbleAboveWidget = widgetTop > screenYCenter;
    showBubbleLeftWidget = widgetLeft < screenXCenter;

    if (showBubbleLeftWidget) {
      leftPosition = widget.bubblePadding;
    } else {
      rightPosition = widget.bubblePadding;
    }

    if (showBubbleAboveWidget) {
      bottomPosition = screenHeight - widgetTop;
    } else {
      topPosition = widgetTop;
    }

    if (showBubbleLeftWidget) {
      bubbleTipLeftPadding =
          widgetCenterX - widget.bubblePadding - bubbleTipHalfWidth;

      ///If widget is very close to screen.
      if (bubbleTipLeftPadding < 0) bubbleTipLeftPadding = 0;
    } else {
      var widgetLeft = screenWidth - widget.bubbleWidth - widget.bubblePadding;
      bubbleTipLeftPadding = widgetCenterX - widgetLeft - bubbleTipHalfWidth;

      ///If widget is very close to screen.
      if (bubbleTipLeftPadding > widget.bubbleWidth - widget.bubbleTipWidth) {
        bubbleTipLeftPadding = widget.bubbleWidth - widget.bubbleTipWidth;
      }
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      AnimatedPositioned(
        duration: animationDuration,
        left: leftPosition,
        right: rightPosition,
        top: topPosition,
        bottom: bottomPosition,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (!showBubbleAboveWidget)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(left: bubbleTipLeftPadding),
            //     child: CustomPaint(
            //       painter: TrianglePainter(
            //         strokeColor: widget.bgColor,
            //         strokeWidth: 10,
            //         paintingStyle: PaintingStyle.fill,
            //       ),
            //       child: SizedBox(
            //         height: widget.bubbleTipHeight,
            //         width: widget.bubbleTipWidth,
            //       ),
            //     ),
            //   ),
            Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsetsDirectional.all(12),
                width: widget.bubbleWidth,
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadiusDirectional.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: context.theme.appTextStyle.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: context.theme.appTextStyle.bodySmall.copyWith(
                          color: Colors.black87,
                        ),
                        children: widget.description,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // if (showBubbleAboveWidget)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(left: bubbleTipLeftPadding),
            //     child: RotatedBox(
            //       quarterTurns: 2,
            //       child: CustomPaint(
            //         painter: TrianglePainter(
            //           strokeColor: widget.bgColor,
            //           strokeWidth: 10,
            //           paintingStyle: PaintingStyle.fill,
            //         ),
            //         child: SizedBox(
            //           height: widget.bubbleTipHeight,
            //           width: widget.bubbleTipWidth,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    ],
  );

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(x / 2, 0)
      ..lineTo(x, y)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
