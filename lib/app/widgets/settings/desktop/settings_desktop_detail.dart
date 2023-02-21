import 'package:flutter/material.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';
import '../../../utils/utils.dart';
import 'desktop_settings.dart';

class SettingsDesktopDetail extends StatefulWidget {
  const SettingsDesktopDetail(
      {required this.item,
      required this.reposCubit,
      required this.settings,
      required this.panicCounter,
      required this.natDetection,
      required this.isBiometricsAvailable,
      required this.onRenameRepository,
      required this.onShareRepository,
      required this.onRepositorySecurity,
      required this.onDeleteRepository});

  final SettingItem? item;
  final ReposCubit reposCubit;
  final Settings settings;
  final StateMonitorIntValue panicCounter;
  final Future<NatDetection> natDetection;
  final bool isBiometricsAvailable;

  final Future<void> Function(dynamic) onRenameRepository;
  final void Function(RepoCubit) onShareRepository;
  final Future<void> Function(dynamic) onRepositorySecurity;
  final Future<void> Function(dynamic context) onDeleteRepository;

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
        return RepositoryDesktopDetail(
            item: widget.item!,
            reposCubit: widget.reposCubit,
            isBiometricsAvailable: widget.isBiometricsAvailable,
            onRenameRepository: widget.onRenameRepository,
            onShareRepository: widget.onShareRepository,
            onRepositorySecurity: widget.onRepositorySecurity,
            onDeleteRepository: widget.onDeleteRepository);
      case Setting.network:
        return NetworkDesktopDetail(
            item: widget.item!, natDetection: widget.natDetection);
      case Setting.log:
        return LogsDesktopDetail(
            item: widget.item!,
            settings: widget.settings,
            reposCubit: widget.reposCubit,
            panicCounter: widget.panicCounter,
            natDetection: widget.natDetection);
      case Setting.feedback:
        return FeedbackDesktopDetail(item: widget.item!);
      case Setting.about:
        return AboutDesktopDetail(item: widget.item!);
    }
  }
}
