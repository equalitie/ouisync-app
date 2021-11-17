import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../cubit/cubits.dart';
import '../custom_widgets/custom_widgets.dart';
import '../utils/utils.dart';
import 'pages.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.repositoriesCubit,
    required this.synchronizationCubit,
    required this.onRepositorySelect,
    required this.title,
    this.currentRepository,
    this.currentRepositoryName = '',
  });

  final RepositoriesCubit repositoriesCubit;
  final SynchronizationCubit synchronizationCubit;
  final RepositoryCallback onRepositorySelect;
  final String title;
  final Repository? currentRepository;
  final String currentRepositoryName;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _settingBody()
    );
  }

  Widget _settingBody() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildIconLabel(
            Icons.lock_rounded,
            'Repository',
            infoSize: 25.0,
            labelPadding: EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 20.0)
            ),
          RepositoryPicker(
            repositoriesCubit: widget.repositoriesCubit,
            synchronizationCubit: widget.synchronizationCubit,
            onRepositorySelect: widget.onRepositorySelect,
            borderColor: Colors.black38,
            currentRepository: widget.currentRepository,
            currentRepositoryName: widget.currentRepositoryName,
          ),
          SizedBox(height: 20.0,),
          TextButton(
            onPressed: () {},
            child: Text(
              'Edit name',
              style: TextStyle(
                fontSize: 18.0
              ),
            )
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Delete repository',
              style: TextStyle(
                fontSize: 18.0
              ),
            )
          ),
        ],
      ),
    );
  }
}
