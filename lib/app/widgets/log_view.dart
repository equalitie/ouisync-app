import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/utils.dart';

class LogView extends StatefulWidget {
  final LogReader reader;
  final LogViewTheme theme;

  LogView(this.reader, {super.key, this.theme = LogViewTheme.light});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final _buffer = LogBuffer();
  StreamSubscription<LogMessage>? _subscription;

  final _scrollController = ScrollController();
  var _follow = true;
  var _onScrollEnabled = true;

  _LogViewState();

  @override
  void initState() {
    super.initState();

    _subscribe();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unsubscribe();

    super.dispose();
  }

  @override
  void didUpdateWidget(LogView old) {
    super.didUpdateWidget(old);

    if (old.reader != widget.reader) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemBuilder: (context, index) => _buildMessage(context, _buffer[index]),
        itemCount: _buffer.length,
      ),
    );
  }

  Widget _buildMessage(BuildContext context, LogMessage message) => Text.rich(
    TextSpan(
      children:
          message.content
              .map(
                (span) =>
                    TextSpan(text: span.text, style: _resolveStyle(span.style)),
              )
              .toList(),
    ),
  );

  TextStyle _resolveStyle(AnsiStyle style) => TextStyle(
    color: widget.theme.resolveColor(style.foreground),
    backgroundColor: widget.theme.resolveColor(style.background),
    fontWeight: style.fontWeight,
    fontStyle: style.fontStyle,
    fontFamilyFallback: [
      "Monaco",
      "Consolas",
      "Droid Sans Mono",
      "Courier New",
      "Courier",
    ],
  );

  void _onMessage(LogMessage message) {
    setState(() {
      _buffer.add(message);
    });

    if (_follow) {
      // Scroll to bottom after widget fully rebuilds.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_scrollToBottom()),
      );
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
    if (!mounted) {
      return;
    }

    _onScrollEnabled = false;

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    _onScrollEnabled = true;
  }

  void _subscribe() {
    _subscription = widget.reader.messages.listen(_onMessage);
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
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

  static const light = LogViewTheme(
    black: Color.fromARGB(255, 0, 0, 0),
    red: Color.fromARGB(255, 222, 56, 43),
    green: Color.fromARGB(255, 57, 181, 74),
    yellow: Color.fromARGB(255, 255, 199, 6),
    blue: Color.fromARGB(255, 0, 111, 184),
    magenta: Color.fromARGB(255, 118, 38, 113),
    cyan: Color.fromARGB(255, 44, 181, 233),
    white: Color.fromARGB(255, 204, 204, 204),
  );

  static const dark = LogViewTheme(
    black: Color.fromARGB(255, 204, 204, 204),
    red: Color.fromARGB(255, 222, 56, 43),
    green: Color.fromARGB(255, 57, 181, 74),
    yellow: Color.fromARGB(255, 255, 199, 6),
    blue: Color.fromARGB(255, 0, 111, 184),
    magenta: Color.fromARGB(255, 118, 38, 113),
    cyan: Color.fromARGB(255, 44, 181, 233),
    white: Color.fromARGB(255, 0, 0, 0),
  );

  static LogViewTheme system(
    BuildContext context, {
    light = light,
    dark = dark,
  }) {
    final theme = Theme.of(context);

    switch (theme.brightness) {
      case Brightness.light:
        return light;
      case Brightness.dark:
        return dark;
    }
  }

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
