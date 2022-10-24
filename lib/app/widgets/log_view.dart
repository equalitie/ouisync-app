import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/utils.dart';

class LogView extends StatefulWidget {
  final LogReader reader;
  final LogViewTheme theme;

  LogView(
    this.reader, {
    this.theme = defaultTheme,
  });

  @override
  State<LogView> createState() => _LogViewState(reader);
}

class _LogViewState extends State<LogView> {
  final LogReader _reader;
  final _buffer = LogBuffer();
  final _scrollController = ScrollController();
  StreamSubscription<LogMessage>? _subscription;
  var _follow = true;
  var _onScrollEnabled = true;

  _LogViewState(this._reader);

  @override
  void initState() {
    super.initState();

    _subscription = _reader.messages.listen(_onMessage);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    unawaited(_subscription?.cancel());
    _subscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SelectionArea(
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          itemBuilder: (context, index) => _buildMessage(
            context,
            _buffer[index],
          ),
          itemCount: _buffer.length,
        ),
      );

  Widget _buildMessage(BuildContext context, LogMessage message) =>
      Text.rich(TextSpan(
          children: message.content
              .map((span) => TextSpan(
                    text: span.text,
                    style: _resolveStyle(span.style),
                  ))
              .toList()));

  void _onMessage(LogMessage message) {
    setState(() {
      _buffer.add(message);
    });

    if (_follow) {
      // Scroll to bottom after widget fully rebuilds.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => unawaited(_scrollToBottom()));
    }
  }

  void _onScroll() {
    if (!_onScrollEnabled) {
      return;
    }

    var end =
        _scrollController.offset >= _scrollController.position.maxScrollExtent;

    setState(() {
      _follow = end;
    });
  }

  Future<void> _scrollToBottom() async {
    _onScrollEnabled = false;

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    _onScrollEnabled = true;
  }

  TextStyle _resolveStyle(AnsiStyle style) => TextStyle(
        color: widget.theme.resolveColor(style.foreground),
        backgroundColor: widget.theme.resolveColor(style.background),
        fontWeight: style.fontWeight,
        fontStyle: style.fontStyle,
      );
}

class LogViewTheme {
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color magenta;
  final Color cyan;
  final Color white;

  const LogViewTheme({
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.magenta,
    required this.cyan,
    required this.white,
  });

  Color? resolveColor(AnsiColor? color) {
    switch (color) {
      case AnsiColor.black:
        return black;
      case AnsiColor.red:
        return red;
      case AnsiColor.green:
        return green;
      case AnsiColor.yellow:
        return yellow;
      case AnsiColor.blue:
        return blue;
      case AnsiColor.magenta:
        return magenta;
      case AnsiColor.cyan:
        return cyan;
      case AnsiColor.white:
        return white;
      case null:
        return null;
    }
  }
}

const defaultTheme = LogViewTheme(
  black: Color.fromARGB(255, 0, 0, 0),
  red: Color.fromARGB(255, 222, 56, 43),
  green: Color.fromARGB(255, 57, 181, 74),
  yellow: Color.fromARGB(255, 255, 199, 6),
  blue: Color.fromARGB(255, 0, 111, 184),
  magenta: Color.fromARGB(255, 118, 38, 113),
  cyan: Color.fromARGB(255, 44, 181, 233),
  white: Color.fromARGB(255, 204, 204, 204),
);
