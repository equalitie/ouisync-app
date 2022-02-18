import 'package:flutter/material.dart';
import 'package:ouisync_app/app/custom_widgets/dialogs/modal_rename_repository_dialog.dart';
import 'package:ouisync_app/app/models/data_models/persisted_repository.dart';

import '../cubit/cubits.dart';
import '../custom_widgets/custom_widgets.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import 'pages.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.repositoriesCubit,
    required this.onRepositorySelect,
    required this.onShareRepository,
    required this.title,
    this.dhtStatus = false, 
  });

  final RepositoriesCubit repositoriesCubit;
  final RepositoryCallback onRepositorySelect;
  final void Function() onShareRepository;
  final String title;
  final bool dhtStatus;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  RepositoriesService _repositoriesSession = RepositoriesService();

  PersistedRepository? _persistedRepository;
  bool _bittorrentDhtStatus = false;

  @override
  void initState() {
    super.initState();

    _bittorrentDhtStatus = widget.dhtStatus;
    print('BitTorrent DHT status: ${widget.dhtStatus}');

    setState(() {
      _persistedRepository = _repositoriesSession.current;
    });
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
            ),
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
          Fields.idLabel(Strings.titleRepository,
            fontSize: Dimensions.fontAverage,
            fontWeight: FontWeight.normal
          ),
          Dimensions.spacingVertical,
          Container(
            decoration: BoxDecoration(
              borderRadius : BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              color : Color.fromRGBO(33, 33, 33, 0.07999999821186066),
            ),
            child: Container(
              padding: Dimensions.paddingActionBox,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusMicro)),
                border: Border.all(
                  color: Colors.black45,
                  width: 1.0,
                  style: BorderStyle.solid
                ),
                color: Colors.grey.shade300,
              ),
              child: DropdownButton(
                isExpanded: true,
                value: _persistedRepository,
                underline: SizedBox(),
                items: _repositoriesSession.repositories.map((PersistedRepository persisted) {
                  return DropdownMenuItem(
                    value: persisted,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Fields.idLabel(
                          Strings.labelSelectRepository,
                          textAlign: TextAlign.start,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade600
                        ),
                        Dimensions.spacingVerticalHalf,
                        Row(
                          children: [
                            Fields.constrainedText(
                              persisted.name,
                              fontWeight: FontWeight.normal
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (persisted) async {
                  print('Selected: $persisted');
                  
                  setState(() {
                    _persistedRepository = persisted as PersistedRepository;
                  });
                },
              ),
            ),
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Expanded(
                child: Fields.actionText(
                  Strings.actionEdit,
                  textFontSize: Dimensions.fontAverage,
                  icon: Icons.edit,
                  iconSize: Dimensions.sizeIconSmall,
                  spacing: Dimensions.spacingHorizontalHalf,
                  onTap: () async {
                    if (!_repositoriesSession.hasCurrent) {
                      return;
                    }

                    await showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        final formKey = GlobalKey<FormState>();

                        return ActionsDialog(
                          title: Strings.messageRenameRepository,
                          body: RenameRepository(
                            context: context,
                            formKey: formKey,
                            repositoryName: _repositoriesSession.current!.name
                          ),
                        );
                      }
                    ).then((newName) {
                      if (newName?.isNotEmpty ?? false) {
                        widget.repositoriesCubit
                        .renameRepository(_repositoriesSession.current!.name, newName!);
                      }
                    });
                  }
                ),
              ),
              Expanded(
                child: Fields.actionText(
                  Strings.actionShare,
                  textFontSize: Dimensions.fontAverage,
                  icon: Icons.share,
                  iconSize: Dimensions.sizeIconSmall,
                  spacing: Dimensions.spacingHorizontalHalf,
                  onTap: widget.onShareRepository
                )
              ),
              Expanded(
                child: Fields.actionText(
                  Strings.actionDelete,
                  textFontSize: Dimensions.fontAverage,
                  textColor: Colors.red,
                  icon: Icons.delete,
                  iconSize: Dimensions.sizeIconSmall,
                  iconColor: Colors.red,
                  spacing: Dimensions.spacingHorizontalHalf,
                  onTap: () {
                    if (!_repositoriesSession.hasCurrent) {
                      return;
                    }

                    final actions = [
                      TextButton(
                        child: const Text(Strings.actionDeleteCapital),
                        onPressed: () => 
                        Navigator.of(context).pop(true),
                      ),
                      TextButton(
                        child: const Text(Strings.actionCloseCapital),
                        onPressed: () => 
                        Navigator.of(context).pop(false),
                      )
                    ];

                    Dialogs.simpleAlertDialog(
                      context: context,
                      title: Strings.titleDeleteRepository,
                      message: Strings.messageConfirmRepositoryDeletion,
                      actions: actions
                    ).then((delete) {
                      if (delete ?? false) {
                        widget.repositoriesCubit
                        .deleteRepository(_repositoriesSession.current?.name ?? '');
                      }
                    });
                  }
                )
              )
            ],
          ),
        ]
    );
  }

  Future<void> updateDhtSetting(bool enable) async {
    if (!_repositoriesSession.hasCurrent) {
      return;
    }

    print('${enable ? 'Enabling': 'Disabling'} BitTorrent DHT...');

    enable ? await _repositoriesSession.current!.repository.enableDht()
    : await _repositoriesSession.current!.repository.disableDht();
    
    final isEnabled = await _repositoriesSession.current!.repository.isDhtEnabled();
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