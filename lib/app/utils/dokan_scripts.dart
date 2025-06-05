import 'dart:io' as io;

import 'package:path/path.dart' as p;

import 'constants.dart';
import 'log.dart';

const String msiAdditionalAssetsFolder = 'data\\bundled-assets';

class DokanScripts with AppLogger {
  const DokanScripts({
    required this.requiredMayor,
    required this.minimumRequiredVersion,
  });

  final String requiredMayor;
  final String minimumRequiredVersion;

  String buildPathToFile(String fileName) {
    final root = p.dirname(io.Platform.resolvedExecutable);
    return p.join(root, msiAdditionalAssetsFolder, fileName);
  }

  DokanCheckResult checkDokanInstallation() {
    final scriptFilePath = buildPathToFile('check_dokan_installation.ps1');
    final script = 'powershell.exe -executionpolicy bypass -File '
        '"$scriptFilePath"';

    final args = [
      requiredMayor,
      minimumRequiredVersion,
    ];

    final resultCheckDokanInstallation = io.Process.runSync(script, args);

    final exitCode = resultCheckDokanInstallation.exitCode;
    if (exitCode != 0) {
      final error = resultCheckDokanInstallation.stderr;
      loggy.debug('Checking Dokan installation failed: $error');

      return DokanCheckResult(result: null, error: error);
    }

    final scriptResult = resultCheckDokanInstallation.stdout as String;
    final dokanResult = dokanResultFromString(scriptResult.trim());

    return DokanCheckResult(result: dokanResult);
  }

  Future<bool?> runDokanMsiInstallation() async {
    final args = [
      '/i',
      buildPathToFile('Dokan_x64.msi'),
    ];

    final processResult = io.Process.runSync('msiexec', args);

    final exitCode = processResult.exitCode;
    final stdOut = ((processResult.stdout as String?) ?? '').trim();
    final stdError = ((processResult.stderr as String?) ?? '').trim();

    switch (exitCode) {
      case 0:
        {
          loggy.debug('Dokan MSI installation successful');
          return true;
        }
      case 1602:
        {
          loggy.debug(
              'The user canceled the Dokan MSI execution before it was done\n'
              'stdout:\n$stdOut\n');
          return null;
        }
      case 1603:
        {
          loggy.debug(
            'The Dokan MSI installation failed because there is a '
            'Windows reboot still pending after a Dokan driver uninstall, or'
            ' it is already installed\n'
            'stdout:\n$stdOut\n',
          );
          return null;
        }
      default:
        {
          loggy.debug(
            'There was an error trying to install the Dokan MSI.\n'
            'stderr:\n$stdError\n'
            'stdout:\n$stdOut\n',
          );
          return false;
        }
    }
  }
}

class DokanCheckResult {
  final DokanResult? result;
  final String? error;

  const DokanCheckResult({required this.result, this.error});
}
