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

Widget buildActionIcon({icon, onTap, size = 40.0}) {
  return GestureDetector(
    child: Icon(
      icon,
      size: size,
    ),
    onTap: onTap
  );
}

Widget buildIconLabel(iconInfo, info, { 
  iconSize = 30.0,
  iconColor = Colors.black,
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
  size = 30.0,
  color = Colors.black,
}) => Icon(
  icon,
  size: size,
  color: color
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
  size = 18.0,
  textAlign = TextAlign.start,
  softWrap = true,
  overflow = TextOverflow.clip,
  fontWeight = FontWeight.w600,
  color = Colors.black
})  => Expanded(
  flex: 1,
  child: Text(
    text,
    textAlign: textAlign,
    softWrap: softWrap,
    overflow: overflow,
    style: TextStyle(
      fontSize: size,
      fontWeight: fontWeight,
      color: color
    ),
  ),
);

Widget buildEntry({
  required BuildContext context,
  TextEditingController? textEditingController,
  required String label,
  required String hint,
  required Function(String?) onSaved,
  required String? Function(String?) validator,
  AutovalidateMode? autovalidateMode,
  bool autofocus = false,
  String? initialValue,
  Function()? onTap,
  Function(String)? onChanged,
  padding = const EdgeInsets.only(bottom: 10.0),
}) => Padding(
  padding: padding,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      buildTextFormField(
        context: context,
        textEditingController: textEditingController,
        label: label,
        hint: hint,
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: autovalidateMode,
        autofocus: autofocus,
        initialValue: initialValue,
        onTap: onTap,
        onChanged: onChanged
      )
    ],
  )
);

Widget buildTextFormField({
  required BuildContext context,
  TextEditingController? textEditingController,
  required String label,
  required String hint,
  required Function(String?) onSaved,
  required String? Function(String?) validator,
  AutovalidateMode? autovalidateMode,
  bool autofocus = false,
  String? initialValue,
  Function()? onTap,
  Function(String)? onChanged
}) => TextFormField(
  controller: textEditingController,
  autovalidateMode: autovalidateMode,
  autofocus: autofocus,
  initialValue: initialValue,  
  keyboardType: TextInputType.text,
  decoration: InputDecoration (
    icon: const Icon(Icons.folder),
    hintText: hint,
    labelText: label,
  ),
  validator: validator,
  onSaved: onSaved,
  onTap: onTap,
  onChanged: onChanged,
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