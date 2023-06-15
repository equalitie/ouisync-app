import 'package:flutter/material.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/utils.dart';
import 'desktop_settings.dart';

class SettingsDesktopDetail extends StatefulWidget {
  const SettingsDesktopDetail({
    required this.item,
    required this.reposCubit,
    required this.settings,
    required this.panicCounter,
    required this.isBiometricsAvailable,
  });

  final SettingItem? item;
  final ReposCubit reposCubit;
  final Settings settings;
  final StateMonitorIntCubit panicCounter;
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
          child: Center(child: _selectDetailWidget(widget.item?.setting))));

  Widget _selectDetailWidget(Setting? setting) {
    if (setting == null) {
      return LandingDesktopDetail();
    }

    switch (setting) {
      case Setting.repository:
        return RepositoryDesktopDetail(context,
            item: widget.item!,
            reposCubit: widget.reposCubit,
            isBiometricsAvailable: widget.isBiometricsAvailable);
      case Setting.network:
        return NetworkDesktopDetail();
      case Setting.log:
        return LogsDesktopDetail(
          settings: widget.settings,
          repos: widget.reposCubit,
          panicCounter: widget.panicCounter,
        );
      case Setting.feedback:
        return FeedbackDesktopDetail(item: widget.item!);
      case Setting.about:
        return AboutDesktopDetail(reposCubit: widget.reposCubit);
    }
  }
}
