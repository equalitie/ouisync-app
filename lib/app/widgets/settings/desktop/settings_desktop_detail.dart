import 'package:flutter/material.dart';

import 'settings_desktop_list.dart';

class SettingsDesktopDetail extends StatefulWidget {
  const SettingsDesktopDetail({required this.item});

  final SettingItem? item;

  @override
  State<SettingsDesktopDetail> createState() => _SettingsDesktopDetailState();
}

class _SettingsDesktopDetailState extends State<SettingsDesktopDetail> {
  @override
  Widget build(BuildContext context) =>
      Center(child: _selectDetailWidget(widget.item?.setting));

  Widget _selectDetailWidget(Setting? setting) {
    if (setting == null) {
      return LandingDetailDesktop();
    }

    switch (setting) {
      case Setting.repository:
        return RepositoryDetailDesktop(item: widget.item!);
      case Setting.network:
        return NetworkDetailDesktop(item: widget.item!);
      case Setting.log:
        return LogsDetailDesktop(item: widget.item!);
      case Setting.feedback:
        return FeedbackDetailDesktop(item: widget.item!);
      case Setting.about:
        return AboutDetailDesktop(item: widget.item!);
    }
  }
}

class LandingDetailDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: SizedBox.expand(child: Text('None selected')));
  }
}

class RepositoryDetailDesktop extends StatelessWidget {
  const RepositoryDetailDesktop({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.yellow, child: Text(item.name))))
    ]);
  }
}

class NetworkDetailDesktop extends StatelessWidget {
  const NetworkDetailDesktop({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.red, child: Text(item.name))))
    ]);
  }
}

class LogsDetailDesktop extends StatelessWidget {
  const LogsDetailDesktop({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.blue, child: Text(item.name))))
    ]);
  }
}

class FeedbackDetailDesktop extends StatelessWidget {
  const FeedbackDetailDesktop({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.green, child: Text(item.name))))
    ]);
  }
}

class AboutDetailDesktop extends StatelessWidget {
  const AboutDetailDesktop({required this.item});

  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.green, child: Text(item.name))))
    ]);
  }
}
