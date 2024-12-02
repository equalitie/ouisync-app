import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ouisync/ouisync.dart';
import 'package:settings_ui/settings_ui.dart' as s;

import '../../cubits/cubits.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import 'about_section.dart';
import 'logs_section.dart';
import 'network_section.dart';
import 'settings_section.dart';

class AppSettingsContainer extends StatefulHookWidget {
  AppSettingsContainer(
    Session session, {
    required void Function() checkForDokan,
    required ConnectivityInfo connectivityInfo,
    required LaunchAtStartupCubit launchAtStartup,
    required this.localeCubit,
    required this.mount,
    required NatDetection natDetection,
    required this.panicCounter,
    required PeerSetCubit peerSet,
    required this.powerControl,
    required ReposCubit reposCubit,
    required this.upgradeExists,
  }) : sections = [
          NetworkSection(
            session,
            connectivityInfo: connectivityInfo,
            natDetection: natDetection,
            peerSet: peerSet,
            powerControl: powerControl,
          ),
          LogsSection(
            mount: mount,
            panicCounter: panicCounter,
            powerControl: powerControl,
            reposCubit: reposCubit,
            connectivityInfo: connectivityInfo,
            natDetection: natDetection,
            checkForDokan: checkForDokan,
          ),
          AboutSection(
            session,
            localeCubit: localeCubit,
            powerControl: powerControl,
            reposCubit: reposCubit,
            connectivityInfo: connectivityInfo,
            peerSet: peerSet,
            natDetection: natDetection,
            launchAtStartup: launchAtStartup,
            upgradeExists: upgradeExists,
          ),
        ];

  final LocaleCubit localeCubit;
  final MountCubit mount;
  final StateMonitorIntCubit panicCounter;
  final PowerControl powerControl;
  final UpgradeExistsCubit upgradeExists;

  final List<SettingsSection> sections;

  @override
  State<AppSettingsContainer> createState() => _AppSettingsContainerState();
}

class _AppSettingsContainerState extends State<AppSettingsContainer>
    with AppLogger {
  @override
  Widget build(BuildContext context) {
    final selected = useState(0);

    return Row(
      children: [
        if (PlatformValues.isDesktopDevice)
          Flexible(
            flex: 1,
            child: ListView(
              children: widget.sections
                  .mapIndexed(
                    (index, section) => SettingsSectionTitleDesktop(
                      mount: widget.mount,
                      powerControl: widget.powerControl,
                      panicCounter: widget.panicCounter,
                      upgradeExists: widget.upgradeExists,
                      section: section,
                      selected: selected.value == index,
                      onTap: () {
                        selected.value = index;

                        Scrollable.ensureVisible(
                          section.key.currentContext!,
                          duration: Duration(seconds: 1),
                          curve: Curves.linearToEaseOut,
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        Flexible(
          flex: 4,
          child: NotificationListener<ScrollEndNotification>(
            child: s.SettingsList(
              platform: s.PlatformUtils.detectPlatform(context),
              sections: widget.sections
                  .map(
                    (section) => s.SettingsSection(
                      key: section.key,
                      title: Text(section.title,
                          style: context.theme.appTextStyle.titleMedium),
                      tiles: section
                          .buildTiles(context)
                          .map(
                            (tile) => (tile is s.AbstractSettingsTile)
                                ? tile
                                : s.CustomSettingsTile(child: tile),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
            onNotification: (notification) =>
                _selectFromScroll(notification, selected),
          ),
        ),
      ],
    );
  }

  bool _selectFromScroll(
      ScrollEndNotification notification, ValueNotifier<int> selected) {
    if (PlatformValues.isMobileDevice) return true;

    final networkKey = widget.sections.elementAt(0).key.currentContext;
    final logsKey = widget.sections.elementAt(1).key.currentContext;

    if (networkKey == null || logsKey == null) {
      return true;
    }

    final networkSectionSize = networkKey.size?.height ?? 0.0;
    final logsSectionSize = logsKey.size?.height ?? 0.0;

    if (networkSectionSize == 0.0 || logsSectionSize == 0.0) {
      return true;
    }

    final pixels = notification.metrics.pixels;

    final index = pixels == 0 || pixels < networkSectionSize * 0.4
        ? 0
        : pixels > 0 && pixels == notification.metrics.maxScrollExtent
            ? 2
            : pixels < (networkSectionSize + (logsSectionSize * 0.2))
                ? 1
                : 0;

    selected.value = index;

    return true;
  }
}

class SettingsSectionTitleDesktop extends StatelessWidget {
  const SettingsSectionTitleDesktop({
    required this.mount,
    required this.panicCounter,
    required this.powerControl,
    required this.upgradeExists,
    required this.section,
    required this.onTap,
    this.selected = false,
  });

  final MountCubit mount;
  final PowerControl powerControl;
  final StateMonitorIntCubit panicCounter;
  final UpgradeExistsCubit upgradeExists;

  final SettingsSection section;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Row(
          children: [
            // Need to put the badge in a row because wrapping the Text in Badge
            // will make the text centered. Maybe there's a better solution
            // though.
            Text(section.title, style: _getStyle(context)),
            _maybeBadge(section),
          ],
        ),
        selected: selected,
        onTap: onTap,
      );

  TextStyle? _getStyle(BuildContext context) {
    Color? color = Colors.black54;
    FontWeight fontWeight = FontWeight.normal;

    if (selected) {
      color = Colors.black;
      fontWeight = FontWeight.w500;
    }

    return context.theme.appTextStyle.bodyMedium
        .copyWith(color: color, fontWeight: fontWeight);
  }

  Widget _maybeBadge(SettingsSection section) {
    Color? badgeColor;

    if (section.containsErrorNotification()) {
      badgeColor = Constants.errorColor;
    } else if (section.containsWarningNotification()) {
      badgeColor = Constants.warningColor;
    }

    // If we just use `null` then we `moveRight` and `moveDownwards` doesn't work.
    final dummy = SizedBox.shrink();

    if (badgeColor == null) {
      return dummy;
    }

    return Fields.addBadge(dummy,
        color: badgeColor, moveRight: 23, moveDownwards: 23);
  }
}
