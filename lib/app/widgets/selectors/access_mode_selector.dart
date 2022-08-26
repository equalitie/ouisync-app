import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class AccessModeSelector extends StatefulWidget {
  const AccessModeSelector({
    required this.accessModes,
    required this.onChanged,
  });

  final List<AccessMode> accessModes;
  final Future<void> Function(AccessMode?) onChanged;

  @override
  State<AccessModeSelector> createState() => _AccessModeSelectorState();
}

class _AccessModeSelectorState extends State<AccessModeSelector>  with OuiSyncAppLogger {
  final Map<AccessMode, String> accessModeDescriptions = {
    AccessMode.blind: S.current.messageBlindReplicaExplanation,
    AccessMode.read: S.current.messageReadReplicaExplanation,
    AccessMode.write: S.current.messageWriteReplicaExplanation
  };

  AccessMode? _selectedMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingActionBoxTop,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
        color: Constants.inputBackgroundColor
      ),
      child: _buildModeSelector());
  }

  Widget _buildModeSelector() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Dimensions.paddingItem,
            child: Row(children: [Fields.constrainedText(
              S.current.labelSetPermission,
              fontSize: Dimensions.fontMicro,
              fontWeight: FontWeight.normal,
              color: Constants.inputLabelForeColor)])),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildAccessModeOptions(),)
        ],);
  }

  List<Widget> _buildAccessModeOptions() {
    return widget.accessModes.map((mode) =>
      Expanded(child: RadioListTile(
        title: Text(mode.name,
          style: const TextStyle(
            fontSize: Dimensions.fontAverage,
          ),),
        toggleable: true,
        dense: true,
        contentPadding: const EdgeInsets.all(0.0),
        visualDensity: VisualDensity.compact,
        value: mode,
        groupValue: _selectedMode,
        onChanged: (current) async {
          loggy.app('Access mode: $current');

          if (current == null) {
            setState(() => _selectedMode = null);
            await widget.onChanged(null);

            return;
          }

          setState(() => _selectedMode = current as AccessMode);
          await widget.onChanged(current as AccessMode);
        },
      ))).toList();
  }
}