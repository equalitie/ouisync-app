import 'package:flutter/material.dart';

import '../../../utils/platform/platform.dart';
import 'desktop_settings.dart';

class SettingsDesktopDetail extends StatefulWidget {
  const SettingsDesktopDetail({required this.item});

  final SettingItem? item;

  @override
  State<SettingsDesktopDetail> createState() => _SettingsDesktopDetailState();
}

class _SettingsDesktopDetailState extends State<SettingsDesktopDetail> {
  @override
  Widget build(BuildContext context) => Container(
      height: double.infinity,
      constraints: BoxConstraints(
          maxWidth: PlatformValues.getFormFactorMaxWidth(context)),
      child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Center(child: _selectDetailWidget(widget.item?.setting))));

  Widget _selectDetailWidget(Setting? setting) {
    if (setting == null) {
      return LandingDesktopDetail();
    }

    switch (setting) {
      case Setting.repository:
        return RepositoryDesktopDetail(item: widget.item!);
      case Setting.network:
        return NetworkDesktopDetail(item: widget.item!);
      case Setting.log:
        return LogsDesktopDetail(item: widget.item!);
      case Setting.feedback:
        return FeedbackDesktopDetail(item: widget.item!);
      case Setting.about:
        return AboutDesktopDetail(item: widget.item!);
    }
  }
}
