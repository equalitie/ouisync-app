import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_app/generated/l10n.dart';

import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryList extends StatelessWidget {
  RepositoryList({
    required this.context,
    required this.cubit,
    required this.current,
    required this.onRepositorySelect
  });

  final BuildContext context;
  final RepositoriesCubit cubit;
  final String current;
  final RepositoryCallback onRepositorySelect;

  final RepositoriesService repositoriesSession = RepositoriesService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLocalRepositories(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: Dimensions.paddingBottomSheet,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Fields.bottomSheetHandle(context),
                Fields.bottomSheetTitle(S.current.titleRepositoriesList),
                _buildRepositoryList(snapshot.data as List<String>, current),
                Dimensions.spacingActionsVertical,
                Fields.actionText(
                  S.current.iconCreateRepository,
                  onTap: () => createRepoDialog(this.cubit),
                  icon: Icons.add_circle_outline_rounded,
                ),
                Fields.actionText(
                  S.current.iconAddRepositoryWithToken,
                  onTap: () => addRepoWithTokenDialog(this.cubit),
                  icon: Icons.insert_link_rounded,
                ),
              ]
            ),
          ); 
        }

        return Container(child: Text(S.current.messageError),);
      }
    );
  }

  Widget _buildRepositoryList(List<String> repositories, String current) => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: repositories.length,
    itemBuilder: (context, index) {

      final repositoryName = repositories[index];
      return Fields.actionText(
        repositoryName,
        onTap: () { 
          this.cubit.selectRepository(
            repositoriesSession.getNamed(repositoryName));
          
          updateDefaultRepositorySetting(repositoryName);
          Navigator.of(context).pop();
        },
        icon: repositoryName == current
        ? Icons.lock_open_rounded
        : Icons.lock,
        textColor: repositoryName == current
        ? Colors.black
        : Colors.black54,
        textFontWeight: repositoryName == current
        ? FontWeight.bold
        : FontWeight.normal,
        iconColor: repositoryName == current
        ? Colors.black
        : Colors.black54
      );
    }
  );

  Future<List<String>> loadLocalRepositories() async {
    final repositoriesDir = await Settings.readSetting(Constants.repositoriesDirKey);
    final repositoryFiles = <String>[];
    if (io.Directory(repositoriesDir).existsSync()) {
      repositoryFiles.addAll(io.Directory(repositoriesDir).listSync().map((e) => removeParentFromPath(e.path)).toList());
      repositoryFiles.removeWhere((e) => !e.endsWith('db'));
    }

    print('Local repositories found: $repositoryFiles');
    return repositoryFiles.map((e) => e.substring(0, e.lastIndexOf('.'))).toList();
  }

  Future<void> updateDefaultRepositorySetting(repositoryName) async {
    final result = await Settings.saveSetting(Constants.currentRepositoryKey, repositoryName);
    print('Current repository updated to $repositoryName: $result');
  }

  void createRepoDialog(cubit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleCreateRepository,
          body: RepositoryCreation(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    ).then((newRepository) {
      if (newRepository.isNotEmpty) { // If a repository is successfuly created, the new repository name is returned; otherwise, empty string.
        updateDefaultRepositorySetting(newRepository);
        Navigator.of(this.context).pop();
      }
    });
  }

  void addRepoWithTokenDialog(cubit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleAddRepository,
          body: AddRepositoryWithToken(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    ).then((addedRepository) {
      if (addedRepository.isNotEmpty) { // If a repository is successfuly created, the new repository name is returned; otherwise, empty string.
        updateDefaultRepositorySetting(addedRepository);
        Navigator.of(this.context).pop();
      }
    });
  }
}
