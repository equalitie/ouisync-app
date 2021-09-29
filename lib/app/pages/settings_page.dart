import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.selectedRepository,
    required this.repository
  });

  final String selectedRepository;
  final Repository repository;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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