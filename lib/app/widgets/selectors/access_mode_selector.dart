import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../../models/access_mode.dart';

class AccessModeSelector extends StatefulWidget {
  const AccessModeSelector({
    required this.currentAccessMode,
    required this.availableAccessMode,
    required this.onChanged,
    required this.onDisabledMessage,
    super.key,
  });

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
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(Dimensions.radiusSmall),
          ),
          color: Constants.inputBackgroundColor),
      child: _buildModeSelector(),
    );
  }

  Widget _buildModeSelector() => Column(children: [
        Padding(
            padding: Dimensions.paddingItem,
            child: Row(children: [
              Fields.constrainedText(S.current.labelSetPermission,
                  style: context.theme.appTextStyle.bodyMicro
                      .copyWith(color: Constants.inputLabelForeColor))
            ])),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildAccessModeOptions())
      ]);

  List<Widget> _buildAccessModeOptions() => AccessMode.values
      .map((mode) => Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Radio(
                value: mode,
                groupValue: _selectedMode,
                toggleable: true,
                onChanged: (current) async {
                  loggy.debug('Access mode: $current');

                  if (!widget.availableAccessMode.contains(mode)) {
                    final message = S.current.messageAccessModeDisabled(
                        widget.currentAccessMode.localized);
                    widget.onDisabledMessage(message);
                    return;
                  }

                  setState(() => _selectedMode = current);
                  await widget.onChanged(current);
                }),
            Text(
              mode.localized,
              textAlign: TextAlign.start,
              style: TextStyle().copyWith(color: _getModeStateColor(mode)),
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
