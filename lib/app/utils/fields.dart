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
    EdgeInsets padding = Dimensions.paddingInPageMain
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
    EdgeInsets padding = Dimensions.paddingInPageSecondary
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
    double verticalMargin = 20.0,
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
    EdgeInsets padding = Dimensions.paddingBottomSheetTitle,
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
    double labelFontSize = Dimensions.fontAverage,
    FontWeight labelFontWeight = FontWeight.bold,
    Color labelColor = Colors.black,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontAverage,
    FontWeight textFontWeight = FontWeight.w600,
    Color textColor = Colors.black,
    EdgeInsets padding: Dimensions.paddingBox,
    Widget space = Dimensions.spacingHorizontal
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
        space,
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

  static Widget iconLabel({
    required IconData icon,
    required String text,
    double iconSize = Dimensions.sizeIconBig,
    Color iconColor = Colors.black,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.w600,
    Color textColor = Colors.black,
    EdgeInsets padding: Dimensions.paddingBox,
    Widget space = Dimensions.spacingHorizontal
  }) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        _iconBase(
          icon,
          size: iconSize,
          color: iconColor
        ),
        space,
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
    double size = Dimensions.sizeIconAverage,
    Color color = Colors.black,
  }) => Icon(
    icon,
    size: size,
    color: color
  );

  static Widget actionIcon(Icon icon, {
    required void Function()? onPressed,
    double size = Dimensions.sizeIconBig,
    EdgeInsets padding = Dimensions.paddingIconButton,
    AlignmentGeometry alignment = Dimensions.alignmentIconButton,
    Color color = Colors.black,
    bool autofocus = false,
    String? tooltip,
  }) => IconButton(
    icon: icon,
    iconSize: size,
    padding: padding,
    alignment: alignment,
    color: color,
    autofocus: autofocus,
    tooltip: tooltip,
    onPressed: onPressed,
  );

  static Widget actionText(String text, {
    required void Function()? onTap,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    IconData? icon,
    double iconSize = Dimensions.sizeIconBig,
    Color iconColor = Colors.black,
    EdgeInsets padding = Dimensions.paddingActionButton,
    Widget spacing = Dimensions.spacingHorizontal
  }) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) _iconBase(
            icon,
            size: iconSize,
            color: iconColor
          ),
          spacing,
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
    FocusNode? focusNode,
    String? initialValue,
    bool obscureText = false,
    int? maxLines = 1,
    Function()? onTap,
    Function(String)? onChanged
  }) => TextFormField(
    controller: textEditingController,
    autovalidateMode: autovalidateMode,
    autofocus: autofocus,
    focusNode: focusNode,
    initialValue: initialValue,
    obscureText: obscureText,  
    maxLines: maxLines,
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
    FocusNode? focusNode,
    String? initialValue,
    bool obscureText = false,
    int? maxLines = 1,
    Function()? onTap,
    Function(String)? onChanged,
    padding = Dimensions.paddingFormTextField,
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
          focusNode: focusNode,
          initialValue: initialValue,
          obscureText: obscureText,
          maxLines: maxLines,
          onTap: onTap,
          onChanged: onChanged
        )
      ],
    )
  );  

  static Widget actionsSection(BuildContext context,
  {
    required List<Widget> buttons,
    EdgeInsets padding = Dimensions.paddingActionsSection
  }) =>  Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: buttons
    )
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