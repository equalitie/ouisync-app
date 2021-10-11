import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../cubit/cubits.dart';
import '../../utils/utils.dart';
import '../controls.dart';

class RepositoryList extends StatelessWidget {
  const RepositoryList({
    Key? key,
    required this.context,
    required this.cubit,
    required this.current,
  }) : super(key: key);

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
                buildHandle(context),
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
          buildTitle('Your Repositories'),
          Container(
            height: 150.0,
            child: _buildRepositoryItem(localRepositories, current)
          ),
          SizedBox(height: 50.0,),
          GestureDetector(
            onTap: () => createRepoDialog(this.cubit),
            child: buildIconLabel(
              Icons.add_circle_outline_rounded,
              'Add new lockbox',
              iconSize: 30.0,
              iconColor: Colors.black,
              infoSize: 25.0,
              labelPadding: EdgeInsets.only(bottom: 10.0)
            )
          ),
        ]
      )
    );
  }

  Widget _buildRepositoryItem(List<String> repositories, String current) => ListView.builder(
    itemCount: repositories.length,
    itemBuilder: (context, index) {
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
              const Icon(
                Icons.check,
                size: 40.0,
                color:  Colors.black
              ),
              SizedBox(width: 20.0,),
              Expanded(
                flex: 1,
                child: Text(
                  repositories[index],
                  style:  TextStyle(
                    fontSize: 30.0,

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
    final repositoriesDir = await Settings.readSetting(repositoriesDirKey);
    final repositoryFiles = <String>[];
    if (io.Directory(repositoriesDir).existsSync()) {
      repositoryFiles.addAll(io.Directory(repositoriesDir).listSync().map((e) => removeParentFromPath(e.path)).toList());
      repositoryFiles.removeWhere((e) => !e.endsWith('db'));
    }

    print('Local repositories found: $repositoryFiles');
    return repositoryFiles.map((e) => e.substring(0, e.lastIndexOf('.'))).toList();
  }

  Future<void> updateDefaultRepositorySetting(repositoryName) async {
    final result = await Settings.saveSetting(currentRepositoryKey, repositoryName);
    print('Current repository updated to $repositoryName: $result');
  }

  void createRepoDialog(cubit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: 'Create Lockbox',
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
}