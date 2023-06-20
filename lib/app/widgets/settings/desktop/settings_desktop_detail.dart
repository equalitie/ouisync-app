import 'package:flutter/material.dart';

import '../../../cubits/cubits.dart';
import 'desktop_settings.dart';

class SettingsDesktopDetail extends StatefulWidget {
  const SettingsDesktopDetail(
    this._cubits, {
    required this.item,
    required this.isBiometricsAvailable,
  });

  final Cubits _cubits;
  final SettingItem item;
  final bool isBiometricsAvailable;

  @override
  State<SettingsDesktopDetail> createState() => _SettingsDesktopDetailState();
}

class _SettingsDesktopDetailState extends State<SettingsDesktopDetail> {
  @override
  Widget build(BuildContext context) => Container(
      height: double.infinity,
      child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Center(child: _selectDetailWidget(widget.item.setting))));

  Widget _selectDetailWidget(Setting? setting) {
    if (setting == null) {
      return LandingDesktopDetail();
    }

    switch (setting) {
      case Setting.repository:
        return RepositoryDesktopDetail(context,
            item: widget.item,
            reposCubit: widget._cubits.repositories,
            isBiometricsAvailable: widget.isBiometricsAvailable);
      case Setting.network:
        return NetworkDesktopDetail();
      case Setting.log:
        return LogsDesktopDetail(widget._cubits);
      case Setting.feedback:
        return FeedbackDesktopDetail(item: widget.item);
      case Setting.about:
        return AboutDesktopDetail(reposCubit: widget._cubits.repositories);
    }
  }
}
