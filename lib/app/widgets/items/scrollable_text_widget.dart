import 'package:flutter/material.dart';

class ScrollableTextWidget extends StatefulWidget {
  const ScrollableTextWidget({
    required this.child,
    this.parentColor = Colors.white,
    this.fontSize,
    super.key,
  });

  final Widget child;
  final Color parentColor;
  final double? fontSize;

  @override
  State<ScrollableTextWidget> createState() =>
      _ScrollableTextWidgetState(parentColor, fontSize);
}

class _ScrollableTextWidgetState extends State<ScrollableTextWidget> {
  _ScrollableTextWidgetState(Color parentColor, double? fontSize)
    : _parentColor = parentColor,
      _leadingFadeWidget = Text('   ', style: TextStyle(fontSize: fontSize)),
      _trailingEllipsisWidget = Text(
        '...',
        style: TextStyle(
          backgroundColor: Colors.transparent,
          fontSize: fontSize,
        ),
      );

  final Color _parentColor;

  final Text _leadingFadeWidget;
  final Text _trailingEllipsisWidget;

  final _scrollController = ScrollController();

  bool _showStartEllipsis = false;

  bool _showEndEllipsis = false;
  bool _maintainEndEllipsisSpace = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extentTotal = _scrollController.position.extentTotal;
      final viewPort = _scrollController.position.extentInside;

      final willScroll = extentTotal > viewPort;

      _maintainEndEllipsisSpace = willScroll;
      setState(() => _showEndEllipsis = willScroll);
    });

    _scrollController.addListener(
      () => setState(() {
        if (_scrollController.positions.isEmpty) return;

        final offset = _scrollController.offset;
        final maxScroll = _scrollController.position.maxScrollExtent;

        _showStartEllipsis = offset > 1;
        _showEndEllipsis = (maxScroll - offset) > 0;
      }),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: widget.child,
            ),
          ),
          Visibility(
            visible: _showEndEllipsis,
            child: _trailingEllipsisWidget,
            maintainState: _maintainEndEllipsisSpace,
            maintainSize: _maintainEndEllipsisSpace,
            maintainAnimation: _maintainEndEllipsisSpace,
          ),
        ],
      ),
      Visibility(
        visible: _showStartEllipsis,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [_parentColor, _parentColor.withAlpha(25)],
                ),
              ),
              child: _leadingFadeWidget,
            ),
          ],
        ),
      ),
    ],
  );
}
