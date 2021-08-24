import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

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
          _buildHandle(context),
          _fileDetails(context),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      widthFactor: 0.25,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            color: theme.dividerColor,
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
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
          _buildTitle('File Details'),
          _buildInfoLabel(
            'Name: ',
            name
          ),
          _buildInfoLabel(
            'Location: ', 
            path
            .replaceAll(name, '')
            .trimRight()
          ),
          _buildInfoLabel(
            'Size: ',
            formattSize(size, units: true)
          ),
          Divider(
            height: 20,
            color: Colors.transparent
          ),
          _buildActionsSection(context),
        ],
      ),
    );
  }

  Widget _buildTitle(title) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold
        ),
      ),
      Divider(
        height: 30,
        color: Colors.transparent
      ),
    ]
  );

  Widget _buildInfoLabel(label, info) => Padding(
    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        _buildIdLabel(label),
        SizedBox(width: 10.0,),
        _buildConstrainedText(info)
      ],
    )
  );

  Widget _buildIdLabel(text) => Text(
    text,
    textAlign: TextAlign.center,
    softWrap: true,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold
    ),
  ); 

  Widget _buildConstrainedText(text)  => Expanded(
    flex: 1,
    child: Text(
      text,
      textAlign: TextAlign.start,
      softWrap: true,
      overflow: TextOverflow.clip,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600
      ),
    ),
  );

  Widget _buildActionsSection(context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    mainAxisSize: MainAxisSize.max,
    children: [
      _buildRoundedButton(
        context,
        const Icon(Icons.preview),
        'Preview',
        () async => await NativeChannels.previewOuiSyncFile(path, size)
      ),
      _buildRoundedButton(
        context,
        const Icon(Icons.share),
        'Share',
        () async => await NativeChannels.shareOuiSyncFile(path, size)
      )
    ],
  );

  Widget _buildRoundedButton(BuildContext context, Icon icon, String text, Function action) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () => action.call(),
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle
            ),
            child: icon,
          ),
          style: OutlinedButton.styleFrom(
            shape: CircleBorder(),
            primary: Theme.of(context).primaryColor
          ),
        ),
        Divider(
          height: 5.0,
          color: Colors.transparent,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
          ),
        )
      ]
    );
  }
}