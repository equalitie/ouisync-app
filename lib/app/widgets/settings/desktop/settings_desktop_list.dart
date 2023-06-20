import 'package:flutter/widgets.dart';

import '../../../../generated/l10n.dart';
import '../../../utils/platform/platform.dart';
import '../../../widgets/notification_badge.dart';
import 'setting_desktop_item.dart';

class SettingsDesktopList extends StatelessWidget {
  SettingsDesktopList({
    required this.onItemTap,
    required notificationBadgeBuilder,
    this.selectedItem,
  }) : _notificationBadgeBuilder = notificationBadgeBuilder.copyWith(
            withErrorOnLibraryPanic: true,
            withErrorIfUpdateExists: false,
            withWarningIfNetworkDisabled: false);

  final ValueChanged<SettingItem> onItemTap;
  final SettingItem? selectedItem;
  final NotificationBadgeBuilder _notificationBadgeBuilder;

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
      children: platformSettingsItems.map<Widget>(_buildEntry).toList(),
    );
  }

  Widget _buildEntry(SettingItem settingItemEntry) {
    final item = SettingDesktopItem(
        item: settingItemEntry,
        onTap: () => onItemTap(settingItemEntry),
        selected: selectedItem?.setting == settingItemEntry.setting);

    if (settingItemEntry.setting == Setting.log) {
      return _notificationBadgeBuilder.build(item);
    } else {
      return item;
    }
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
      name: S.current.menuItemRepository,
      platform: SettingItemPlatform.all),
  SettingItem(
      setting: Setting.network,
      name: S.current.menuItemNetwork,
      platform: SettingItemPlatform.all),

  /// TODO: Get the logs sharing to work on desktop
  SettingItem(
      setting: Setting.log,
      name: S.current.menuItemLogs,
      platform: SettingItemPlatform.all),
  // Currently unnavailable:
  // SettingItem(
  //     setting: Setting.feedback,
  //     name: "Feedback",
  //     platform: SettingItemPlatform.all),
  SettingItem(
      setting: Setting.about,
      name: S.current.menuItemAbout,
      platform: SettingItemPlatform.all)
];
