import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart'
    show Constants, DokanScripts, DokanCheckResult, Fields;
import '../widgets.dart'
    show
        ActionsDialog,
        DokanDifferentMayorFound,
        DokanNotFound,
        DokanOlderMayorFound;

class DokanValidation {
  const DokanValidation(
    BuildContext context, {
    required void Function() installationOk,
    required Future<bool?> Function() installationFailed,
  })  : _context = context,
        _installationOk = installationOk,
        _installationFailed = installationFailed;

  final BuildContext _context;
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
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(_context),
    );

    await _runInstallation(title, body);
  }

  Future<void> tryInstallNewerDokanMayor() async {
    final title = S.current.titleDokanInstallationFound;
    final body = DokanDifferentMayorFound(
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(_context),
    );

    await _runInstallation(title, body);
  }

  Future<void> tryInstallDifferentDokanMayor() async {
    final title = S.current.titleDokanInstallationFound;
    final body = DokanOlderMayorFound(
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(_context),
    );

    await _runInstallation(title, body);
  }

  TextSpan _buildLinkToDokanWebsite(BuildContext context) =>
      Fields.linkTextSpan(
        _context,
        S.current.messageDokan,
        _launchDokanWebsite,
      );

  void _launchDokanWebsite(BuildContext context) async {
    final title = Text('Dokan');
    await Fields.openUrl(context, title, Constants.dokanUrl);
  }

  Future<void> _runInstallation(String title, Widget body) async {
    final install = await showDialog<bool?>(
          context: _context,
          barrierDismissible: false,
          builder: (BuildContext context) => ActionsDialog(
            title: title,
            body: body,
          ),
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
