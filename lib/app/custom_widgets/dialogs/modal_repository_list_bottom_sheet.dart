import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../cubit/cubits.dart';
import '../../utils/utils.dart';
import '../custom_widgets.dart';

class RepositoryList extends StatelessWidget {
  const RepositoryList({
    required this.context,
    required this.cubit,
    required this.current,
  });

  final BuildContext context;
  final RepositoriesCubit cubit;
  final String current;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLocalRepositories(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.all(16.0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16.0))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Fields.bottomSheetHandle(context),
                _folderDetails(context, snapshot.data as List<String>),
              ],
            ),
          ); 
        }

        return Container(child: Text('Error'),);
      }
    );
  }

  Widget _folderDetails(BuildContext context, List<String> localRepositories) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetTitle('Your Repositories'),
          _buildRepositoryItem(localRepositories, current),
          SizedBox(height: 50.0,),
          GestureDetector(
            onTap: () => createRepoDialog(this.cubit),
            child: Fields.iconText(
              icon: Icons.add_circle_outline_rounded,
              text: 'Create a new repository',
              iconSize: 40.0,
              iconColor: Colors.black,
              textSize: 25.0,
              padding: EdgeInsets.only(bottom: 10.0)
            )
          ),
          SizedBox(height: 20.0,),
          GestureDetector(
            onTap: () => addRepoWithTokenDialog(this.cubit),
            child: Fields.iconText(
              icon: Icons.insert_link_rounded,
              text: 'Add a repository with token',
              iconSize: 40.0,
              iconColor: Colors.black,
              textSize: 25.0,
              padding: EdgeInsets.only(bottom: 10.0)
            )
          ),
        ]
      )
    );
  }

  Widget _buildRepositoryItem(List<String> repositories, String current) => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: repositories.length,
    itemBuilder: (context, index) {
      final icon = repositories[index] == current
      ? const Icon(
        Icons.lock_open_rounded,
        size: 40.0,
        color:  Colors.black
      )
      : const Icon(
        Icons.lock,
        size: 40.0,
        color:  Colors.black54
      );

      final textColor = repositories[index] == current
      ? Colors.black
      : Colors.black54;

      final fontWeight = repositories[index] == current
      ? FontWeight.bold
      : FontWeight.normal;

      return GestureDetector(
        onTap: () {
          this.cubit.openRepository(repositories[index]);
          updateDefaultRepositorySetting(repositories[index]);

          Navigator.of(this.context).pop();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
          child: Row(
            children: [
              icon,
              SizedBox(width: 10.0,),
              Expanded(
                flex: 1,
                child: Text(
                  repositories[index],
                  style:  TextStyle(
                    fontSize: 25.0,
                    color: textColor,
                    fontWeight: fontWeight
                  )
                ),
              )
            ],
          ),
        ),
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
          title: 'Create Repository',
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
          title: 'Add Repository',
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