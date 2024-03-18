import 'dart:io' as io;

import 'package:path/path.dart' as p;

import 'constants.dart';
import 'log.dart';

const String msiOuisyncAssetsFolder = 'data\\ouisync_assets';

class DokanCheck with AppLogger {
  const DokanCheck({
    required this.requiredMayor,
    required this.minimumRequiredVersion,
  });

  final String requiredMayor;
  final String minimumRequiredVersion;

  String buildPathToFile(String fileName) {
    final root = p.dirname(io.Platform.resolvedExecutable);
    return p.join(root, msiOuisyncAssetsFolder, fileName);
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
      loggy.app('Checking Dokan installation failed: $error');

      return DokanCheckResult(result: null, error: error);
    }

    final scriptResult = resultCheckDokanInstallation.stdout as String;
    final dokanResult = dokanResultFromString(scriptResult.trim());

    return DokanCheckResult(result: dokanResult);
  }

  /// We use a PowerShell script instead of directly executing the msiexec call
  /// so we can get exit code, sdtour and stderr and log any error better.
  /// When executing the msiexec directly we only seem to get the exit code.
  /// TODO: Test and see if just the exit code is enough in this case.
  bool? runDokanMsiInstallation() {
    final scriptFilePath = buildPathToFile('install_dokan.ps1');
    final script = 'powershell.exe -executionpolicy bypass -File '
        '"$scriptFilePath"';

    final msiPath = buildPathToFile('Dokan_x64.msi');
    final args = [msiPath];

    final processResult = io.Process.runSync(script, args);

    final exitCode = processResult.exitCode;
    final stdOut = ((processResult.stdout as String?) ?? '').trim();
    final stdError = ((processResult.stderr as String?) ?? '').trim();

    if (exitCode != 0) {
      loggy.app(
        'Checking Dokan installation failed.\n'
        'stderr:\n$stdError\n'
        'stdout:\n$stdOut\n',
      );

      return false;
    }

    if (stdError.isNotEmpty) {
      loggy.app(
        'The user say no to run the Dokan installation as admin.\n'
        'stderr:\n$stdError\n',
      );

      return null;
    }

    if (stdOut.isNotEmpty && stdOut != '0') {
      switch (stdOut) {
        case '1602':
          loggy.app(
              'The user canceled the Dokan MSI execution before it was done\n'
              'stdout:\n$stdOut\n');
          break;
        case '1603':
          loggy.app(
            'The Dokan MSI installation failed because there is a '
            'Windows reboot still pending after a Dokan driver uninstall, or'
            ' it is already installed\n'
            'stdout:\n$stdOut\n',
          );
          break;
        default:
          loggy.app(
            'There was an error while trying to install the Dokan MSI.\n'
            'stdout:\n$stdOut\n',
          );
          break;
      }

      return null;
    }

    if (stdOut == '0') {
      loggy.app('Dokan MSI installation successful');
    }

    return true;
  }
}

class DokanCheckResult {
  final DokanResult? result;
  final String? error;

  const DokanCheckResult({required this.result, this.error});
}
