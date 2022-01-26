import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:styled_text/styled_text.dart';

class Fields {
  Fields._();

  static Widget _styledTextBase(
    String message,
    TextAlign textAlign,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    Color color,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsets padding
  ) {
    if (tags == null) {
      tags = Map<String, StyledTextTagBase>();
    }
    
    tags.addAll({
      'font': StyledTextTag(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          color: color
        )
      )
    });

    return Container(
      padding: padding,
      child: StyledText(
        text: '<font>$message</font>',
        textAlign: textAlign,
        tags: tags
      )
    );
  }

  static Widget inPageMainMessage(String message,
  {
    TextAlign textAlign = TextAlign.center,
    double fontSize = Dimensions.fontBig,
    FontWeight fontWeight = FontWeight.bold,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.black,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0)
  }) => _styledTextBase(
    message,
    textAlign,
    fontSize,
    fontWeight,
    fontStyle,
    color,
    tags,
    padding
  );

  static Widget inPageSecondaryMessage(String message,
  {
    TextAlign textAlign = TextAlign.center,
    double fontSize = Dimensions.fontAverage,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.black,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0)
  }) => _styledTextBase(
    message,
    textAlign,
    fontSize,
    fontWeight,
    fontStyle,
    color,
    tags,
    padding
  );

  static Widget inPageButton ({
    required void Function()? onPressed,
    required String text,
    Alignment alignment = Alignment.center,
    Size size = Dimensions.sizeInPageButtonRegular,
    double fontSize = Dimensions.fontAverage,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.white,
    bool autofocus = false,
  }) => ElevatedButton(
    onPressed: onPressed,
    child: Text(text),
    style: ButtonStyle(
      alignment: alignment,
      minimumSize: MaterialStateProperty.all<Size?>(size),
      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color
      )),
    ),
    autofocus: autofocus,
  );

  static Widget bottomSheetHandle(BuildContext context,
  {
    double widthFactor = 0.25,
    double verticalMargin = 12.0,
    double height = 5.0,
    double borderRadius = 2.5
  }) => FractionallySizedBox(
    widthFactor: widthFactor,
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: verticalMargin,
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
    ),
  );

  static Widget bottomSheetTitle(String title,
  {
    EdgeInsets padding = const EdgeInsets.only(bottom: 30.0),
    TextAlign textAlign = TextAlign.center,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    bool softWrap = true,
    double fontSize = Dimensions.fontBig,
    FontWeight fontWeight = FontWeight.bold
  }) => Padding(
    padding: padding,
    child: Column(
      children: [
        Text(
          title,
          textAlign: textAlign,
          softWrap: softWrap,
          overflow: textOverflow,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight
          ),
        ),
      ]
    )
  );

  static Widget idLabel(String text,
  {
    TextAlign textAlign = TextAlign.center,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    bool softWrap = true,
    double fontSize = Dimensions.fontSmall,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.black
  }) => Text(
    text,
    textAlign: textAlign,
    softWrap: softWrap,
    overflow: textOverflow,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color
    ),
  );

  static Widget labeledText({
    required String label,
    required String text,
    TextAlign labelTextAlign = TextAlign.center,
    TextOverflow labelTextOverflow = TextOverflow.ellipsis,
    bool labelSoftWrap = false,
    double labelFontSize = Dimensions.fontSmall,
    FontWeight labelFontWeight = FontWeight.bold,
    Color labelColor = Colors.black,
    TextAlign textAlign = TextAlign.center,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontAverage,
    FontWeight textFontWeight = FontWeight.w600,
    Color textColor = Colors.black,
    EdgeInsets padding: const EdgeInsets.only(top: 20.0),
    double space = 10.0
  }) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        idLabel(
          label,
          textAlign: labelTextAlign,
          textOverflow: labelTextOverflow,
          softWrap: labelSoftWrap,
          fontSize: labelFontSize,
          fontWeight: labelFontWeight,
          color: labelColor
        ),
        SizedBox(width: space,),
        constrainedText(text,
          textAlign: textAlign,
          textOverflow: textOverflow,
          softWrap: textSoftWrap,
          fontSize: textFontSize,
          fontWeight: textFontWeight,
          color: textColor
        )
      ],
    )
  );

  static Widget constrainedText(String text,
  {
    int flex = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool softWrap = true,
    double fontSize = Dimensions.fontAverage,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.black
  })  => Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: textOverflow,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color
      ),
    ),
  );

  static Icon _iconBase(IconData icon,
  {
    double size = 30.0,
    Color color = Colors.black,
  }) => Icon(
    icon,
    size: size,
    color: color
  );

  static Widget actionIcon({
    required IconData icon,
    required Function()? onTap,
    double size = 40.0,
    Color color = Colors.black
  }) => GestureDetector(
    child: _iconBase(
      icon,
      size: size,
      color: color
    ),
    onTap: onTap
  );

  static Widget iconText({
    required IconData icon, 
    required String text, 
    double iconSize = 30.0,
    Color iconColor = Colors.black,
    TextAlign textAlign = TextAlign.center,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.w600,
    Color textColor = Colors.black,
    EdgeInsets padding = const EdgeInsets.only(bottom: 10.0),
    double spacing = 10.0
  }) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconBase(
          icon,
          size: iconSize,
          color: iconColor
        ),
        SizedBox(width: spacing,),
        constrainedText(text,
          textAlign: textAlign,
          textOverflow: textOverflow,
          softWrap: textSoftWrap,
          fontSize: textFontSize,
          fontWeight: textFontWeight,
          color: textColor
        )
      ],
    )
  );

  static Widget _textFormFieldBase({
    required BuildContext context,
    TextEditingController? textEditingController,
    Icon? icon,
    required String label,
    required String hint,
    required Function(String?) onSaved,
    required String? Function(String? value, {String error}) validator,
    AutovalidateMode? autovalidateMode,
    bool autofocus = false,
    String? initialValue,
    bool obscureText = false,
    Function()? onTap,
    Function(String)? onChanged
  }) => TextFormField(
    controller: textEditingController,
    autovalidateMode: autovalidateMode,
    autofocus: autofocus,
    initialValue: initialValue,
    obscureText: obscureText,  
    keyboardType: TextInputType.text,
    decoration: InputDecoration (
      icon: icon,
      hintText: hint,
      labelText: label,
    ),
    validator: validator,
    onSaved: onSaved,
    onTap: onTap,
    onChanged: onChanged,
  );

  static Widget formTextField({
    required BuildContext context,
    TextEditingController? textEditingController,
    Icon? icon,
    required String label,
    required String hint,
    required Function(String?) onSaved,
    required String? Function(String? value, {String error}) validator,
    AutovalidateMode? autovalidateMode,
    bool autofocus = false,
    String? initialValue,
    bool obscureText = false,
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
        _textFormFieldBase(
          context: context,
          textEditingController: textEditingController,
          icon: icon,
          label: label,
          hint: hint,
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidateMode,
          autofocus: autofocus,
          initialValue: initialValue,
          obscureText: obscureText,
          onTap: onTap,
          onChanged: onChanged
        )
      ],
    )
  );  

  static Widget actionsSection(BuildContext context,
  {
    required List<Widget> buttons,
    EdgeInsets padding = const EdgeInsets.only(top: 20.0)
  }) =>  Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: buttons
    )
  );

  static Widget roundedButton(BuildContext context,
  {
    required IconData icon,
    required String text,
    required Function action,
    double iconSize = 30.0,
    Color iconColor = Colors.black,
    double width = 60.0,
    double height = 60.0,
    double textFontSize = Dimensions.fontSmall,
    FontWeight textFontWeight = FontWeight.w700,
    double spacing = 5.0
  }) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      OutlinedButton(
        onPressed: () => action.call(),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle
          ),
          child: _iconBase(
            icon,
            size: iconSize,
            color: iconColor
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: CircleBorder(),
          primary: Theme.of(context).primaryColor
        ),
      ),
      Divider(
        height: spacing,
        color: Colors.transparent,
      ),
      Text(
        text,
        style: TextStyle(
          fontSize: textFontSize,
          fontWeight: textFontWeight,
        ),
      )
    ]
  );

  static Container routeBar({ required Widget route })
    => Container(
      padding: EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.0,
            color: Colors.transparent,
            style: BorderStyle.solid
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(child: route),
              ],
            )
          ),
        ],
      ),
    ); 
}