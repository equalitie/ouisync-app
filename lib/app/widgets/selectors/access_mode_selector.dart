import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class AccessModeSelector extends StatefulWidget {
  const AccessModeSelector({
    required this.currentAccessMode,
    required this.availableAccessMode,
    required this.onChanged,
    required this.onDisabledMessage,
    Key? key
  }) : super(key: key);

  final AccessMode currentAccessMode;
  final List<AccessMode> availableAccessMode;
  final Future<void> Function(AccessMode?) onChanged;
  final void Function(bool, String, int) onDisabledMessage;

  @override
  State<AccessModeSelector> createState() => _AccessModeSelectorState();
}

class _AccessModeSelectorState extends State<AccessModeSelector>
    with OuiSyncAppLogger {
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
            borderRadius:
                BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
            color: Constants.inputBackgroundColor),
        child: _buildModeSelector());
  }

  Widget _buildModeSelector() {
    return Column(
        children: [
          Padding(
            padding: Dimensions.paddingItem,
            child: Row(children: [Fields.constrainedText(
              S.current.labelSetPermission,
              fontSize: Dimensions.fontMicro,
              fontWeight: FontWeight.normal,
              color: Constants.inputLabelForeColor)])),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildAccessModeOptions(),)
        ],);
  }

  List<Widget> _buildAccessModeOptions() {
    return AccessMode.values.map((mode) =>
      Expanded(child: RadioListTile(
        title: Text(mode.name,
        textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: Dimensions.fontAverage,
            color: _getModeStateColor(mode)
          ),),
        toggleable: true,
        contentPadding: EdgeInsets.zero,
        value: mode,
        groupValue: _selectedMode,
        onChanged: (current) async {
          loggy.app('Access mode: $current');

          final disabledMessage = 
            S.current.messageAccessModeDisabled(widget.currentAccessMode.name);
          final isEnabled = widget.availableAccessMode.contains(mode);

          widget.onDisabledMessage(
            !isEnabled,
            disabledMessage,
            Constants.notAvailableActionMessageDuration);

          if (!isEnabled) {
            return;
          }

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

  Color _getModeStateColor(AccessMode accessMode) {
    if (widget.availableAccessMode.contains(accessMode)) {
      return Colors.black;
    }

    return Colors.grey;
  }
}