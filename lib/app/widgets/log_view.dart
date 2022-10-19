import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/utils.dart';

class LogView extends StatefulWidget {
  final LogReader reader;

  LogView(this.reader);

  @override
  State<LogView> createState() => _LogViewState(reader);
}

class _LogViewState extends State<LogView> {
  final LogReader _reader;
  final _buffer = LogBuffer();
  final _scrollController = ScrollController();
  var _follow = true;
  var _onScrollEnabled = true;

  _LogViewState(this._reader);

  @override
  void initState() {
    super.initState();

    _reader.messages.listen(_onMessage);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _reader.close();
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
      Text.rich(TextSpan(children: message.content));

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
}
