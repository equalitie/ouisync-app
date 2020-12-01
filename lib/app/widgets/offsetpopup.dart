import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OffsetPopup extends StatelessWidget {
  const OffsetPopup({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 1,
        child: Text("Create folder"),

      ),
      PopupMenuItem(
        value: 2,
        child: Text("Add file"),
      ),
      PopupMenuItem(
        value: 3,
        child: Text("Create new branch"),
      ),
      PopupMenuItem(
        value: 4,
        child: Text("Link branch"),
      ),
    ],
    icon: Container(constraints: BoxConstraints.tightForFinite(),
        height: double.infinity,
        width: double.infinity,
        decoration: ShapeDecoration(
            color: Colors.black,
            shape: StadiumBorder(
              side: BorderSide(color: Colors.white, width: 2),
            )
        ),
        child: Icon(Icons.add, color: Colors.white)
    ),
  );
}