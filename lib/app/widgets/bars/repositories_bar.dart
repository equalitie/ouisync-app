import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

typedef UnlockRepoFunction = Future<void> Function(
    {required String databaseId, required String repositoryName});

class RepositoriesBar extends StatelessWidget with PreferredSizeWidget {
  const RepositoriesBar(
      {required this.reposCubit,
      required this.checkForBiometricsCallback,
      required this.shareRepositoryOnTap,
      required this.unlockRepositoryOnTap});

  final ReposCubit reposCubit;
  final CheckForBiometricsFunction checkForBiometricsCallback;
  final void Function(RepoCubit) shareRepositoryOnTap;
  final UnlockRepoFunction unlockRepositoryOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(
                width: 1.0,
                color: Colors.transparent,
                style: BorderStyle.solid),
          ),
        ),
        padding: Dimensions.paddingRepositoryBar,
        child: Row(children: [
          Expanded(
              child: _Picker(
                  reposCubit: reposCubit,
                  checkForBiometricsCallback: checkForBiometricsCallback,
                  shareRepositoryOnTap: shareRepositoryOnTap,
                  unlockRepositoryOnTap: unlockRepositoryOnTap,
                  borderColor: Colors.white))
        ]));
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

  const _Picker(
      {required this.reposCubit,
      required this.checkForBiometricsCallback,
      required this.shareRepositoryOnTap,
      required this.unlockRepositoryOnTap,
      required this.borderColor});

  final ReposCubit reposCubit;
  final CheckForBiometricsFunction checkForBiometricsCallback;
  final void Function(RepoCubit) shareRepositoryOnTap;
  final UnlockRepoFunction unlockRepositoryOnTap;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => reposCubit.builder((state) {
        if (state.isLoading) {
          return Column(
            children: const [CircularProgressIndicator(color: Colors.white)],
          );
        }

        if (reposCubit.showList) {
          return _buildRepoListState(context);
        }

        final repo = state.currentRepo;
        final name = _repoName(repo);

        if (repo == null) {
          return _buildState(
            context,
            borderColor: borderColor,
            icon: Fields.accessModeIcon(null),
            iconColor: colorNoRepo,
            textColor: colorNoRepo,
            repoName: name,
          );
        }

        final icon = Fields.accessModeIcon(repo.accessMode);
        final color = repo.accessMode == AccessMode.blind
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

  Widget _buildRepoListState(BuildContext context) => Container(
      padding: Dimensions.paddingRepositoryPicker,
      child: Row(children: [
        Expanded(child: Text(S.current.titleAppTitle)),

        /// TODO: Implement search repos in list
        // Fields.actionIcon(
        //   const Icon(Icons.search_rounded),
        //   onPressed: () {},
        //   size: Dimensions.sizeIconSmall,
        //   color: Colors.white,
        // )
      ]));

  Widget _buildState(
    BuildContext context, {
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required String repoName,
  }) =>
      Row(children: [
        Fields.actionIcon(
          const Icon(Icons.arrow_back_rounded),
          onPressed: () => reposCubit.pushRepoList(true),
          size: Dimensions.sizeIconSmall,
          color: Colors.white,
        ),
        Expanded(
            child: Container(
                padding: Dimensions.paddingRepositoryPicker,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(Dimensions.radiusSmall)),
                  border:
                      Border.all(color: borderColor, style: BorderStyle.solid),
                  color: Colors.white,
                ),
                child: InkWell(
                    onTap: () async {
                      await _showRepositorySelector(context);
                    },
                    child: Row(children: [
                      IconButton(
                          icon: Icon(icon),
                          iconSize: Dimensions.sizeIconSmall,
                          color: iconColor,
                          onPressed: () async {
                            if (reposCubit.currentRepo == null) return;

                            if (reposCubit.currentRepo?.accessMode ==
                                AccessMode.blind) return;

                            final repo = reposCubit.currentRepo;

                            if (repo is OpenRepoEntry) {
                              await reposCubit
                                  .lockRepository(repo.settingsRepoEntry);
                            }
                          }),
                      Dimensions.spacingHorizontal,
                      Fields.constrainedText(repoName,
                          softWrap: false,
                          textOverflow: TextOverflow.fade,
                          color: textColor),
                      SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.keyboard_arrow_down_outlined,
                              color: iconColor))
                    ]))))
      ]);

  Future<dynamic> _showRepositorySelector(BuildContext context) =>
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: Dimensions.borderBottomSheetTop,
          builder: (context) {
            return _List(reposCubit, checkForBiometricsCallback,
                shareRepositoryOnTap, unlockRepositoryOnTap);
          });
}

class _List extends StatelessWidget with OuiSyncAppLogger {
  _List(
      ReposCubit repositories,
      CheckForBiometricsFunction checkForBiometricsCallback,
      void Function(RepoCubit) shareRepositoryOnTap,
      UnlockRepoFunction unlockRepositoryOnTap)
      : _repositories = repositories,
        _checkForBiometricsCallback = checkForBiometricsCallback,
        _shareRepositoryOnTap = shareRepositoryOnTap,
        _unlockRepositoryOnTap = unlockRepositoryOnTap;

  final ReposCubit _repositories;
  final CheckForBiometricsFunction _checkForBiometricsCallback;
  final void Function(RepoCubit) _shareRepositoryOnTap;
  final UnlockRepoFunction _unlockRepositoryOnTap;
  final ValueNotifier<bool> _lockAllEnable = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) => _repositories.builder(
        (state) {
          _enableLockAllRepos();
          final repoListMaxHeight = MediaQuery.of(context).size.height * 0.4;
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
                              final lockAll = value;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Fields.actionIcon(
                                    const Icon(Icons.lock_outline),
                                    size: Dimensions.sizeIconAverage,
                                    padding: const EdgeInsets.all(0.0),
                                    onPressed: lockAll
                                        ? () async =>
                                            await _lockAllRepositories(context)
                                        : null,
                                  ),
                                  Fields.constrainedText(
                                    S.current.labelLockAllRepos,
                                    flex: 0,
                                    fontSize: Dimensions.fontMicro,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ],
                              );
                            },
                          )
                        : const SizedBox(),
                    state.repositoryNames().isNotEmpty
                        ? ConstrainedBox(
                            constraints: BoxConstraints.loose(
                                Size.fromHeight(repoListMaxHeight)),
                            child: _buildRepositoryList(context,
                                state.repos.toList(), state.currentRepoName))
                        : Fields.placeholderWidget(
                            assetName: Constants.assetPathNothingHereYet,
                            text: S.current.messageNothingHereYet,
                            assetHeight: noReposImageHeight),
                    Dimensions.spacingActionsVertical,
                    Fields.paddedActionText(
                      S.current.iconCreateRepository.toUpperCase(),
                      textFontSize: Dimensions.fontAverage,
                      textColor: Constants.primaryColor(context),
                      textFontWeight: FontWeight.w600,
                      textOverflow: TextOverflow.ellipsis,
                      icon: Icons.add,
                      iconSize: Dimensions.sizeIconSmall,
                      iconColor: Constants.primaryColor(context),
                      onTap: () async => await createRepoDialog(context),
                    ),
                    Fields.paddedActionText(
                        S.current.iconAddExistingRepository.toUpperCase(),
                        textFontSize: Dimensions.fontAverage,
                        textColor: Constants.primaryColor(context),
                        textFontWeight: FontWeight.w600,
                        textOverflow: TextOverflow.ellipsis,
                        icon: Icons.insert_link_rounded,
                        iconSize: Dimensions.sizeIconSmall,
                        iconColor: Constants.primaryColor(context),
                        onTap: () async {
                      final shareLink = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AddRepositoryPage(reposCubit: _repositories);
                      }));

                      if (shareLink == null) return;

                      await addRepoWithTokenDialog(context,
                          shareLink: shareLink);
                    }),
                  ]));
        },
      );

  void _enableLockAllRepos() {
    _lockAllEnable.value =
        _repositories.repos.any((repo) => repo.accessMode != AccessMode.blind);
  }

  Future<void> _lockAllRepositories(BuildContext context) async {
    final unlockedRepos = _repositories.repos.where((repo) =>
        [AccessMode.read, AccessMode.write].contains(repo.accessMode));

    final lockAll = await _confirmLockAll(context,
        title: S.current.titleLockAllRepos,
        message: S.current.messageLockOpenRepos(unlockedRepos.length),
        actions: _confirmLockAllReposActions(context));

    if (!(lockAll ?? false)) {
      return;
    }

    List<Future> futures = <Future>[];

    for (final repo in unlockedRepos) {
      // TODO: What about LoadingRepoEntry? That should be locked right after
      // loading is finished.
      if (repo is OpenRepoEntry) {
        futures.add(_repositories.lockRepository(repo.settingsRepoEntry));
      }
    }

    final indicator =
        _getLinearProgressIndicator(S.current.messageLockingAllRepos);
    await Dialogs.executeFutureWithLoadingDialog(
      context,
      f: Future.wait(futures),
      widget: indicator,
    );
  }

  Future<dynamic> _confirmLockAll(BuildContext context,
      {required String title,
      required String message,
      required List<Widget> actions}) async {
    final lockAll = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ActionsDialog(
            title: title,
            body: Column(
              children: [
                Text(message),
                Fields.dialogActions(context, buttons: actions)
              ],
            ),
          );
        });
    return lockAll;
  }

  List<Widget> _confirmLockAllReposActions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false)),
        PositiveButton(
            text: S.current.actionLockCapital,
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true))
      ];

  Padding _getLinearProgressIndicator(String? text) {
    final indicator = Padding(
        padding: Dimensions.paddingLinearProgressIndicator,
        child: Column(
          children: [
            const LinearProgressIndicator(
              color: Colors.white,
            ),
            if (text != null) Dimensions.spacingVertical,
            if (text != null)
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: Dimensions.fontAverage),
              )
          ],
        ));
    return indicator;
  }

  Widget _buildRepositoryList(
    BuildContext context,
    List<RepoEntry> repos,
    String? current,
  ) =>
      ListView.builder(
          shrinkWrap: true,
          itemCount: repos.length,
          itemBuilder: (context, index) {
            final repo = repos[index];
            final repositoryName = repo.name;
            final accessMode = repo.accessMode;

            return Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Fields.actionListTile(repositoryName,
                        subtitle: accessMode.name,
                        textOverflow: TextOverflow.ellipsis,
                        textSoftWrap: false, onTap: () {
                  _repositories.setCurrentByName(repositoryName);
                  updateSettingsAndPop(context, repositoryName);
                },
                        icon: Fields.accessModeIcon(accessMode),
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
                if (repo is OpenRepoEntry)
                  _getActionByAccessMode(
                    context,
                    repo.databaseId,
                    repo.name,
                    accessMode,
                  )
              ],
            );
          });

  Row _getActionByAccessMode(
    BuildContext context,
    String databaseId,
    String repositoryName,
    AccessMode? accessMode,
  ) {
    RepoCubit? repoCubit = _repositories.get(repositoryName)?.maybeCubit;
    final modeIcon = accessMode == null
        ? Icons.error_outline_rounded
        : accessMode == AccessMode.blind
            ? Icons.lock_open_outlined
            : Icons.lock_outline;

    return Row(
      children: [
        Fields.actionIcon(Icon(modeIcon), onPressed: () async {
          if (repoCubit == null) return;
          if (accessMode == null) return;

          if (accessMode == AccessMode.blind) {
            await _unlockRepositoryOnTap(
                databaseId: databaseId, repositoryName: repositoryName);

            _lockAllEnable.value = true;
            return;
          }

          await _repositories.lockRepository(repoCubit.settingsRepoEntry);

          _enableLockAllRepos();
        }, color: Colors.black87, size: Dimensions.sizeIconAverage),
        Fields.actionIcon(const Icon(Icons.share), onPressed: () {
          if (repoCubit == null) return;

          // TODO: Should we dismiss the repo list or leave it open to return to it... ?
          // Navigator.of(context).pop();
          _shareRepositoryOnTap(repoCubit);
        }, color: Colors.black87, size: Dimensions.sizeIconAverage)
      ],
    );
  }

  Future<void> createRepoDialog(BuildContext context) async {
    final isBiometricsAvailable =
        await _isBiometricsAvailable(context) ?? false;
    final newRepo = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ScaffoldMessenger(child: Builder(builder: ((context) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                    title: S.current.titleCreateRepository,
                    body: RepositoryCreation(
                        context: context,
                        cubit: _repositories,
                        isBiometricsAvailable: isBiometricsAvailable),
                  ));
            }))));

    if (newRepo?.isEmpty ?? true) return;

    await updateSettingsAndPop(context, newRepo!);
  }

  Future<void> addRepoWithTokenDialog(BuildContext context,
      {required String shareLink}) async {
    final isBiometricsAvailable =
        await _isBiometricsAvailable(context) ?? false;
    final addedRepo = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ScaffoldMessenger(child: Builder(builder: ((context) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                      title: S.current.titleAddRepository,
                      body: RepositoryCreation(
                          context: context,
                          cubit: _repositories,
                          initialTokenValue: shareLink,
                          isBiometricsAvailable: isBiometricsAvailable)));
            }))));

    if (addedRepo?.isEmpty ?? true) return;

    await updateSettingsAndPop(context, addedRepo);
  }

  Future<bool?> _isBiometricsAvailable(BuildContext context) async =>
      Dialogs.executeFutureWithLoadingDialog(context,
          f: _checkForBiometricsCallback());

  Future<void> updateSettingsAndPop(
      BuildContext context, String repositoryName) async {
    await _repositories.settings.setDefaultRepo(repositoryName);
    Navigator.of(context).pop(repositoryName);
  }
}
