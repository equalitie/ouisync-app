import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SyncWidget extends StatefulWidget {
  @override
  _SyncWidgetState createState() => _SyncWidgetState();
}

class _SyncWidgetState extends State<SyncWidget> {
  bool _synced = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        children: [
          _iconStatus(),
          SizedBox(width: 4.0),
          _textStatus()
        ],
      )
    );
  }

  Widget _iconStatus() {
    return _synced 
    ? const Icon(
      Icons.check_circle,
      size: 28.0,
    )
    : Container( width: 25.0,); 
  }

  Widget _textStatus() {
    return Text(
      _synced ? 'synced' : 'idle',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w900
      ),
    );
  }
}