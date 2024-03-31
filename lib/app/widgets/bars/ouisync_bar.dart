import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/cubits.dart';
import '../../utils/constants.dart';
import 'folder_navigation_bar.dart';

class OuiSyncBar extends StatelessWidget implements PreferredSizeWidget {
  OuiSyncBar({
    required this.reposCubit,
    required this.repoPicker,
    required this.appSettingsButton,
    required this.searchButton,
    required this.repoSettingsButton,
  });

  final ReposCubit reposCubit;
  final PreferredSizeWidget repoPicker;
  final Widget appSettingsButton;
  final Widget searchButton;
  final Widget repoSettingsButton;

  final ouisyncLogo = const Image(image: AssetImage(Constants.ouisyncLogoFull));

  @override
  Widget build(BuildContext context) => reposCubit.builder((state) {
        final leadingWidget = state.showList
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ouisyncLogo,
              )
            : null;

        final cubit = state.currentRepo?.cubit;
        Widget titleWidget =
            cubit != null ? getTitleWidget(cubit) : SizedBox.shrink();

        final actionsList = <Widget>[];

        /// TODO: Implement the search before showing the button in the bar
        // if (reposCubit.repos.isNotEmpty) {
        //   actionsList.add(searchButton);
        // }

        actionsList.add(
            state.showList == false ? repoSettingsButton : appSettingsButton);

        return AppBar(
          automaticallyImplyLeading: true,
          leading: leadingWidget,
          leadingWidth: 120.0,
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
