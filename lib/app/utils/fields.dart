import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as b;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:styled_text/styled_text.dart';

import '../pages/pages.dart';
import '../widgets/async_text_form_field.dart';
import '../widgets/buttons/elevated_async_button.dart';
import 'platform/platform.dart';
import 'utils.dart';

class Fields {
  Fields._();

  static Widget addBadge(
    Widget child, {
    bool show = true,
    Color color = Colors.red,
    double moveRight = 0,
    double moveDownwards = 0,
  }) {
    return b.Badge(
      showBadge: show,
      ignorePointer: true,
      badgeStyle: b.BadgeStyle(badgeColor: color, shape: b.BadgeShape.circle),
      position: b.BadgePosition.custom(
        bottom: 12 - moveDownwards,
        end: 10 - moveRight,
      ),
      child: child,
    );
  }

  static Widget _styledTextBase(
    String message,
    TextAlign textAlign,
    TextStyle? style,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsetsDirectional padding,
  ) {
    tags ??= <String, StyledTextTagBase>{};

    tags.addAll({'font': StyledTextTag(style: style)});

    return Container(
      padding: padding,
      child: StyledText(
        text: '<font>$message</font>',
        textAlign: textAlign,
        tags: tags,
      ),
    );
  }

  static Widget inPageMainMessage(
    String message, {
    TextAlign textAlign = TextAlign.center,
    TextStyle? style,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsetsDirectional padding = Dimensions.paddingInPageMain,
  }) => _styledTextBase(message, textAlign, style, tags, padding);

  static Widget inPageSecondaryMessage(
    String message, {
    TextAlign textAlign = TextAlign.center,
    TextStyle? style,
    Map<String, StyledTextTagBase>? tags,
    EdgeInsetsDirectional padding = Dimensions.paddingInPageSecondary,
  }) => _styledTextBase(message, textAlign, style, tags, padding);

  static Widget inPageButton({
    required void Function()? onPressed,
    Icon? leadingIcon,
    required String text,
    AlignmentDirectional alignment = AlignmentDirectional.center,
    Size size = Dimensions.sizeInPageButtonRegular,
    bool autofocus = false,
    FocusNode? focusNode,
    Color? backgroundColor,
    Color? foregroundColor,
  }) => ElevatedButton(
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) leadingIcon,
        if (leadingIcon != null) Dimensions.spacingHorizontal,
        Text(text.toUpperCase()),
      ],
    ),
    style: ButtonStyle(
      alignment: alignment,
      minimumSize: WidgetStateProperty.all<Size?>(size),
      backgroundColor:
          backgroundColor != null
              ? WidgetStateProperty.all<Color>(backgroundColor)
              : null,
      foregroundColor:
          foregroundColor != null
              ? WidgetStateProperty.all<Color>(foregroundColor)
              : null,
    ),
    autofocus: autofocus,
    focusNode: focusNode,
  );

  static Widget inPageAsyncButton({
    Key? key,
    required Future<void> Function()? onPressed,
    Icon? leadingIcon,
    required String text,
    AlignmentDirectional alignment = AlignmentDirectional.center,
    Size size = Dimensions.sizeInPageButtonRegular,
    bool autofocus = false,
    FocusNode? focusNode,
    Color? backgroundColor,
    Color? foregroundColor,
  }) => ElevatedAsyncButton(
    key: key,
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) leadingIcon,
        if (leadingIcon != null) Dimensions.spacingHorizontal,
        Text(text.toUpperCase()),
      ],
    ),
    style: ButtonStyle(
      alignment: alignment,
      minimumSize: WidgetStateProperty.all<Size?>(size),
      backgroundColor:
          backgroundColor != null
              ? WidgetStateProperty.all<Color>(backgroundColor)
              : null,
      foregroundColor:
          foregroundColor != null
              ? WidgetStateProperty.all<Color>(foregroundColor)
              : null,
    ),
    autofocus: autofocus,
    focusNode: focusNode,
  );

  static Widget bottomSheetHandle(
    BuildContext context, {
    double widthFactor = 0.25,
    double verticalMargin = 20.0,
    double height = 4.0,
    double borderRadius = 2.5,
  }) => FractionallySizedBox(
    widthFactor: widthFactor,
    child: Container(
      margin: EdgeInsetsDirectional.symmetric(vertical: verticalMargin),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(borderRadius),
          ),
        ),
      ),
    ),
  );

  static Widget bottomSheetTitle(
    String title, {
    EdgeInsetsDirectional padding = Dimensions.paddingBottomSheetTitle,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    bool softWrap = true,
    TextStyle? style,
  }) => Padding(
    padding: padding,
    child: Text(
      title,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: textOverflow,
      style: style,
    ),
  );

  static Widget idLabel(
    String text, {
    TextAlign textAlign = TextAlign.center,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    bool softWrap = true,
    TextStyle? style,
  }) => Text(
    text,
    textAlign: textAlign,
    softWrap: softWrap,
    overflow: textOverflow,
    style: style,
  );

  static autosizedLabeledText({
    required String label,
    required String text,
    Key? textKey,
    TextAlign labelTextAlign = TextAlign.center,
    TextOverflow labelTextOverflow = TextOverflow.ellipsis,
    bool labelSoftWrap = false,
    TextStyle? labelStyle,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    bool textSoftWrap = true,
    TextStyle? textStyle,
    double? minTextFontSize,
    double? maxTextFontSize,
    int textMaxLines = 1,
    EdgeInsetsDirectional padding = Dimensions.paddingBox,
    Widget space = Dimensions.spacingHorizontal,
  }) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          flex: 0,
          child: idLabel(
            label,
            textAlign: labelTextAlign,
            textOverflow: labelTextOverflow,
            softWrap: labelSoftWrap,
            style: labelStyle,
          ),
        ),
        space,
        Expanded(
          flex: 1,
          child: autosizeText(
            text,
            key: textKey,
            textAlign: textAlign,
            textOverflow: textOverflow,
            softWrap: textSoftWrap,
            style: textStyle,
            minFontSize: minTextFontSize,
            maxFontSize: maxTextFontSize,
            maxLines: textMaxLines,
          ),
        ),
      ],
    ),
  );

  static Widget labeledText({
    required String label,
    required String text,
    TextAlign labelTextAlign = TextAlign.center,
    TextOverflow labelTextOverflow = TextOverflow.ellipsis,
    bool labelSoftWrap = false,
    TextStyle? labelStyle,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool textSoftWrap = true,
    TextStyle? textStyle,
    EdgeInsetsDirectional padding = Dimensions.paddingBox,
    Widget space = Dimensions.spacingHorizontal,
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
          style: textStyle,
        ),
        space,
        constrainedText(
          text,
          textAlign: textAlign,
          textOverflow: textOverflow,
          softWrap: textSoftWrap,
          style: textStyle,
        ),
      ],
    ),
  );

  static Widget labeledButton({
    required String label,
    TextStyle? labelStyle,
    required String buttonText,
    TextStyle? buttonTextStyle,
    required Function() onPressed,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      idLabel(label, textAlign: TextAlign.start, style: labelStyle),
      OutlinedButton(
        child: Text(buttonText, style: buttonTextStyle),
        onPressed: onPressed,
      ),
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
    TextStyle? style,
    EdgeInsetsDirectional padding = Dimensions.paddingBox,
    Widget space = Dimensions.spacingHorizontal,
  }) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          flex: 0,
          child: _iconBase(icon, size: iconSize, color: iconColor),
        ),
        Expanded(flex: 0, child: space),
        Expanded(
          child: Text(
            text,
            textAlign: textAlign,
            overflow: textOverflow,
            softWrap: textSoftWrap,
            style: style,
          ),
        ),
      ],
    ),
  );

  static Widget autosizeText(
    String text, {
    Key? key,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    bool softWrap = true,
    TextStyle? style,
    double? minFontSize,
    double? maxFontSize,
    int maxLines = 1,
  }) => AutoSizeText(
    text,
    key: key,
    textAlign: textAlign,
    softWrap: softWrap,
    overflow: textOverflow,
    maxLines: maxLines,
    style: style,
    minFontSize: minFontSize ?? 12.0,
    maxFontSize: maxFontSize ?? double.infinity,
  );

  static Widget constrainedText(
    String text, {
    Key? key,
    int flex = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.clip,
    bool softWrap = true,
    TextStyle? style,
    int maxLines = 1,
  }) => Expanded(
    key: key,
    flex: flex,
    child: Text(
      text,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: textOverflow,
      maxLines: maxLines,
      style: style,
    ),
  );

  static Icon _iconBase(
    IconData icon, {
    double size = Dimensions.sizeIconAverage,
    Color color = Colors.black,
  }) => Icon(icon, size: size, color: color);

  static Widget actionIcon(
    Widget icon, {
    required void Function()? onPressed,
    double size = Dimensions.sizeIconMicro,
    EdgeInsetsDirectional padding = Dimensions.paddingIconButton,
    AlignmentGeometry alignment = Dimensions.alignmentIconButton,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    String? tooltip,
    BoxConstraints? constraints,
  }) => IconButton(
    icon: icon,
    iconSize: size,
    padding: padding,
    alignment: alignment,
    color: color,
    focusNode: focusNode,
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
    TextStyle? style,
    IconData? icon,
    double iconSize = Dimensions.sizeIconMicro,
    Color iconColor = Colors.black,
    bool dense = false,
    VisualDensity visualDensity = VisualDensity.compact,
  }) => InkWell(
    onTap: onTap,
    child: ListTile(
      visualDensity: visualDensity,
      dense: dense,
      contentPadding: EdgeInsetsDirectional.zero,
      minLeadingWidth: 20.0,
      leading:
          (icon != null)
              ? _iconBase(icon, size: iconSize, color: iconColor)
              : const SizedBox(),
      title: Text(
        text,
        textAlign: textAlign,
        softWrap: textSoftWrap,
        overflow: textOverflow,
        style: style,
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
    ),
  );

  static Widget formTextField({
    Key? key,
    required BuildContext context,
    TextEditingController? controller,
    TextStyle? style,
    bool? enabled = true,
    Icon? icon,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? labelText,
    String? hintText,
    String? errorText,
    Function(String?)? onSaved,
    Function(String)? onChanged,
    Function(String?)? onFieldSubmitted,
    FutureOr<String?> Function(String? value)? validator,
    AutovalidateMode? autovalidateMode,
    bool autofocus = false,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputAction? textInputAction,
  }) {
    final inputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
    );
    final decoration = InputDecoration(
      filled: true,
      fillColor: Constants.inputBackgroundColor,
      border: InputBorder.none,
      focusedBorder: inputBorder,
      icon: icon,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      labelStyle: TextStyle(color: Constants.inputLabelForeColor),
      errorMaxLines: 2,
    );

    final widget =
        (validator is Future<String?> Function(String?))
            ? AsyncTextFormField(
              key: key,
              controller: controller,
              enabled: enabled,
              autovalidateMode: autovalidateMode,
              autofocus: autofocus,
              focusNode: focusNode,
              obscureText: obscureText,
              textInputAction: textInputAction,
              keyboardType: TextInputType.text,
              decoration: decoration,
              style: style,
              validator: validator,
              onSaved: onSaved,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
            )
            : TextFormField(
              key: key,
              controller: controller,
              enabled: enabled,
              autovalidateMode: autovalidateMode,
              autofocus: autofocus,
              focusNode: focusNode,
              obscureText: obscureText,
              textInputAction: textInputAction,
              keyboardType: TextInputType.text,
              decoration: decoration,
              style: style,
              validator: validator as String? Function(String?)?,
              onSaved: onSaved,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
            );

    return Padding(
      padding: Dimensions.paddingFormTextField,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [widget],
      ),
    );
  }

  static Widget dialogActions({
    required List<Widget> buttons,
    EdgeInsetsDirectional padding = Dimensions.paddingActionsSection,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  }) => Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.max,
      children: buttons,
    ),
  );

  static Widget placeholderWidget({
    required String assetName,
    String? text,
    TextStyle? style,
    double? assetScale,
    double? assetWidth,
    double? assetHeight,
    AlignmentGeometry assetAlignment = AlignmentDirectional.center,
  }) {
    return Column(
      children: [
        Image.asset(
          assetName,
          scale: assetScale,
          width: assetWidth,
          height: assetHeight,
          alignment: assetAlignment,
        ),
        if (text != null) Text(text, textAlign: TextAlign.center, style: style),
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

  static TextSpan boldTextSpan(String text, {double? fontSize}) => TextSpan(
    text: text,
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
  );

  static TextSpan linkTextSpan(
    BuildContext context,
    String text,
    void Function(BuildContext) callback, {
    double? fontSize,
  }) => TextSpan(
    text: text,
    style: TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blueAccent,
      fontSize: fontSize,
    ),
    recognizer: TapGestureRecognizer()..onTap = () => callback(context),
  );

  static WidgetSpan quoteTextSpan(
    String quote,
    String author, {
    double? fontSize,
  }) => WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    style: TextStyle(fontSize: fontSize),
    child: Text.rich(
      TextSpan(
        style: TextStyle(fontSize: fontSize),
        children: [
          italicTextSpan(quote, fontSize: fontSize),
          TextSpan(text: author, style: TextStyle(fontSize: fontSize)),
        ],
      ),
      style: TextStyle(fontSize: fontSize),
    ),
  );

  static TextSpan italicTextSpan(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
  }) => TextSpan(
    text: text,
    style: TextStyle(
      fontStyle: FontStyle.italic,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );

  static Future<void> openUrl(
    BuildContext context,
    Widget title,
    String url,
  ) async {
    final webView = PlatformWebView();

    if (PlatformValues.isDesktopDevice) {
      await webView.launchUrl(url);
      return;
    }

    final content = await Dialogs.executeFutureWithLoadingDialog(
      null,
      webView.loadUrl(context, url),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: title, content: content),
      ),
    );
  }
}
