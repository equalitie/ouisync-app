import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class ActionsDialog extends StatefulWidget {
  const ActionsDialog({
    required this.title,
    this.body,
  });

  final String title;
  final Widget? body;

  @override
  _ActionsDialogState createState() => _ActionsDialogState();
}

class _ActionsDialogState extends State<ActionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: <Widget>[
          Container(
            padding: Dimensions.paddingDialog,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                blurRadius: Dimensions.radiusBig / 2
                ),
              ]
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  reverse: true,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.minHeight 
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Fields.constrainedText(
                          widget.title,
                          flex: 0,
                          fontSize: Dimensions.fontBig
                        ),
                        Dimensions.spacingVertical,
                        widget.body!,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }
}