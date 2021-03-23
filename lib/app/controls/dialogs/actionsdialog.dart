import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

class ActionsDialog extends StatefulWidget {
  const ActionsDialog({
    Key key,
    this.title,
    this.body,
    this.image
  });

  final String title;
  final Widget body;
  final Image image;

  @override
  _ActionsDialogState createState() => _ActionsDialogState();
}

class _ActionsDialogState extends State<ActionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(actionsDialogPadding),
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
          padding: EdgeInsets.only(left: actionsDialogPadding, top: actionsDialogAvatarRadius
              + actionsDialogPadding, right: actionsDialogPadding,bottom: actionsDialogPadding
          ),
          margin: EdgeInsets.only(top: actionsDialogAvatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(actionsDialogPadding),
            boxShadow: [
              BoxShadow(color: Colors.black,offset: Offset(0,10),
              blurRadius: 10
              ),
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              widget.body,
              // Text(widget.descriptions,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
              // SizedBox(height: 22,),
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: TextButton(
              //       onPressed: (){
              //         Navigator.of(context).pop();
              //       },
              //       child: Text(widget.text,style: TextStyle(fontSize: 18),)),
              // ),
            ],
          ),
        ),
        Positioned(
          left: actionsDialogPadding,
            right: actionsDialogPadding,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: actionsDialogAvatarRadius,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(actionsDialogAvatarRadius)),
                  child: Image.network('https://equalit.ie/wp-content/uploads/2015/04/eq-logo-site.jpg')
              ),
            ),
        ),
      ],
    );
  }
}