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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.actionsDialogPadding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: Constants.actionsDialogPadding,
            top: Constants.actionsDialogAvatarRadius + Constants.actionsDialogPadding, 
            right: Constants.actionsDialogPadding,
            bottom: Constants.actionsDialogPadding
          ),
          margin: EdgeInsets.only(top: Constants.actionsDialogAvatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.actionsDialogPadding),
            boxShadow: [
              BoxShadow(color: Colors.black,offset: Offset(0,10),
              blurRadius: 10
              ),
            ]
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.minHeight 
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: Dimensions.fontBig,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(height: 15,),
                      widget.body!,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}