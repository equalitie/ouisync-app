import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../cubits/cubits.dart';
import '../../mixins/repo_actions_mixin.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SettingsContainer extends StatefulWidget {
  const SettingsContainer({
    required this.reposCubit,
    required this.settings,
    required this.panicCounter,
    required this.isBiometricsAvailable,
  });

  final ReposCubit reposCubit;
  final Settings settings;
  final StateMonitorIntCubit panicCounter;
  final bool isBiometricsAvailable;

  @override
  State<SettingsContainer> createState() => _SettingsContainerState();
}

class _SettingsContainerState extends State<SettingsContainer>
    with RepositoryActionsMixin, OuiSyncAppLogger {
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
        LogsSectionMobile(
          settings: widget.settings,
          repos: widget.reposCubit,
          panicCounter: widget.panicCounter,
        ),
        AboutSectionMobile(repos: widget.reposCubit)
      ]);

  Widget _buildDesktopLayout() => Row(children: [
        Flexible(
          flex: 1,
          child: SettingsDesktopList(
              onItemTap: (setting) => setState(() => _selected = setting),
              selectedItem: _selected),
        ),
        Flexible(
          flex: 4,
          child: SettingsDesktopDetail(
            item: _selected,
            reposCubit: widget.reposCubit,
            settings: widget.settings,
            panicCounter: widget.panicCounter,
            isBiometricsAvailable: widget.isBiometricsAvailable,
          ),
        )
      ]);
}
