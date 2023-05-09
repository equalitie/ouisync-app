import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as b;
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:styled_text/styled_text.dart';

import 'utils.dart';
import '../widgets/async_text_form_field.dart';

class Fields {
  Fields._();

  static Widget addBadge(Widget child,
      {bool show = true,
      Color color = Colors.red,
      double moveRight = 0,
      double moveDownwards = 0}) {
    return b.Badge(
        showBadge: show,
        ignorePointer: true,
        badgeContent: SizedBox(width: 10, height: 10),
        badgeColor: color,
        position:
            b.BadgePosition(bottom: 12 - moveDownwards, end: 10 - moveRight),
        padding: const EdgeInsets.all(0.0),
        shape: b.BadgeShape.circle,
        child: child);
  }

  static Widget _styledTextBase(
      String message,
      TextAlign textAlign,
      double fontSize,
      FontWeight fontWeight,
      FontStyle fontStyle,
      Color color,
      Map<String, StyledTextTagBase>? tags,
      EdgeInsets padding) {
    tags ??= <String, StyledTextTagBase>{};

    tags.addAll({
      'font': StyledTextTag(
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              color: color))
    });

    return Container(
        padding: padding,
        child: StyledText(
            text: '<font>$message</font>', textAlign: textAlign, tags: tags));
  }

  static Widget inPageMainMessage(
    String message, {
    TextAlign textAlign = TextAlign.center,
    double fontSize = Dimensions.fontBig,
    FontWeight fontWeight = FontWeight.bold,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.black,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsets padding = Dimensions.paddingInPageMain,
  }) =>
      _styledTextBase(
        message,
        textAlign,
        fontSize,
        fontWeight,
        fontStyle,
        color,
        tags,
        padding,
      );

  static Widget inPageSecondaryMessage(
    String message, {
    TextAlign textAlign = TextAlign.center,
    double fontSize = Dimensions.fontAverage,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.black,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsets padding = Dimensions.paddingInPageSecondary,
  }) =>
      _styledTextBase(
        message,
        textAlign,
        fontSize,
        fontWeight,
        fontStyle,
        color,
        tags,
        padding,
      );

  static Widget inPageButton({
    required void Function()? onPressed,
    Icon? leadingIcon,
    required String text,
    Alignment alignment = Alignment.center,
    Size size = Dimensions.sizeInPageButtonRegular,
    double fontSize = Dimensions.fontSmall,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Colors.white,
    bool autofocus = false,
  }) =>
      ElevatedButton(
        onPressed: onPressed,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (leadingIcon != null) leadingIcon,
          if (leadingIcon != null) Dimensions.spacingHorizontal,
          Text(text.toUpperCase())
        ]),
        style: ButtonStyle(
          alignment: alignment,
          minimumSize: MaterialStateProperty.all<Size?>(size),
          textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              color: color)),
        ),
        autofocus: autofocus,
      );

  static Widget bottomSheetHandle(BuildContext context,
          {double widthFactor = 0.25,
          double verticalMargin = 20.0,
          double height = 4.0,
          double borderRadius = 2.5}) =>
      FractionallySizedBox(
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
          {EdgeInsets padding = Dimensions.paddingBottomSheetTitle,
          TextAlign textAlign = TextAlign.start,
          TextOverflow textOverflow = TextOverflow.ellipsis,
          bool softWrap = true,
          double fontSize = Dimensions.fontBig,
          FontWeight fontWeight = FontWeight.w400}) =>
      Padding(
          padding: padding,
          child: Row(children: [
            Text(
              title,
              textAlign: textAlign,
              softWrap: softWrap,
              overflow: textOverflow,
              style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
            ),
          ]));

  static Widget idLabel(String text,
          {TextAlign textAlign = TextAlign.center,
          TextOverflow textOverflow = TextOverflow.ellipsis,
          bool softWrap = true,
          double fontSize = Dimensions.fontSmall,
          FontWeight fontWeight = FontWeight.w500,
          Color color = Colors.black}) =>
      Text(
        text,
        textAlign: textAlign,
        softWrap: softWrap,
        overflow: textOverflow,
        style:
            TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  static autosizedLabeledText(
          {required String label,
          required String text,
          Key? textKey,
          TextAlign labelTextAlign = TextAlign.center,
          TextOverflow labelTextOverflow = TextOverflow.ellipsis,
          bool labelSoftWrap = false,
          double labelFontSize = Dimensions.fontAverage,
          FontWeight labelFontWeight = FontWeight.w500,
          Color labelColor = Colors.black,
          TextAlign textAlign = TextAlign.start,
          TextOverflow textOverflow = TextOverflow.ellipsis,
          bool textSoftWrap = true,
          double textFontSize = Dimensions.fontAverage,
          double minTextFontSize = Dimensions.fontSmall,
          double maxTextFontSize = Dimensions.fontAverage,
          FontWeight textFontWeight = FontWeight.normal,
          Color textColor = Colors.black,
          int textMaxLines = 1,
          EdgeInsets padding = Dimensions.paddingBox,
          Widget space = Dimensions.spacingHorizontal}) =>
      Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                  flex: 0,
                  child: idLabel(label,
                      textAlign: labelTextAlign,
                      textOverflow: labelTextOverflow,
                      softWrap: labelSoftWrap,
                      fontSize: labelFontSize,
                      fontWeight: labelFontWeight,
                      color: labelColor)),
              space,
              Expanded(
                  flex: 1,
                  child: autosizeText(text,
                      key: textKey,
                      textAlign: textAlign,
                      textOverflow: textOverflow,
                      softWrap: textSoftWrap,
                      fontSize: textFontSize,
                      minFontSize: minTextFontSize,
                      maxFontSize: maxTextFontSize,
                      fontWeight: textFontWeight,
                      color: textColor,
                      maxLines: textMaxLines))
            ],
          ));

  static Widget labeledText(
          {required String label,
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
          Widget space = Dimensions.spacingHorizontal}) =>
      Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              idLabel(label,
                  textAlign: labelTextAlign,
                  textOverflow: labelTextOverflow,
                  softWrap: labelSoftWrap,
                  fontSize: labelFontSize,
                  fontWeight: labelFontWeight,
                  color: labelColor),
              space,
              constrainedText(text,
                  textAlign: textAlign,
                  textOverflow: textOverflow,
                  softWrap: textSoftWrap,
                  fontSize: textFontSize,
                  fontWeight: textFontWeight,
                  color: textColor)
            ],
          ));

  static Widget labeledButton({
    required String label,
    required String buttonText,
    required Function() onPressed,
  }) =>
      Row(
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

  static Widget iconLabel(
          {required IconData icon,
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
          Widget space = Dimensions.spacingHorizontal}) =>
      Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _iconBase(icon, size: iconSize, color: iconColor),
              space,
              constrainedText(text,
                  textAlign: textAlign,
                  textOverflow: textOverflow,
                  softWrap: textSoftWrap,
                  fontSize: textFontSize,
                  fontWeight: textFontWeight,
                  color: textColor)
            ],
          ));

  static Widget autosizeText(String text,
          {Key? key,
          TextAlign textAlign = TextAlign.start,
          TextOverflow textOverflow = TextOverflow.ellipsis,
          bool softWrap = true,
          double fontSize = Dimensions.fontAverage,
          double minFontSize = Dimensions.fontSmall,
          double maxFontSize = Dimensions.fontAverage,
          FontWeight fontWeight = FontWeight.normal,
          Color color = Colors.black,
          int maxLines = 1}) =>
      AutoSizeText(
        text,
        key: key,
        textAlign: textAlign,
        softWrap: softWrap,
        overflow: textOverflow,
        maxLines: maxLines,
        style:
            TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
        minFontSize: minFontSize,
        maxFontSize: maxFontSize,
      );

  static Widget constrainedText(String text,
          {Key? key,
          int flex = 1,
          TextAlign textAlign = TextAlign.start,
          TextOverflow textOverflow = TextOverflow.clip,
          bool softWrap = true,
          double fontSize = Dimensions.fontAverage,
          FontWeight fontWeight = FontWeight.normal,
          Color color = Colors.black,
          int maxLines = 1}) =>
      Expanded(
        key: key,
        flex: flex,
        child: Text(
          text,
          textAlign: textAlign,
          softWrap: softWrap,
          overflow: textOverflow,
          maxLines: maxLines,
          style: TextStyle(
              fontSize: fontSize, fontWeight: fontWeight, color: color),
        ),
      );

  static Icon _iconBase(
    IconData icon, {
    double size = Dimensions.sizeIconAverage,
    Color color = Colors.black,
  }) =>
      Icon(icon, size: size, color: color);

  static Widget actionIcon(
    Icon icon, {
    required void Function()? onPressed,
    double size = Dimensions.sizeIconMicro,
    EdgeInsets padding = Dimensions.paddingIconButton,
    AlignmentGeometry alignment = Dimensions.alignmentIconButton,
    Color color = Colors.black,
    bool autofocus = false,
    String? tooltip,
    BoxConstraints? constraints,
  }) =>
      IconButton(
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

  static Widget actionListTile(
    String text, {
    String? subtitle,
    required void Function()? onTap,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    double textFontSize = Dimensions.fontAverage,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    IconData? icon,
    double iconSize = Dimensions.sizeIconMicro,
    Color iconColor = Colors.black,
    bool dense = false,
    VisualDensity visualDensity = VisualDensity.compact,
  }) =>
      InkWell(
          onTap: onTap,
          child: ListTile(
            visualDensity: visualDensity,
            dense: dense,
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 20.0,
            leading: (icon != null)
                ? _iconBase(icon, size: iconSize, color: iconColor)
                : const SizedBox(),
            title: Text(text,
                textAlign: textAlign,
                softWrap: textSoftWrap,
                overflow: textOverflow,
                style: TextStyle(
                    fontSize: textFontSize,
                    fontWeight: textFontWeight,
                    color: textColor)),
            subtitle: subtitle != null ? Text(subtitle) : null,
          ));

  static Widget actionText(
    String text, {
    String? subtitle,
    required void Function()? onTap,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    int textMaxLines = 1,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    IconData? icon,
    double iconSize = Dimensions.sizeIconAverage,
    Color iconColor = Colors.black,
  }) =>
      InkWell(
          onTap: onTap,
          child: Row(
            children: [
              if (icon != null)
                _iconBase(icon, size: iconSize, color: iconColor),
              Dimensions.spacingHorizontal,
              Expanded(
                  child: Text(text,
                      textAlign: textAlign,
                      overflow: textOverflow,
                      softWrap: textSoftWrap,
                      maxLines: textMaxLines,
                      style: TextStyle(
                          fontSize: textFontSize,
                          fontWeight: textFontWeight,
                          color: textColor)))
            ],
          ));

  static Widget paddedActionText(
    String text, {
    String? subtitle,
    required void Function()? onTap,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    int textMaxLines = 1,
    double textFontSize = Dimensions.fontBig,
    FontWeight textFontWeight = FontWeight.normal,
    Color textColor = Colors.black,
    IconData? icon,
    double iconSize = Dimensions.sizeIconAverage,
    Color iconColor = Colors.black,
  }) =>
      Padding(
          padding: Dimensions.paddingActionButton,
          child: actionText(text,
              subtitle: subtitle,
              onTap: onTap,
              textAlign: textAlign,
              textSoftWrap: textSoftWrap,
              textOverflow: textOverflow,
              textMaxLines: textMaxLines,
              textFontWeight: textFontWeight,
              textColor: textColor,
              textFontSize: textFontSize,
              icon: icon,
              iconSize: iconSize,
              iconColor: iconColor));

  static Widget _textFormFieldBase({
    Key? key,
    required BuildContext context,
    TextEditingController? textEditingController,
    Icon? icon,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? label,
    required String hint,
    Function(String?)? onSaved,
    FutureOr<String?> Function(String?)? validator,
    AutovalidateMode? autovalidateMode,
    bool autofocus = false,
    FocusNode? focusNode,
    bool obscureText = false,
  }) {
    final inputBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 2.0,
      ),
    );
    final decoration = InputDecoration(
      filled: true,
      fillColor: Constants.inputBackgroundColor,
      border: InputBorder.none,
      focusedBorder: inputBorder,
      icon: icon,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hint,
      labelText: label,
      labelStyle: TextStyle(color: Constants.inputLabelForeColor),
      errorMaxLines: 2,
    );

    if (validator is Future<String?> Function(String?)) {
      return AsyncTextFormField(
        key: key,
        controller: textEditingController,
        autovalidateMode: autovalidateMode,
        autofocus: autofocus,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: TextInputType.text,
        decoration: decoration,
        validator: validator,
        onSaved: onSaved,
      );
    } else {
      return TextFormField(
        key: key,
        controller: textEditingController,
        autovalidateMode: autovalidateMode,
        autofocus: autofocus,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: TextInputType.text,
        decoration: decoration,
        validator: validator as String? Function(String?)?,
        onSaved: onSaved,
      );
    }
  }

  static Widget formTextField({
    Key? key,
    required BuildContext context,
    TextEditingController? textEditingController,
    Icon? icon,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? label,
    required String hint,
    Function(String?)? onSaved,
    FutureOr<String?> Function(String? value)? validator,
    AutovalidateMode? autovalidateMode,
    bool autofocus = false,
    FocusNode? focusNode,
    bool obscureText = false,
  }) =>
      Padding(
          padding: Dimensions.paddingFormTextField,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _textFormFieldBase(
                key: key,
                context: context,
                textEditingController: textEditingController,
                icon: icon,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                label: label,
                hint: hint,
                onSaved: onSaved,
                validator: validator,
                autovalidateMode: autovalidateMode,
                autofocus: autofocus,
                focusNode: focusNode,
                obscureText: obscureText,
              )
            ],
          ));

  static Widget dialogActions(BuildContext context,
          {required List<Widget> buttons,
          EdgeInsets padding = Dimensions.paddingActionsSection,
          MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center}) =>
      Padding(
          padding: padding,
          child: Row(
              mainAxisAlignment: mainAxisAlignment,
              mainAxisSize: MainAxisSize.max,
              children: buttons));

  static Widget placeholderWidget(
      {required String assetName,
      String? text,
      double? assetScale,
      double? assetWidth,
      double? assetHeight,
      AlignmentGeometry assetAlignment = Alignment.center}) {
    return Column(
      children: [
        Image.asset(
          assetName,
          scale: assetScale,
          width: assetWidth,
          height: assetHeight,
          alignment: assetAlignment,
        ),
        if (text != null)
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: Dimensions.fontAverage,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          )
      ],
    );
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
