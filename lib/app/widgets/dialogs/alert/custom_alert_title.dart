import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/utils/extensions.dart';

import '../../../utils/fields.dart';

class CustomAlertTitle extends StatelessWidget {
  const CustomAlertTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: 1,
        child: Flex(
          mainAxisSize: MainAxisSize.min,
          direction: Axis.horizontal,
          children: [
            Fields.constrainedText(
              title,
              style: context.theme.appTextStyle.titleMedium,
              maxLines: 2,
            )
          ],
        ),
      );
}
