import 'package:flutter/widgets.dart';

import '../../models/item/folderitem.dart';

class FolderDescription extends StatelessWidget {
  const FolderDescription({
    Key key,
    this.folderData,
  }) : super(key: key);

  final FolderItem folderData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getUI(),
      ),
    );
  }

  List<Widget> _getUI() {
    return [
      Text(
        folderData.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
      Text(
          folderData.path.length == 0
              ? "-"
              : folderData.path,
          style: const TextStyle(fontSize: 12.0)
      ),
    ];
  }
}