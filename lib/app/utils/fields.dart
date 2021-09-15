import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


Widget buildHandle(BuildContext context) {
  final theme = Theme.of(context);

  return FractionallySizedBox(
    widthFactor: 0.25,
    child: Container(
      margin: const EdgeInsets.symmetric(
        vertical: 12.0,
      ),
      child: Container(
        height: 5.0,
        decoration: BoxDecoration(
          color: theme.dividerColor,
          borderRadius: const BorderRadius.all(Radius.circular(2.5)),
        ),
      ),
    ),
  );
}

Widget buildTitle(title, {
  size = 24.0,
  padding = const EdgeInsets.only(bottom: 30.0)
}) => 
Padding(
  padding: padding,
  child: Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold
        ),
      ),
    ]
  )
);

Widget buildInfoLabel(label, info, {
  labelSize = 14.0,
  infoSize = 18.0,
  padding: const EdgeInsets.only(top: 20.0)
}) => 
Padding(
  padding: padding,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      buildIdLabel(label, size: labelSize),
      SizedBox(width: 10.0,),
      buildConstrainedText(info, size: infoSize)
    ],
  )
);

Widget buildIconLabel(iconInfo, info, { 
  iconSize = 30.0,
  infoSize = 18.0,
  labelPadding = const EdgeInsets.only(bottom: 10.0)
}) => Padding(
  padding: labelPadding,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _buildIcon(iconInfo, size: iconSize),
      SizedBox(width: 10.0,),
      buildConstrainedText(info, size: infoSize)
    ],
  )
);

Icon _buildIcon(icon, {
  size = 30.0 
}) => Icon(
  icon,
  size: size,
);

Widget buildIdLabel(text, {
  size = 14.0 
}) => Text(
  text,
  textAlign: TextAlign.center,
  softWrap: true,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: size,
    fontWeight: FontWeight.bold
  ),
); 

Widget buildConstrainedText(text, {
  size = 18.0
})  => Expanded(
  flex: 1,
  child: Text(
    text,
    textAlign: TextAlign.start,
    softWrap: true,
    overflow: TextOverflow.clip,
    style: TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600
    ),
  ),
);

Widget buildEntry(context, label, hint, onSaved, validatorErrorMessage, {
  padding = const EdgeInsets.only(bottom: 10.0)
}) => Padding(
  padding: padding,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      buildTextFormField(context, label, hint, onSaved, validatorErrorMessage)
    ],
  )
);

Widget buildTextFormField(context, label, hint, onSaved, validatorErrorMessage) => TextFormField(
  autofocus: true,
  keyboardType: TextInputType.text,
  decoration: InputDecoration (
    icon: const Icon(Icons.folder),
    hintText: hint,
    labelText: label,
  ),
  validator: (value) {
    return value!.isEmpty
    ? validatorErrorMessage
    : null;
  },
  onSaved: onSaved,
);

Widget buildActionsSection(context, List<Widget> buttons, {
  padding = const EdgeInsets.only(top: 20.0)
}) => 
Padding(
  padding: padding,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    mainAxisSize: MainAxisSize.max,
    children: buttons
  )
);

Widget buildRoundedButton(BuildContext context, Icon icon, String text, Function action, {
  double buttonSize = 60.0,
  double textSize = 13.0
}) {
  return  Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      OutlinedButton(
        onPressed: () => action.call(),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle
          ),
          child: icon,
        ),
        style: OutlinedButton.styleFrom(
          shape: CircleBorder(),
          primary: Theme.of(context).primaryColor
        ),
      ),
      Divider(
        height: 5.0,
        color: Colors.transparent,
      ),
      Text(
        text,
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.w700,
        ),
      )
    ]
  );
}