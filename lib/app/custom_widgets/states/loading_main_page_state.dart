import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/generated/l10n.dart';

class LoadingMainPageState extends StatelessWidget {
  const LoadingMainPageState({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator.adaptive(),
          Dimensions.spacingVerticalDouble,
          Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(
              S.current.messageInitializing
            ),
          )
        ],
      ),
    );
  }
}