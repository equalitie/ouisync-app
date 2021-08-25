import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../utils/utils.dart';

class FileDetail extends StatelessWidget {
  const FileDetail({
    Key? key,
    required this.name,
    required this.path,
    required this.size
  }) : super(key: key);

  final String name;
  final String path;
  final int size;

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
          _fileDetails(context),
        ],
      ),
    );
  }

  Widget _fileDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitle('File Details'),
          buildInfoLabel(
            'Name: ',
            name
          ),
          buildInfoLabel(
            'Location: ', 
            path
            .replaceAll(name, '')
            .trimRight()
          ),
          buildInfoLabel(
            'Size: ',
            formattSize(size, units: true)
          ),
          buildActionsSection(context, _actions(context)),
        ],
      ),
    );
  }

  List<Widget> _actions(context) => [
    buildRoundedButton(
      context,
      const Icon(Icons.preview),
      'Preview',
      () async => await NativeChannels.previewOuiSyncFile(path, size)
    ),
    buildRoundedButton(
      context,
      const Icon(Icons.share),
      'Share',
      () async => await NativeChannels.shareOuiSyncFile(path, size)
    )
  ];
}