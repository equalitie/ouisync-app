import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../../cubits/repo.dart';

class AccessModeDropDownMenu extends StatefulWidget {
  const AccessModeDropDownMenu({
    required this.accessModes,
    required this.onChanged,
  });


  final List<AccessMode> accessModes;
  final Future<void> Function(AccessMode) onChanged;

  @override
  State<AccessModeDropDownMenu> createState() => _AccessModeDropDownMenuState();
}

class _AccessModeDropDownMenuState extends State<AccessModeDropDownMenu>  with OuiSyncAppLogger {
  AccessMode _accessMode = AccessMode.blind;

  final Map<AccessMode, String> accessModeDescriptions = {
    AccessMode.blind: S.current.messageBlindReplicaExplanation,
    AccessMode.read: S.current.messageReadReplicaExplanation,
    AccessMode.write: S.current.messageWriteReplicaExplanation
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingActionBox,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
        color: Constants.inputBackgroundColor
      ),
      child: DropdownButton(
        isExpanded: true,
        value: _accessMode,
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        underline: const SizedBox(),
        items: widget.accessModes.map((AccessMode element) => DropdownMenuItem(
          value: element,
          child: _buildOpenAccessModeItem(context, element))).toList(),
        selectedItemBuilder: (context) => widget.accessModes.map<Widget>((AccessMode element) {
          return _buildAccessModeItem(element);
        }).toList(),
        onChanged: (accessMode) async {
          loggy.app('Access mode: $accessMode');
          setState(() { _accessMode = accessMode as AccessMode; });

          await widget.onChanged(accessMode as AccessMode);
        },
      ));
  }

  Widget _buildOpenAccessModeItem(BuildContext context, AccessMode accessMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(accessMode == _accessMode ? Icons.check : null,
          size: Dimensions.sizeIconSmall,
          color: Theme.of(context).primaryColor),
        Dimensions.spacingHorizontalDouble,
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Fields.constrainedText(
                    accessMode.name.capitalize(),
                    fontWeight: FontWeight.normal)])),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 95.0),
              child: Row(
                children: [
                  Fields.constrainedText(
                    _tokenDescription(accessMode),
                    fontSize: Dimensions.fontMicro,
                    fontWeight: FontWeight.normal)])),
            Dimensions.spacingVerticalHalf
          ])
      ]);
  }

  Widget _buildAccessModeItem(AccessMode accessMode) => 
    Padding(
      padding: Dimensions.paddingItem,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Fields.constrainedText(
            S.current.labelSetPermission,
            fontSize: Dimensions.fontMicro,
            fontWeight: FontWeight.normal,
            color: Constants.inputLabelForeColor)]),
          Row(children: [Fields.constrainedText(
            accessMode.name.capitalize(),
            fontWeight: FontWeight.normal)])
        ],
      ));

  String _tokenDescription(AccessMode accessMode) {
    return accessModeDescriptions.values.elementAt(accessMode.index);
  }
}
