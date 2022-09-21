extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension UriExtension on Uri {
  bool isValidOuiSyncUri() {
    final isHttps = isScheme('HTTPS');
    final isOuiSync = host == 'ouisync.net';
    final hasCorrectPath = path == '/r';
    final hasToken = hasFragment;

    return isHttps && hasCorrectPath && isOuiSync && hasToken;
  }
}
