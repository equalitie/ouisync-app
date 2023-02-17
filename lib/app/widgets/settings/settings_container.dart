import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class SettingsContainer extends StatefulWidget {
  const SettingsContainer(
      {required this.reposCubit,
      required this.settings,
      required this.panicCounter,
      required this.natDetection,
      required this.isBiometricsAvailable,
      required this.onShareRepository});

  final ReposCubit reposCubit;
  final Settings settings;
  final StateMonitorIntValue panicCounter;
  final Future<NatDetection> natDetection;
  final bool isBiometricsAvailable;

  final void Function(RepoCubit) onShareRepository;

  @override
  State<SettingsContainer> createState() => _SettingsContainerState();
}

class _SettingsContainerState extends State<SettingsContainer>
    with OuiSyncAppLogger {
  SettingItem? _selected;

  @override
  Widget build(BuildContext context) => PlatformValues.isMobileDevice
      ? _buildMobileLayout()
      : _buildDesktopLayout();

  Widget _buildMobileLayout() =>
      SettingsList(platform: PlatformUtils.detectPlatform(context), sections: [
        RepositorySectionMobile(
          repos: widget.reposCubit,
          isBiometricsAvailable: widget.isBiometricsAvailable,
          onRenameRepository: _renameRepo,
          onShareRepository: widget.onShareRepository,
        ),
        NetworkSectionMobile(widget.natDetection),
        LogsSectionMobile(
            settings: widget.settings,
            repos: widget.reposCubit,
            panicCounter: widget.panicCounter,
            natDetection: widget.natDetection),
        AboutSectionMobile(repos: widget.reposCubit)
      ]);

  Widget _buildDesktopLayout() => Row(children: [
        Flexible(
            flex: 1,
            child: SettingsDesktopList(
                onItemTap: (setting) {
                  setState(() => _selected = setting);

                  loggy.app('Selected item: ${_selected?.setting.name}');
                },
                selectedItem: _selected)),
        Flexible(
            flex: 3,
            child: SettingsDesktopDetail(
                item: _selected,
                reposCubit: widget.reposCubit,
                settings: widget.settings,
                panicCounter: widget.panicCounter,
                natDetection: widget.natDetection,
                isBiometricsAvailable: widget.isBiometricsAvailable,
                onRenameRepository: _renameRepo,
                onShareRepository: widget.onShareRepository))
      ]);

  Future<void> _renameRepo(context) async {
    final currentRepo = widget.reposCubit.currentRepo;
    final repository = currentRepo is OpenRepoEntry ? currentRepo.cubit : null;

    if (repository == null) {
      return;
    }

    final newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.messageRenameRepository,
            body: RenameRepository(
                context: context,
                formKey: formKey,
                repositoryName: repository.name),
          );
        });

    if (newName == null || newName.isEmpty) {
      return;
    }

    widget.reposCubit.renameRepository(repository.name, newName);
  }
}
