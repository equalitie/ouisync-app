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
    this.dhtStatus = false
  });

  final RepositoriesCubit repositoriesCubit;
  final SynchronizationCubit synchronizationCubit;
  final RepositoryCallback onRepositorySelect;
  final String title;
  final Repository? currentRepository;
  final String currentRepositoryName;
  final bool dhtStatus;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _bittorrentDhtStatus = false;

  @override
  void initState() {
    super.initState();

    _bittorrentDhtStatus = widget.dhtStatus;
    print('BitTorrent DHT status: ${widget.dhtStatus}');
  }

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
          _buildRepositoriesSection(),
          const Divider(
            height: 20.0,
            thickness: 1.0,

          ),
          _buildDhtSection(),
        ],
      ),
    );
  }

  Widget _buildRepositoriesSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.iconText(
            icon: Icons.lock_rounded,
            text: 'Repository',
            textSize: 25.0,
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 20.0)
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
        ]
      )
    );
  }

  Widget _buildDhtSection() {
    return SwitchListTile(
      title: Fields.constrainedText('BitTorrent DHT'),
      value: _bittorrentDhtStatus,
      onChanged: (bool value) {
        updateDhtSetting(value);
      },
    );
  }

  Future<void> updateDhtSetting(bool enable) async {
    if (widget.currentRepository == null) {
      return;
    }

    print('${enable ? 'Enabling': 'Disabling'} BitTorrent DHT...');

    enable ? await widget.currentRepository!.enableDht()
    : await widget.currentRepository!.disableDht();
    
    final isEnabled = await widget.currentRepository!.isDhtEnabled();
    setState(() {
      _bittorrentDhtStatus = isEnabled;
    });

    String dhtStatusMessage = 'BitTorrent DHT is ${isEnabled ? 'enabled' : 'disabled'}';
    if (enable != isEnabled) {
      dhtStatusMessage = enable ? 'BitTorrent DHT could not be enabled'
      : 'Disable BitTorrent DHT failed.';
    }

    print(dhtStatusMessage);
    showToast(dhtStatusMessage);
  }
}
