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
    minimumRequiredVersion: Constants.dokanMinimunVersion,
  );

  DokanCheckResult get checkDokanInstallation =>
      _dokanScripts.checkDokanInstallation();

  Future<void> tryInstallDokan() async {
    final title = S.current.titleDokanMissing;
    final body = DokanNotFound(
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(_context),
    );

    return _runInstallation(title, body);
  }

  Future<void> tryInstallNewerDokanMayor() async {
    final title = S.current.titleDokanInstallationFound;
    final body = DokanDifferentMayorFound(
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(_context),
    );

    return _runInstallation(title, body);
  }

  Future<void> tryInstallDifferentDokanMayor() async {
    final title = S.current.titleDokanInstallationFound;
    final body = DokanOlderMayorFound(
      linkLaunchDokanGitHub: _buildLinkToDokanWebsite(_context),
    );

    return _runInstallation(title, body);
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

  Future<void> _runInstallation(String title, Widget body) => showDialog<bool?>(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) => ActionsDialog(
          title: title,
          body: body,
        ),
      ).then(
        (bool? install) async {
          if (install == null) return;

          if (install) {
            final installationResult =
                await _dokanScripts.runDokanMsiInstallation();

            installationResult == true
                ? _installationOk.call()
                : await _installationFailed.call();
          }
        },
      );
}
