import 'package:flutter/material.dart';

class ScrollableTextWidget extends StatefulWidget {
  const ScrollableTextWidget({required this.child, super.key});

  final Widget child;

  @override
  State<ScrollableTextWidget> createState() => _ScrollableTextWidgetState();
}

class _ScrollableTextWidgetState extends State<ScrollableTextWidget> {
  final _scrollController = ScrollController();

  bool showStartEllipsis = false;

  bool showEndEllipsis = false;
  bool maintainEndEllipsisSpace = false;

  final leadingEllipsisWidget = const Text('... ');
  final trailingEllipsisWidget = const Text(' ...');

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extentTotal = _scrollController.position.extentTotal;
      final viewPort = _scrollController.position.extentInside;

      final willScroll = extentTotal > viewPort;

      maintainEndEllipsisSpace = willScroll;
      setState(() => showEndEllipsis = willScroll);
    });

    _scrollController.addListener(
      () => setState(() {
        if (_scrollController.positions.isEmpty) return;

        final offset = _scrollController.offset;
        final maxScroll = _scrollController.position.maxScrollExtent;

        showStartEllipsis = offset > 1;
        showEndEllipsis = (maxScroll - offset) > 0;
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
                visible: showEndEllipsis,
                child: Container(
                  color: Colors.white,
                  child: trailingEllipsisWidget,
                ),
              ),
            ],
          ),
          Visibility(
            visible: showStartEllipsis,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.white,
                  child: leadingEllipsisWidget,
                ),
                Container(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  child: Text(' '),
                ),
              ],
            ),
          ),
        ],
      );
}
