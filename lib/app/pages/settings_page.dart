import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

class Settings extends StatefulWidget {
  const Settings({
    required this.selectedRepository,
    required this.repository
  });

  final String selectedRepository;
  final Repository repository;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(child: Text('Settings (${widget.selectedRepository})'),),
    );
  }
}