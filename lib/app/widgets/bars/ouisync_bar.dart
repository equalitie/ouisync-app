import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';

class OuiSyncBar extends StatelessWidget implements PreferredSizeWidget {
  OuiSyncBar({
    required this.reposCubit,
    required this.repoPicker,
    required this.appSettingsButton,
    required this.repoSettingsButton,
  });

  final ReposCubit reposCubit;
  final PreferredSizeWidget repoPicker;
  final Widget appSettingsButton;
  final Widget repoSettingsButton;

  @override
  Widget build(BuildContext context) => reposCubit.builder((state) {
        return AppBar(
            shadowColor: Colors.black26,
            title: repoPicker,
            // Make the `repoList` have no spacing on the horizontal axis.
            titleSpacing: 0.0,
            actions: [state.showList ? appSettingsButton : repoSettingsButton]);
      });

  @override
  Size get preferredSize =>
      Size(repoPicker.preferredSize.width, repoPicker.preferredSize.height);
}
