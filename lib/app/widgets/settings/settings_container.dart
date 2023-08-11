import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart' as s;

import '../../cubits/cubits.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import 'about_section.dart';
import 'logs_section.dart';
import 'network_section.dart';
import 'repository_section.dart';
import 'settings_section.dart';

class SettingsContainer extends StatelessWidget {
  SettingsContainer(
    Cubits cubits, {
    required bool isBiometricsAvailable,
  }) : sections = [
          if (PlatformValues.isDesktopDevice)
            RepositorySection(
              cubits,
              isBiometricsAvailable: isBiometricsAvailable,
            ),
          NetworkSection(),
          LogsSection(cubits),
          AboutSection(cubits),
        ];

  final List<SettingsSection> sections;

  @override
  Widget build(BuildContext context) => PlatformValues.isDesktopDevice
      ? SettingsContainerDesktop(sections)
      : SettingsContainerMobile(sections);
}

class SettingsContainerMobile extends StatelessWidget {
  const SettingsContainerMobile(this.sections);

  final List<SettingsSection> sections;

  @override
  Widget build(BuildContext context) => s.SettingsList(
      platform: s.PlatformUtils.detectPlatform(context),
      sections: sections
          .map((section) => s.SettingsSection(
              title: Text(section.title,
                  style: context.theme.appTextStyle.titleMedium),
              tiles: section
                  .buildTiles(context)
                  .map((tile) => (tile is s.AbstractSettingsTile)
                      ? tile
                      : s.CustomSettingsTile(child: tile))
                  .toList()))
          .toList());
}

class SettingsContainerDesktop extends StatefulWidget {
  const SettingsContainerDesktop(this.sections);

  final List<SettingsSection> sections;

  @override
  State<SettingsContainerDesktop> createState() =>
      _SettingsContainerDesktopState();
}

class _SettingsContainerDesktopState extends State<SettingsContainerDesktop> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Flexible(
            flex: 1,
            child: ListView(
                children: widget.sections
                    .mapIndexed(
                      (index, section) => SettingsSectionTitleDesktop(
                        section: section,
                        selected: selected == index,
                        onTap: () => setState(() {
                          selected = index;
                        }),
                      ),
                    )
                    .toList()),
          ),
          Flexible(
            flex: 4,
            child: SettingsSectionDetailDesktop(
              widget.sections[selected],
            ),
          )
        ],
      );
}

class SettingsSectionTitleDesktop extends StatelessWidget {
  const SettingsSectionTitleDesktop({
    required this.section,
    required this.onTap,
    this.selected = false,
  });

  final SettingsSection section;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Row(children: [
          // Need to put the badge in a row because wrapping the Text in Badge
          // will make the text centered. Maybe there's a better solution
          // though.
          Text(section.title, style: _getStyle(context)),
          _maybeBadge(section)
        ]),
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

class SettingsSectionDetailDesktop extends StatelessWidget {
  const SettingsSectionDetailDesktop(
    this.section,
  );

  final SettingsSection section;

  @override
  Widget build(BuildContext context) => Container(
      height: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Center(child: _buildSection(context)),
      ));

  Widget _buildSection(BuildContext context) {
    final changed = section.changed;

    if (changed != null) {
      return StreamBuilder(
        stream: changed,
        builder: (context, snapshot) => Column(
          children: section.buildTiles(context),
        ),
      );
    } else {
      return Column(children: section.buildTiles(context));
    }
  }
}
