import 'package:flutter/material.dart';
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
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRepositoriesSection(),
            const Divider(
              height: 20.0,
              thickness: 1.0,

            ),
            LabeledSwitch(
              label: Strings.labelBitTorrentDHT,
              padding: const EdgeInsets.all(0.0),
              value: _bittorrentDhtStatus,
              onChanged: updateDhtSetting,
            )
          ],
        )
      )
    );
  }

  Widget _buildRepositoriesSection() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.iconLabel(
            icon: Icons.lock_rounded,
            text: Strings.titleRepository,
            iconSize: Dimensions.sizeIconBig,
            textAlign: TextAlign.start,
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
              Strings.actionEditRepositoryName,
              style: TextStyle(
                fontSize: Dimensions.fontAverage
              ),
            )
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              Strings.actionDeleteRepository,
              style: TextStyle(
                fontSize: Dimensions.fontAverage
              ),
            )
          ),
        ]
      
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

    String dhtStatusMessage = Strings.messageBitTorrentDHTStatus
    .replaceAll(
      Strings.replacementStatus,
      isEnabled ? 'enabled' : 'disabled'
    );
    if (enable != isEnabled) {
      dhtStatusMessage = enable ? Strings.messageBitTorrentDHTEnableFailed
      : Strings.messageBitTorrentDHTDisableFailed;
    }

    print(dhtStatusMessage);
    showToast(dhtStatusMessage);
  }
}