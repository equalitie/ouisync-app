import 'package:flutter/widgets.dart';

import '../../../utils/platform/platform.dart';
import 'setting_desktop_item.dart';

class SettingsDesktopList extends StatelessWidget {
  SettingsDesktopList({required this.onItemTap, this.selectedItem});

  final ValueChanged<SettingItem> onItemTap;
  final SettingItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    final currentPlatform = PlatformValues.isMobileDevice
        ? SettingItemPlatform.mobile
        : SettingItemPlatform.desktop;

    final platformSettingsItems = settingsItems.where((settingItemEntry) => [
          SettingItemPlatform.all,
          currentPlatform
        ].contains(settingItemEntry.platform));

    return ListView(
      children: platformSettingsItems
          .map<Widget>((settingItemEntry) => SettingDesktopItem(
              item: settingItemEntry,
              onTap: () => onItemTap(settingItemEntry),
              selected: selectedItem?.setting == settingItemEntry.setting))
          .toList(),
    );
  }
}

enum SettingItemPlatform { mobile, desktop, all }

enum Setting { repository, network, log, feedback, about }

class SettingItem {
  SettingItem(
      {required this.setting,
      required this.name,
      this.description,
      required this.platform});

  final Setting setting;
  final String name;
  final String? description;
  final SettingItemPlatform platform;
}

final settingsItems = [
  SettingItem(
      setting: Setting.repository,
      name: "Repository",
      platform: SettingItemPlatform.all),
  SettingItem(
      setting: Setting.network,
      name: "Network",
      platform: SettingItemPlatform.all),
  SettingItem(
      setting: Setting.log, name: "Logs", platform: SettingItemPlatform.all),
  SettingItem(
      setting: Setting.feedback,
      name: "Feedback",
      platform: SettingItemPlatform.all),
  SettingItem(
      setting: Setting.about, name: "About", platform: SettingItemPlatform.all)
];
