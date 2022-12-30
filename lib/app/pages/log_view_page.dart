import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class LogViewPage extends StatefulWidget {
  final Settings settings;

  const LogViewPage({required this.settings});

  @override
  State<LogViewPage> createState() => _LogViewPageState();
}

class _LogViewPageState extends State<LogViewPage> {
  late Future<LogReader> _readerFuture;

  @override
  void initState() {
    super.initState();
    _readerFuture = LogReader.open().then((reader) {
      reader.filter = widget.settings.getLogViewFilter();
      return reader;
    });
  }

  @override
  void dispose() {
    unawaited(_readerFuture.then((reader) => reader.close()));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LogReader>(
        future: _readerFuture,
        builder: (context, snapshot) {
          final reader = snapshot.data;
          if (reader != null) {
            return _buildContent(context, reader);
          } else {
            return SizedBox.shrink();
          }
        },
      );

  Widget _buildContent(BuildContext context, LogReader reader) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.messageLogViewer),
          actions: [_buildSettingsButton(context, reader)],
          elevation: 0.0,
        ),
        body: Padding(
          padding: Dimensions.paddingContents,
          child: LogView(reader, theme: LogViewTheme.system(context)),
        ),
      );

  Widget _buildSettingsButton(BuildContext context, LogReader reader) =>
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () async => _onSettingsPressed(context, reader),
      );

  Future<void> _onSettingsPressed(
    BuildContext context,
    LogReader reader,
  ) async {
    final filter = await showDialog<LogLevel>(
      context: context,
      builder: (context) => _buildSettingsDialog(context, reader),
    );

    if (filter != null) {
      setState(() {
        reader.filter = filter;
      });

      await widget.settings.setLogViewFilter(filter);
    }
  }

  Widget _buildSettingsDialog(BuildContext context, LogReader reader) =>
      AlertDialog(
          title: Text(S.current.messageVerbosity),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LogLevel.values
                .map((value) => RadioListTile<LogLevel>(
                      title: Text(_logLevelName(value)),
                      value: value,
                      groupValue: reader.filter,
                      onChanged: (value) {
                        Navigator.pop(context, value);
                      },
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
                child: Text(S.current.actionCancel),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]);
}

String _logLevelName(LogLevel level) {
  switch (level) {
    case LogLevel.error:
      return S.current.messageLogLevelError;
    case LogLevel.warn:
      return S.current.messageLogLevelErrorWarn;
    case LogLevel.info:
      return S.current.messageLogLevelErrorWarnInfo;
    case LogLevel.debug:
      return S.current.messageLogLevelErroWarnInfoDebug;
    case LogLevel.verbose:
      return S.current.messageLogLevelAll;
  }
}
