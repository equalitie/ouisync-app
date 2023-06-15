import 'package:flutter/material.dart';

import '../logs_actions.dart';
import '../../../cubits/cubits.dart';
import '../../../utils/utils.dart';
import '../../../../generated/l10n.dart';

class LogsDesktopDetail extends StatelessWidget {
  LogsDesktopDetail({
    required this.settings,
    required this.repos,
    required this.panicCounter,
  }) : actions = LogsActions(
          settings: settings,
          stateMonitor: repos.session.rootStateMonitor,
        );

  final Settings settings;
  final ReposCubit repos;
  final StateMonitorIntCubit panicCounter;
  final LogsActions actions;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildSaveTile(context),
      _buildShareTile(context),
      _buildViewTile(context)
    ]);
  }

  Widget _buildSaveTile(BuildContext context) => Column(children: [
        Row(children: [Text(S.current.actionSave, textAlign: TextAlign.start)]),
        ListTile(
            leading: const Icon(Icons.save),
            title: Row(children: [
              TextButton(
                  onPressed: () => actions.saveLogs(context),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      child: Text(S.current.messageSaveLogFile)),
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white))
            ])),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildShareTile(BuildContext context) => Wrap(children: [
        ListTile(
            // TODO: enable this on desktop as well (if possible)
            enabled: false,
            title: Text(S.current.actionShare,
                style: TextStyle(fontSize: Dimensions.fontSmall)),
            leading: Icon(Icons.share),
            onTap: () => actions.shareLogs(context)),
        Dimensions.desktopSettingDivider
      ]);

  Widget _buildViewTile(BuildContext context) => ListTile(
        // TODO: enable this on desktop as well
        enabled: false,
        title: Text(S.current.messageView, 
            style: TextStyle(fontSize: Dimensions.fontSmall)),
        leading: Icon(Icons.visibility),
        onTap: () => actions.viewLogs(context),
      );
}
