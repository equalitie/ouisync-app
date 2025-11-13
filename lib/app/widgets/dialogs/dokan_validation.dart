import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/stage.dart';
import '../../utils/utils.dart'
    show Constants, DokanScripts, DokanCheckResult, Fields;
import '../widgets.dart'
    show
        ActionsDialog,
        DokanDifferentMayorFound,
        DokanNotFound,
        DokanOlderMayorFound;

class DokanValidation {
  const DokanValidation({
    required Stage stage,
    required void Function() installationOk,
    required Future<bool?> Function() installationFailed,
  }) : _stage = stage,
       _installationOk = installationOk,
       _installationFailed = installationFailed;

  final Stage _stage;
  final void Function() _installationOk;
  final Future<bool?> Function() _installationFailed;

  final _dokanScripts = const DokanScripts(
    requiredMayor: Constants.dokanMayorRequired,
    minimumRequiredVersion: Constants.dokanMinimumVersion,
  );

  DokanCheckResult get checkDokanInstallation =>
      _dokanScripts.checkDokanInstallation();

  Future<void> tryInstallDokan() async {
    final title = S.current.titleDokanMissing;
    final body = DokanNotFound(
      stage: _stage,
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(),
    );

    await _runInstallation(title, body);
  }

  Future<void> tryInstallNewerDokanMayor() async {
    final title = S.current.titleDokanInstallationFound;
    final body = DokanDifferentMayorFound(
      stage: _stage,
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(),
    );

    await _runInstallation(title, body);
  }

  Future<void> tryInstallDifferentDokanMayor() async {
    final title = S.current.titleDokanInstallationFound;
    final body = DokanOlderMayorFound(
      stage: _stage,
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(),
    );

    await _runInstallation(title, body);
  }

  TextSpan _buildLinkToDokanWebsite() =>
      Fields.linkTextSpan(S.current.messageDokan, _launchDokanWebsite);

  void _launchDokanWebsite() async {
    final title = Text('Dokan');
    await Fields.openUrl(_stage, title, Constants.dokanUrl);
  }

  Future<void> _runInstallation(String title, Widget body) async {
    final install =
        await _stage.showDialog<bool?>(
          barrierDismissible: false,
          builder: (BuildContext context) =>
              ActionsDialog(title: title, body: body),
        ) ??
        false;

    if (install == false) return;

    final installationResult = await _dokanScripts.runDokanMsiInstallation();
    if (installationResult == false) {
      await _installationFailed.call();
      return;
    }

    _installationOk.call();
  }
}
