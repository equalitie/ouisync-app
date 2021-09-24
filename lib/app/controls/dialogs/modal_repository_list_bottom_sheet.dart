import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/utils/utils.dart';

class RepositoryList extends StatelessWidget {
  const RepositoryList({
    Key? key,
    required this.current,
  }) : super(key: key);

  final String current;

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
          buildTitle('Your Repositories'),
          _buildRepositoryItem(current),
          SizedBox(height: 50.0,),
          GestureDetector(
            onTap: () => {},
            child: buildIconLabel(
              Icons.add_circle_outline_rounded,
              'Add new repository',
              iconSize: 40.0,
              infoSize: 18.0,
              labelPadding: EdgeInsets.only(bottom: 10.0)
            )
          ),
        ]
      )
    );
  }

  Widget _buildRepositoryItem(current) => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
    child: Row(
      children: [
        const Icon(
          Icons.check,
          size: 30.0,
        ),
        SizedBox(width: 20.0,),
        Expanded(
          flex: 1,
          child: Text(
            'Default',
            style:  TextStyle(
              fontSize: 20.0,

            )
          ),
        )
      ],
    ),
  );
}