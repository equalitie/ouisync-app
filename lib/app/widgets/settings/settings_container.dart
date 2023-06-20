import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../cubits/cubits.dart';
import '../../mixins/repo_actions_mixin.dart';
import '../../utils/log.dart';
import '../../utils/platform/platform.dart';
import '../widgets.dart';

class SettingsContainer extends StatefulWidget {
  const SettingsContainer(
    this._cubits, {
    required this.isBiometricsAvailable,
  });

  final Cubits _cubits;
  final bool isBiometricsAvailable;

  @override
  State<SettingsContainer> createState() => _SettingsContainerState();
}

class _SettingsContainerState extends State<SettingsContainer>
    with AppLogger, RepositoryActionsMixin {
  SettingItem? _selected;

  @override
  void initState() {
    final defaultSetting = settingsItems
        .firstWhereOrNull((element) => element.setting == Setting.repository);
    setState(() => _selected = defaultSetting);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => PlatformValues.isMobileDevice
      ? _buildMobileLayout()
      : _buildDesktopLayout();

  Widget _buildMobileLayout() =>
      SettingsList(platform: PlatformUtils.detectPlatform(context), sections: [
        NetworkSectionMobile(),
        LogsSectionMobile(widget._cubits),
        AboutSectionMobile(repos: widget._cubits.repositories)
      ]);

  Widget _buildDesktopLayout() => Row(children: [
        Flexible(
          flex: 1,
          child: SettingsDesktopList(widget._cubits,
              onItemTap: (setting) => setState(() => _selected = setting),
              selectedItem: _selected),
        ),
        Flexible(
          flex: 4,
          child: SettingsDesktopDetail(
            widget._cubits,
            item: _selected!,
            isBiometricsAvailable: widget.isBiometricsAvailable,
          ),
        )
      ]);
}
