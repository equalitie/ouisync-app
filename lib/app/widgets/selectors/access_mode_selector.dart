import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';

class AccessModeSelector extends StatefulWidget {
  const AccessModeSelector({
    required this.currentAccessMode,
    required this.availableAccessMode,
    required this.onChanged,
    required this.onDisabledMessage,
    Key? key,
  }) : super(key: key);

  final AccessMode currentAccessMode;
  final List<AccessMode> availableAccessMode;
  final Future<void> Function(AccessMode?) onChanged;
  final void Function(String) onDisabledMessage;

  @override
  State<AccessModeSelector> createState() => _AccessModeSelectorState();
}

class _AccessModeSelectorState extends State<AccessModeSelector>
    with AppLogger {
  final Map<AccessMode, String> accessModeDescriptions = {
    AccessMode.blind: S.current.messageBlindReplicaExplanation,
    AccessMode.read: S.current.messageReadReplicaExplanation,
    AccessMode.write: S.current.messageWriteReplicaExplanation,
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
      child: _buildModeSelector(),
    );
  }

  Widget _buildModeSelector() {
    final microFontSize =
        (Theme.of(context).textTheme.bodySmall?.fontSize ?? 0.0) * 0.8;

    final microBodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: microFontSize, color: Constants.inputLabelForeColor);

    return Column(
      children: [
        Padding(
          padding: Dimensions.paddingItem,
          child: Row(
            children: [
              Fields.constrainedText(S.current.labelSetPermission,
                  style: microBodyStyle),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildAccessModeOptions(),
        )
      ],
    );
  }

  List<Widget> _buildAccessModeOptions() => AccessMode.values
      .map((mode) => Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Radio(
                value: mode,
                groupValue: _selectedMode,
                toggleable: true,
                onChanged: (current) async {
                  loggy.app('Access mode: $current');

                  if (!widget.availableAccessMode.contains(mode)) {
                    final message = S.current.messageAccessModeDisabled(
                        widget.currentAccessMode.name);
                    widget.onDisabledMessage(message);
                    return;
                  }

                  setState(() => _selectedMode = current);
                  await widget.onChanged(current);
                }),
            Text(
              mode.name,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: Dimensions.fontAverage,
                color: _getModeStateColor(mode),
              ),
            )
          ])))
      .toList();

  Color _getModeStateColor(AccessMode accessMode) {
    if (widget.availableAccessMode.contains(accessMode)) {
      return Colors.black;
    }

    return Colors.grey;
  }
}
