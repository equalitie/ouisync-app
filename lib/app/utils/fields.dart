import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:styled_text/styled_text.dart';

import 'utils.dart';

class Fields {
  Fields._();

  static Widget addBadge(BuildContext context, Widget child, { bool show = true}) {
    return Badge(
      showBadge: show,
      ignorePointer: true,
      badgeContent: SizedBox(width: 10, height: 10),
      //badgeContent: Icon(
      //  Icons.warning_amber,
      //  size: Dimensions.sizeIconBadge,
      //  color: Theme.of(context).colorScheme.primary
      //),
      badgeColor: Colors.red,
      position: BadgePosition(bottom: 12, end: 10),
      padding: const EdgeInsets.all(0.0),
      shape: BadgeShape.circle,
      child: child
    );
  }

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
    tags ??= <String, StyledTextTagBase>{};

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
    FontWeight fontWeight = FontWeight.w500,
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
    FontWeight labelFontWeight = FontWeight.w500,
    Color labelColor = Colors.black,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontAverage,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    EdgeInsets padding = Dimensions.paddingBox,
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

  static Widget labeledButton({
    required String label,
    required String buttonText,
    required Function() onPressed,
  }) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        idLabel(
          label,
          textAlign: TextAlign.start,
          fontSize: Dimensions.fontAverage,
        ),
        OutlinedButton(
          child: Text(buttonText),
          onPressed: onPressed,
        )
      ],
  );

  static Widget iconLabel({
    required IconData icon,
    required String text,
    double iconSize = Dimensions.sizeIconAverage,
    Color iconColor = Colors.black,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    EdgeInsets padding = Dimensions.paddingBox,
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
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    int maxLines = 1
  })  => Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: textOverflow,
      maxLines: maxLines,
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
    double size = Dimensions.sizeIconAverage,
    EdgeInsets padding = Dimensions.paddingIconButton,
    AlignmentGeometry alignment = Dimensions.alignmentIconButton,
    Color color = Colors.black,
    bool autofocus = false,
    String? tooltip,
    BoxConstraints? constraints,
  }) => IconButton(
    icon: icon,
    iconSize: size,
    padding: padding,
    alignment: alignment,
    color: color,
    autofocus: autofocus,
    tooltip: tooltip,
    onPressed: onPressed,
    constraints: constraints,
  );

  static Widget actionListTile(String text, {
    String? subtitle, 
    required void Function()? onTap,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    IconData? icon,
    double iconSize = Dimensions.sizeIconAverage,
    Color iconColor = Colors.black,
    bool dense = false,
    VisualDensity visualDensity = VisualDensity.compact,
  }) => InkWell(
    onTap: onTap,
    child: ListTile(
      visualDensity: visualDensity,
      dense: dense,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 20.0,
      leading: (icon != null) ? _iconBase(
        icon,
        size: iconSize,
        color: iconColor
      ): const SizedBox(),
      title: Text(text,
        textAlign: textAlign,
        softWrap: textSoftWrap,
        overflow: textOverflow,
        style: TextStyle(
          fontSize: textFontSize,
          fontWeight: textFontWeight,
          color: textColor
        )
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
    ));

  static Widget actionText(String text, {
    String? subtitle, 
    required void Function()? onTap,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    IconData? icon,
    double iconSize = Dimensions.sizeIconAverage,
    Color iconColor = Colors.black,
  }) => InkWell(
    onTap: onTap,
    child: Row(
        children: [
          if (icon != null) _iconBase(
            icon,
            size: iconSize,
            color: iconColor
          ),
          Dimensions.spacingHorizontal,
          Text(text,
            textAlign: textAlign,
            softWrap: textSoftWrap,
            overflow: textOverflow,
            style: TextStyle(
              fontSize: textFontSize,
              fontWeight: textFontWeight,
              color: textColor
            )
          )
        ],
      )
  );

  static Widget paddedActionText(String text, {
    String? subtitle, 
    required void Function()? onTap,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    IconData? icon,
    double iconSize = Dimensions.sizeIconAverage,
    Color iconColor = Colors.black,
  }) => Padding(
    padding: Dimensions.paddingActionButton,
    child: actionText(
      text,
      subtitle: subtitle,
      onTap: onTap,
      textAlign: textAlign,
      textSoftWrap: textSoftWrap,
      textOverflow: textOverflow,
      textFontWeight: textFontWeight,
      textColor: textColor,
      textFontSize: textFontSize,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor));

  static Widget _textFormFieldBase({
    required BuildContext context,
    TextEditingController? textEditingController,
    Icon? icon,
    required String label,
    required String hint,
    required Function(String?) onSaved,
    required String? Function(String? value) validator,
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
      labelStyle: TextStyle(
        color: Colors.grey.shade600
      )
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
    required String? Function(String? value) validator,
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

  static Widget dialogActions(BuildContext context,
  {
    required List<Widget> buttons,
    EdgeInsets padding = Dimensions.paddingActionsSection,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center
  }) =>  Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.max,
      children: buttons
    )
  );

  static Widget placeholderWidget({
    required String assetName,
    required String text,
    double? assetScale,
    double? assetWidth,
    double? assetHeight,
    AlignmentGeometry assetAlignment = Alignment.center }) {
    return Column(
      children: [
        Image.asset(
            assetName,
            scale: assetScale,
            width: assetWidth,
            height: assetHeight,
            alignment: assetAlignment,),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: Dimensions.fontAverage,
            fontWeight: FontWeight.bold,
            color: Colors.black54
          ),)
      ],);
  }

  static IconData accessModeIcon(AccessMode? accessMode) {
    late final IconData modeIcon;
    switch (accessMode) {
      case AccessMode.blind:
        modeIcon = Icons.visibility_off_outlined;
        break;
      case AccessMode.read:
        modeIcon = Icons.visibility_outlined;
        break;
      case AccessMode.write:
        modeIcon = Icons.edit_note_rounded;
        break;
      default:
        modeIcon = Icons.error_outline_rounded;
        break;
    }

    return modeIcon;
  }
}
