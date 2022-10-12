class Strings {
  Strings._();

  static const String root = '/';
  static const String atSymbol = '@';

  // Dialogs

  // TODO: Translate these:

  static const String connectionType = 'Connection type';

  static const String labelInternalIP = 'Internal IP';
  static const String labelExternalIP = 'External IP';

  static const String labelLocalIPv4 = 'Local IPv4';
  static const String labelLocalIPv6 = 'Local IPv6';

  static const String labelTcpListenerEndpointV4 = 'Listening on TCP IPv4';
  static const String labelTcpListenerEndpointV6 = 'Listening on TCP IPv6';

  static const String labelQuicListenerEndpointV4 =
      'Listening on QUIC/UDP IPv4';
  static const String labelQuicListenerEndpointV6 =
      'Listening on QUIC/UDP IPv6';

  static const String messageErrorRepositoryPasswordValidation =
      'Please enter a password'; // TODO: Find a way to pass this as default parameter

  // Buttons text

  static const String actionDeleteFile =
      'Delete file'; // TODO: replace in the switch statement in dialogs.dartL149

  static const String errorEntryNotFound =
      'entry not found'; // TODO:  Move to an error specific class maybe?
}
