import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class EntryInfoTable extends StatelessWidget {
  const EntryInfoTable({
    Key? key,
    this.verticalPadding = 2.0,
    this.spacing = 4.0,
    required this.entryInfo,
  }) : super(key: key);

  final double verticalPadding;
  final double spacing;
  final Map<String, String> entryInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.iconLabel(
              icon: Icons.info_rounded,
              text: S.current.iconInformation,
              style: context.theme.appTextStyle.titleMedium),
          _getInfoTable(entryInfo),
        ],
      ),
    );
  }

  Table _getInfoTable(Map<String, String> entryInfo) {
    return Table(
      columnWidths: {
        0: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      children: entryInfo.entries
          .map((info) => _getInfoItem(info.key, info.value))
          .toList(),
    );
  }

  TableRow _getInfoItem(String label, String info) => TableRow(
        children: [
          Padding(
              padding: EdgeInsets.only(
                right: spacing,
                top: verticalPadding,
                bottom: verticalPadding,
              ),
              child: Text(label)),
          Container(
              padding: EdgeInsets.only(
                top: verticalPadding,
                bottom: verticalPadding,
              ),
              child: Fields.ellipsedText(
                info,
                maxLines: 4,
                ellipsisPosition: TextOverflowPosition.middle,
              )),
        ],
      );
}
