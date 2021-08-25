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

Widget buildTitle(title) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold
        ),
      ),
      Divider(
        height: 30,
        color: Colors.transparent
      ),
    ]
  );

  Widget buildInfoLabel(label, info) => Padding(
    padding: EdgeInsets.only(top: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        buildIdLabel(label),
        SizedBox(width: 10.0,),
        buildConstrainedText(info)
      ],
    )
  );

  Widget buildIdLabel(text) => Text(
    text,
    textAlign: TextAlign.center,
    softWrap: true,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold
    ),
  ); 

  Widget buildConstrainedText(text)  => Expanded(
    flex: 1,
    child: Text(
      text,
      textAlign: TextAlign.start,
      softWrap: true,
      overflow: TextOverflow.clip,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600
      ),
    ),
  );

  Widget buildEntry(context, label, onSaved) => Padding(
    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        buildTextFormField(context, label, 'Folder name', onSaved)
      ],
    )
  );

  Widget buildTextFormField(context, label, hint, onSaved) => TextFormField(
    autofocus: true,
    keyboardType: TextInputType.text,
    decoration: InputDecoration (
      icon: const Icon(Icons.folder),
      hintText: hint,
      labelText: label,
    ),
    validator: (value) {
      return value!.isEmpty
      ? 'Please enter a valid name (unique, no spaces, ...)'
      : null;
    },
    onSaved: onSaved,
  );

  Widget buildActionsSection(context, List<Widget> buttons) => Padding(
    padding: EdgeInsets.only(top: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: buttons
    )
  );

  Widget buildRoundedButton(BuildContext context, Icon icon, String text, Function action) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () => action.call(),
          child: Container(
            width: 60,
            height: 60,
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
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
          ),
        )
      ]
    );
  }