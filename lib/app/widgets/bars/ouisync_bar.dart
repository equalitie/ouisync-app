import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/cubits.dart';
import '../../utils/constants.dart';
import '../../utils/dialogs.dart';
import '../dialogs/alert/alert.dart';
import 'folder_navigation_bar.dart';

enum AppBarWidgetType { title, action }

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

        final titleWidget = cubit != null
            ? getTitleWidget(
                cubit,
                repoPicker,
                FolderNavigationBar(cubit),
              )
            : const SizedBox.shrink();

        final settingsButton = cubit != null
            ? getSettingsAction(
                cubit,
                appSettingsButton,
                repoSettingsButton,
              )
            : appSettingsButton;

        final actionsList = <Widget>[];

        /// TODO: Implement the search before showing the button in the bar
        // if (reposCubit.repos.isNotEmpty) {
        //   actionsList.add(searchButton);
        // }

        actionsList.add(TextButton.icon(
          onPressed: () async {
            final result = await Dialogs.showSimpleAlertDialog(
              context: context,
              title: CustomAlertTitle('Title test'),
              message: Text('Message test'),
            );

            print(result);
          },
          icon: const Icon(Icons.power),
          label: Text('test'),
        ));

        actionsList.add(settingsButton);

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

  Widget getTitleWidget(
    RepoCubit cubit,
    PreferredSizeWidget repoPicker,
    FolderNavigationBar folderNavigationBar,
  ) =>
      BlocBuilder<RepoCubit, RepoState>(
        bloc: cubit,
        builder: (_, state) => _selectWidget(
          AppBarWidgetType.title,
          state.currentFolder.isRoot,
          repoPicker,
          folderNavigationBar,
        ),
      );

  Widget getSettingsAction(
    RepoCubit cubit,
    Widget appSettingsButton,
    Widget repoSettingsButton,
  ) =>
      BlocBuilder<RepoCubit, RepoState>(
        bloc: cubit,
        builder: (_, state) => _selectWidget(
          AppBarWidgetType.action,
          state.currentFolder.isRoot,
          repoSettingsButton,
          appSettingsButton,
        ),
      );

  Widget _selectWidget(
    AppBarWidgetType type,
    bool isFolderRoot,
    Widget repoListWidget,
    Widget folderContentWidget,
  ) {
    if (isFolderRoot) return repoListWidget;

    return switch (type) {
      AppBarWidgetType.title => folderContentWidget,
      AppBarWidgetType.action => const SizedBox.shrink(),
    };
  }

  @override
  Size get preferredSize => Size(
        repoPicker.preferredSize.width,
        repoPicker.preferredSize.height,
      );
}
