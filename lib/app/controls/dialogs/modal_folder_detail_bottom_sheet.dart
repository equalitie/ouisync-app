import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../utils/utils.dart';

class FolderDetail extends StatelessWidget {
  const FolderDetail({
    Key? key,
    required this.name,
    required this.path,
    required this.renameAction,
    required this.deleteAction,
  }) : super(key: key);

  final String name;
  final String path;
  final Function renameAction;
  final Function deleteAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHandle(context),
          _folderDetails(context),
        ],
      ),
    );
  }

  Widget _folderDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitle(name),
          // buildIconLabel(Icons.group_rounded, 'Share', infoSize: 20.0, labelPadding: EdgeInsets.all(0.0)),
          // buildInfoLabel('', 'Share this link with your peer', infoSize: 14.0, padding: EdgeInsets.only(bottom: 10.0)),
          // shareLinkWidget()
          GestureDetector(
            onTap: () => renameAction.call(),
            child: buildIconLabel(
              Icons.drive_file_rename_outline_rounded,
              'Rename',
              iconSize: 40.0,
              infoSize: 18.0,
              labelPadding: EdgeInsets.only(bottom: 30.0)
            ),
          ),
          GestureDetector(
            onTap: () => deleteAction.call(),
            child: buildIconLabel(
              Icons.delete_rounded,
              'Delete',
              iconSize: 40.0,
              infoSize: 18.0,
              labelPadding: EdgeInsets.only(bottom: 10.0)
            )
          ),
          Divider(
            height: 50.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          buildIconLabel(
            Icons.info_rounded,
            'Information',
            iconSize: 40.0,
            infoSize: 24.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
          syncStatus(),
        ]
      )
    );
  }

  Widget shareLinkWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 60.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            border: Border.all(
              color: Colors.yellow.shade600,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  getShareableLink(),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        ),
      ]
    );
  }

  String getShareableLink() {
    return 'ouisync.app/S2X31312';
  }

  Widget syncStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildIdLabel('Sync Status:'),
        Container(
          height: 60.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            border: Border.all(
              color: Colors.green.shade600,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.check
                ),
                Text(
                  'SYNCED',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}