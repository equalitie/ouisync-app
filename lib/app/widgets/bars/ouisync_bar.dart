import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/cubits.dart';
import 'folder_navigation_bar.dart';

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
        final cubit = state.currentRepo?.cubit;
        Widget titleWidget =
            cubit != null ? getTitleWidget(cubit) : SizedBox.shrink();

        final actionsList = <Widget>[];

        actionsList.add(
            state.showList == false ? repoSettingsButton : appSettingsButton);

        return AppBar(
          automaticallyImplyLeading: true,
          title: titleWidget,
          // Make the `repoList` have no spacing on the horizontal axis.
          titleSpacing: 0.0,
          actions: actionsList,
        );
      });

  Widget getTitleWidget(RepoCubit? cubit) => BlocBuilder<RepoCubit, RepoState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.currentFolder.isRoot) {
          return repoPicker;
        }

        final cubit = reposCubit.currentRepo?.cubit;
        return cubit != null ? FolderNavigationBar(cubit) : SizedBox.shrink();
      });

  @override
  Size get preferredSize => Size(
        repoPicker.preferredSize.width,
        repoPicker.preferredSize.height,
      );
}
