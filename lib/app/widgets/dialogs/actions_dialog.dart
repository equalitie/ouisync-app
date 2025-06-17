import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class ActionsDialog extends StatefulWidget {
  const ActionsDialog({required this.title, this.body});

  final String title;
  final Widget? body;

  @override
  State<ActionsDialog> createState() => _ActionsDialogState();
}

class _ActionsDialogState extends State<ActionsDialog> {
  @override
  Widget build(BuildContext context) => Dialog(
    child: Stack(
      children: <Widget>[
        Container(
          width:
              Platform.isAndroid
                  ? null
                  : Dimensions.sizeModalDialogWidthDesktop,
          padding: Dimensions.paddingDialog,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.circular(
              Dimensions.radiusSmall,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: Dimensions.radiusBig / 2,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints viewportConstraints,
            ) {
              return SingleChildScrollView(
                reverse: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.minHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Fields.constrainedText(
                        widget.title,
                        flex: 0,
                        style: context.theme.appTextStyle.titleMedium,
                        maxLines: 2,
                      ),
                      Dimensions.spacingVertical,
                      widget.body!,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
