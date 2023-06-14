import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../utils/platform/platform.dart';

class OuiSyncBar extends StatelessWidget implements PreferredSizeWidget {
  OuiSyncBar({
    required this.reposCubit,
    required this.reposBar,
    required this.appSettingsButton,
    required this.repoSettingsButton,
  });

  final ReposCubit reposCubit;
  final PreferredSizeWidget reposBar;
  final Widget appSettingsButton;
  final Widget repoSettingsButton;

  @override
  Widget build(BuildContext context) => reposCubit.builder((state) {
        /// Only on mobile we separate the repository settings from the
        /// rest of the app settings (For now at least)
        final mobilePlatforms = Platform.isAndroid || Platform.isIOS;
        final settingsActionButton = state.showList == false && mobilePlatforms
            ? repoSettingsButton
            : appSettingsButton;

        if (PlatformValues.isDesktopDevice) {
          return AppBar(
              shadowColor: Colors.black26,
              title: _desktopTitleBar(settingsActionButton));
        }

        return _mobileBar(settingsActionButton);
      });

  Widget _desktopTitleBar(Widget settingsActionButton) => WindowTitleBarBox(
          child: Row(children: [
        Expanded(child: MoveWindow(child: reposBar)),
        settingsActionButton,
        _windowButtons()
      ]));

  Widget _windowButtons() => Row(children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(),
        CloseWindowButton()
      ]);

  Widget _mobileBar(Widget settingsActionButton) => AppBar(
      shadowColor: Colors.black26,
      title: reposBar,
      // Make the `repoList` have no spacing on the horizontal axis.
      titleSpacing: 0.0,
      actions: [settingsActionButton]);

  @override
  Size get preferredSize =>
      Size(reposBar.preferredSize.width, reposBar.preferredSize.height);
}
