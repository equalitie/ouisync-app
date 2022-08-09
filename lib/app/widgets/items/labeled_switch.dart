import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({
    Key? key,
    required this.label,
    required this.value,
    this.textAlign = TextAlign.start,
    this.textOverflow = TextOverflow.clip,
    this.softWrap = true,
    this.fontSize = Dimensions.fontAverage,
    this.fontWeight = FontWeight.w400,
    this.color = Colors.black,
    required this.padding,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final bool value;
  final TextAlign textAlign;
  final TextOverflow textOverflow;
  final bool softWrap;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final EdgeInsets padding;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.start,
                overflow: TextOverflow.clip,
                softWrap: true,
                style: const TextStyle(
                  fontSize: Dimensions.fontAverage,
                  fontWeight: FontWeight.w500,
                  color: Colors.black
                )
              )
            ),
            Switch(
              value: value,
              onChanged: (bool newValue) {
                onChanged(newValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}
