import 'dart:io';

class Strings {
  Strings._();


  static String get rootPath {
    return Platform.isWindows ? '\\' : '/';
  }
  //static const String rootPath = '/';
  static const String atSymbol = '@';

  // Dialogs

  static const String labelListenerEndpoint = 'Endpoint:'; // TODO:  Translate?
  static const String labelDHTv4Endpoint = 'DHT IPv4:';
  static const String labelDHTv6Endpoint = 'DHT IPv6:';
  
  static const String messageErrorRepositoryPasswordValidation =
      'Please enter a password'; // TODO: Find a way to pass this as default parameter
  static const String messageErrorRetypePassword =
      'The password and retyped password doesn\'t '
      'match';// TODO: Find a way to pass this as default parameter

  // Buttons text

  static const String actionDeleteFile = 'Delete file'; // TODO: replace in the switch statement in dialogs.dartL149

  static const String emptyIPv4 = '0.0.0.0';
  static const String undeterminedIPv6 = '[::]';

  static const String errorEntryNotFound = 'entry not found'; // TODO:  Move to an error specific class maybe?
}
