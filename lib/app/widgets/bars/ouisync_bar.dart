import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/cubits.dart';
import '../../utils/constants.dart';
import '../widgets.dart' show DirectionalAppBar, FolderNavigationBar;

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
  Widget build(BuildContext context) => BlocBuilder<ReposCubit, ReposState>(
    bloc: reposCubit,
    builder: (context, state) {
      final leadingWidget =
          state.current == null
              ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: ouisyncLogo,
              )
              : null;

      final cubit = state.current?.cubit;

      final titleWidget =
          cubit != null
              ? getTitleWidget(cubit, repoPicker)
              : const SizedBox.shrink();

      final settingsButton =
          cubit != null
              ? getSettingsAction(
                cubit: cubit,
                appSettingsButton: appSettingsButton,
                repoSettingsButton: repoSettingsButton,
              )
              : appSettingsButton;

      final actionsList = <Widget>[];

      /// TODO: Implement the search before showing the button in the bar
      // if (reposCubit.repos.isNotEmpty) {
      //   actionsList.add(searchButton);
      // }

      actionsList.add(settingsButton);

      return DirectionalAppBar(
        leading: leadingWidget,
        title: titleWidget,
        automaticallyImplyLeading: true,
        actions: actionsList,
        // Make the `repoList` have no spacing on the horizontal axis.
        titleSpacing: 0.0,
        leadingWidth: 120.0,
      );
    },
  );

  Widget getTitleWidget(RepoCubit cubit, PreferredSizeWidget repoPicker) =>
      BlocBuilder<RepoCubit, RepoState>(
        bloc: cubit,
        builder:
            (_, state) => _selectWidget(
              type: AppBarWidgetType.title,
              isFolderRoot: state.currentFolder.isRoot,
              repoListWidget: repoPicker,
              folderContentWidget: FolderNavigationBar(cubit),
            ),
      );

  Widget getSettingsAction({
    required RepoCubit cubit,
    required Widget repoSettingsButton,
    required Widget appSettingsButton,
  }) => BlocBuilder<RepoCubit, RepoState>(
    bloc: cubit,
    builder:
        (_, state) => _selectWidget(
          type: AppBarWidgetType.action,
          isFolderRoot: state.currentFolder.isRoot,
          repoListWidget: repoSettingsButton,
          folderContentWidget: appSettingsButton,
        ),
  );

  Widget _selectWidget({
    required AppBarWidgetType type,
    required bool isFolderRoot,
    required Widget repoListWidget,
    required Widget folderContentWidget,
  }) {
    if (isFolderRoot) return repoListWidget;

    return switch (type) {
      AppBarWidgetType.title => folderContentWidget,
      AppBarWidgetType.action => const SizedBox.shrink(),
    };
  }

  @override
  Size get preferredSize =>
      Size(repoPicker.preferredSize.width, repoPicker.preferredSize.height);
}
