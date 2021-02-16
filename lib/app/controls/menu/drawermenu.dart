import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget> [
        Icon(
          Icons.sync_alt_sharp,
          color: Colors.black,
          size: 80.0,
          semanticLabel: "OuiSync",
        ),
        ListTile(
            title: Text("John Doe")
        ),
        LinearProgressIndicator(
            backgroundColor: Colors.black26,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
            value: 0.8
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          child: Text(
              "500.54 MB",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
          ),
        ),
        ListTile(
          title: Text("Sync"),
          trailing: Icon(Icons.arrow_forward),
        ),
        ListTile(
          title: Text("Repos"),
          trailing: Icon(Icons.arrow_forward),
        ),
        ListTile(
          title: Text("Users"),
          trailing: Icon(Icons.arrow_forward),
        ),
        ListTile(
          title: Text("Settings"),
          trailing: Icon(Icons.arrow_forward),
        ),
        ListTile(
          title: Text("Login"),
          trailing: Icon(Icons.arrow_forward),
        ),
        ListTile(
          title: Text("About"),
          trailing: Icon(Icons.arrow_forward),
        ),
        Icon(
          Icons.adjust,
          color: Colors.black,
          size: 80.0,
          semanticLabel: "OuiSync",
        ),
      ],
    );
  }
}