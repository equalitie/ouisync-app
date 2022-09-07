import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_entry.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoriesBar extends StatelessWidget with PreferredSizeWidget {
  const RepositoriesBar({
    required this.reposCubit,
    required this.shareRepositoryOnTap
  });

  final ReposCubit reposCubit;
  final void Function(RepoCubit) shareRepositoryOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.transparent, style: BorderStyle.solid),
        ),
      ),
      padding: Dimensions.paddingRepositoryBar,
      child: Row(
        children: [
          Expanded(
            child: _Picker(
              reposCubit: reposCubit,
              shareRepositoryOnTap: shareRepositoryOnTap,
              borderColor: Colors.white,
            ),
          ),
          Fields.actionIcon(
            const Icon(Icons.share_outlined),
            onPressed: () {
              final current = reposCubit.currentRepo;
              if (current is! OpenRepoEntry) return;
              shareRepositoryOnTap(current.cubit);
            },
            size: Dimensions.sizeIconSmall,
            color: Colors.white,
          )
        ],
      )
    );
  }

  @override
  Size get preferredSize {
    // TODO: This value was found experimentally, can it be done programmatically?
    return const Size.fromHeight(Constants.repositoryBarHeight);
  }
}

class _Picker extends StatelessWidget {
  static const Color colorNoRepo = Colors.grey;
  static const Color colorLockedRepo = Colors.grey;
  static const Color colorUnlockedRepo = Colors.black;
  static const Color colorError = Colors.red;

  const _Picker({
    required this.reposCubit,
    required this.shareRepositoryOnTap,
    required this.borderColor,
  });

  final ReposCubit reposCubit;
  final void Function(RepoCubit) shareRepositoryOnTap;
  final Color borderColor;

  @override
  Widget build(BuildContext context)  => reposCubit.builder((state) {
    if (state.isLoading) {
      return Column(children: const [CircularProgressIndicator(color: Colors.white)],);
    }

    final repo = state.currentRepo;
    final name = _repoName(repo);
    final icon = _selectIconByAccessMode(repo?.maybeHandle?.accessMode);

    if (repo == null) {
      return _buildState(
        context,
        borderColor: borderColor,
        icon: icon,
        iconColor: colorNoRepo,
        textColor: colorNoRepo,
        repoName: name,
      );
    }

    final color = repo is! OpenRepoEntry || repo.cubit.accessMode == AccessMode.blind
        ? colorLockedRepo
        : colorUnlockedRepo;

    return _buildState(
      context,
      borderColor: borderColor,
      icon: icon,
      iconColor: colorUnlockedRepo,
      textColor: color,
      repoName: name,
    );
  });

  String _repoName(RepoEntry? repo) {
    if (repo != null) {
      return repo.name;
    } else {
      return S.current.messageNoRepos;
    }
  }

  _buildState(
    BuildContext context, {
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required String repoName,
  }) => Container(
    padding: Dimensions.paddingepositoryPicker,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
      border: Border.all(
        color: borderColor,
        style: BorderStyle.solid
      ),
      color: Colors.white,
    ),
    child: InkWell(
      onTap: () async { await _showRepositorySelector(context); },
      child: Row(
        children: [
          Icon(
            icon,
            size: Dimensions.sizeIconSmall,
            color: iconColor,
          ),
          Dimensions.spacingHorizontal,
          Fields.constrainedText(
            repoName,
            softWrap: false,
            textOverflow: TextOverflow.fade,
            color: textColor
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: iconColor
            )
          ),
        ]
      )
    )
  );

  Future<dynamic> _showRepositorySelector(BuildContext context) => showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) {
      return _List(
        reposCubit,
        shareRepositoryOnTap);
    }
  );
}

IconData _selectIconByAccessMode(AccessMode? accessMode) {
  late final IconData modeIcon;
  switch (accessMode) {
    case AccessMode.blind:
      modeIcon = Icons.visibility_off_outlined;
      break;
    case AccessMode.read:
      modeIcon = Icons.visibility_outlined;
      break;
    case AccessMode.write:
      modeIcon = Icons.edit_note_rounded;
      break;
    default:
      modeIcon = Icons.error_outline_rounded;
      break;
  }

  return modeIcon;
}

class _List extends StatelessWidget with OuiSyncAppLogger {
  _List(ReposCubit repositories, void Function(RepoCubit) shareRepositoryOnTap) : 
  _repositories = repositories,
  _shareRepositoryOnTap = shareRepositoryOnTap;

  final ReposCubit _repositories;
  final void Function(RepoCubit) _shareRepositoryOnTap;

  final ValueNotifier<bool> _lockAllEnable = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) => _repositories.builder((state) {
    enableLockAllRepos();
    final repoListMaxHeight =  MediaQuery.of(context).size.height * 0.4;
    final noReposImageHeight = MediaQuery.of(context).size.height * 0.2;
    
    return Container(
      padding: Dimensions.paddingBottomSheet, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(context),
          Fields.bottomSheetTitle(S.current.titleRepositoriesList),
          state.repositoryNames().isNotEmpty
          ? ValueListenableBuilder(
            valueListenable: _lockAllEnable,
            builder: (context, value, child) {
              final lockAll = value as bool;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Fields.constrainedText(S.current.labelLockAllRepos,
                    flex: 0,
                    fontSize: Dimensions.fontSmall,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                  Fields.actionIcon(
                    const Icon(Icons.lock_outline),
                    size: Dimensions.sizeIconAverage,
                    onPressed: lockAll ?
                    () async => await _lockAllRepositories() : null,
                  ),]);
            },)
          : const SizedBox(),
          Dimensions.spacingVertical,
          state.repositoryNames().isNotEmpty
          ? ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromHeight(repoListMaxHeight)),
            child: _buildRepositoryList(
              context,
              state.repositoryNames().toList(),
              state.currentRepoName))
          : Fields.placeholderWidget(
            assetName: Constants.assetPathNothingHereYet,
            text: S.current.messageNothingHereYet,
            assetHeight: noReposImageHeight),
          Dimensions.spacingActionsVertical,
          Fields.paddedActionText(
            S.current.iconAddRepository.toUpperCase(),
            textFontSize: Dimensions.fontAverage,
            textColor: Constants.primaryColor(context),
            textFontWeight: FontWeight.w600,
            icon: Icons.add,
            iconSize: Dimensions.sizeIconSmall,
            iconColor: Constants.primaryColor(context),
            onTap: () => createRepoDialog(context),
          ),
          Fields.paddedActionText(
            S.current.iconAddRepositoryWithToken.toUpperCase(),
            textFontSize: Dimensions.fontAverage,
            textColor: Constants.primaryColor(context),
            textFontWeight: FontWeight.w600,
            icon: Icons.insert_link_rounded,
            iconSize: Dimensions.sizeIconSmall,
            iconColor: Constants.primaryColor(context),
            onTap: () => addRepoWithTokenDialog(context),
          ),
        ]));
  },);

  void enableLockAllRepos() {
    _lockAllEnable.value =_repositories
      .repos
      .where((element) => element
        .maybeHandle?.accessMode != AccessMode.blind).isNotEmpty;
  }

  Future<void> _lockAllRepositories() async {
    final unlockedRepos = _repositories
    .repos
    .where((repo) => 
      [AccessMode.read,
      AccessMode.write]
      .contains(repo.maybeHandle?.accessMode ?? AccessMode.blind));

    await Future.forEach(unlockedRepos, (RepoEntry repo) async {
      loggy.app('locking ${repo.name}');
      await _repositories.lockRepository(repo.metaInfo);
    });
  }

  Widget _buildRepositoryList(
    BuildContext context,
    List<String> repoNames,
    String? current) => ListView.builder(
        shrinkWrap: true,
        itemCount: repoNames.length,
        itemBuilder: (context, index) {
          final repositoryName = repoNames[index];
          AccessMode? accessMode = _repositories.get(repositoryName)?.maybeHandle?.accessMode;

          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child:Fields.actionListTile(
                repositoryName,
                subtitle: accessMode?.name,
                textOverflow: TextOverflow.ellipsis,
                textSoftWrap: false,
                onTap: () {
                  _repositories.setCurrentByName(repositoryName);
                  updateSettingsAndPop(context, repositoryName);
                },
                icon: _selectIconByAccessMode(accessMode),
                iconSize: Dimensions.sizeIconAverage,
                iconColor: repositoryName == current
                  ? Colors.black87
                  : Colors.black54,
                textColor: repositoryName == current
                  ? Colors.black87
                  : Colors.black54,
                textFontWeight: repositoryName == current
                  ? FontWeight.bold
                  : FontWeight.normal,
                dense: true,
                visualDensity: VisualDensity.compact)),
              _getActionByAccessMode(
                context,
                repositoryName,
                accessMode,),
            ],);
        }
      );

  Row _getActionByAccessMode(
    BuildContext context,
    String repositoryName,
    AccessMode? accessMode,) {
      RepoCubit? repoCubit = _repositories.get(repositoryName)?.maybeCubit;
      final modeIcon = accessMode == null
      ? Icons.error_outline_rounded
      : accessMode == AccessMode.blind
      ? Icons.lock_open_outlined
      : Icons.lock_outline;

      return Row(
        children: [
          Fields.actionIcon(Icon(modeIcon),
            onPressed: () async {
              if (repoCubit == null) return;
              if (accessMode == null) return;

              if (accessMode == AccessMode.blind) {
                await Dialogs.unlockRepositoryDialog(
                  context,
                  _repositories,
                  repositoryName);

                _lockAllEnable.value = true;
                return;  
              }

              final info = repoCubit.metaInfo;
              _repositories.lockRepository(info);

              enableLockAllRepos();

            },
            color: Colors.black87,
            size: Dimensions.sizeIconAverage),
          Fields.actionIcon(const Icon(Icons.share),
            onPressed: () {
              if (repoCubit == null) return;
              
              // TODO: Should we dismiss the repo list or leave it open to return to it... ?
              // Navigator.of(context).pop();
              _shareRepositoryOnTap(repoCubit);
            },
            color: Colors.black87,
            size: Dimensions.sizeIconAverage)
        ],);
  }

  void createRepoDialog(BuildContext context) async {
    final newRepo = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleCreateRepository,
          body: RepositoryCreation(
            context: context,
            cubit: _repositories,
            formKey: formKey,
          ),
        );
      }
    );
    await updateSettingsAndPop(context, newRepo);
  }

  void addRepoWithTokenDialog(BuildContext context) async {
    final addedRepo = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleAddRepository,
          body: AddRepositoryWithToken(
            context: context,
            cubit: _repositories,
            formKey: formKey,
          ),
        );
      }
    );

    await updateSettingsAndPop(context, addedRepo);
  }

  Future<void> updateSettingsAndPop(BuildContext context, String repositoryName) async {
    await _repositories.settings.setDefaultRepo(repositoryName);
    Navigator.of(context).pop();
  }
}
