import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';

class SavingFile extends StatefulWidget {
  const SavingFile({
    required this.key,
    required this.fileName,
    required this.size
  }) : super(key: key);

  final Key key;
  final String fileName;
  final double size;

  @override
  SavingFileState createState() => SavingFileState();
}

class SavingFileState extends State<SavingFile> {
  String _fileName = '';
  double _size = 0.0;

  ValueNotifier<double> _progress= ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    
    _fileName = widget.fileName;
    _size = widget.size;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Icon(
            Icons.save_alt_outlined,
            size: 40.0,
          ),
          SizedBox(width: 10.0,),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Fields.constrainedText(
                  _fileName,
                  flex: 0,
                  textOverflow: TextOverflow.ellipsis,
                  softWrap: false
                ),
                Fields.constrainedText(
                  formattSize(_size.toInt(), units: true),
                  flex: 0,
                  fontSize: Dimensions.fontSmall
                ),
                LinearProgressIndicator(
                  value: null,
                  backgroundColor: Colors.white70,
                )
              ],
            )
          ),
        ]
      )
    );
  }

  void updateProgress(double progress) {
   _progress.value = (_size - progress) / _size;
  }

}