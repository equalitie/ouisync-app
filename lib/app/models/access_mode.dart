import 'package:ouisync/ouisync.dart' show AccessMode, LocalSecret;
export 'package:ouisync/ouisync.dart' show AccessMode;
import '../../generated/l10n.dart' show S;

//--------------------------------------------------------------------

extension AccessModeLocalizedExtension on AccessMode {
  String get localized {
    switch (this) {
      case AccessMode.blind:
        return S.current.accessModeBlindLabel;
      case AccessMode.read:
        return S.current.accessModeReadLabel;
      case AccessMode.write:
        return S.current.accessModeWriteLabel;
    }
  }
}

//--------------------------------------------------------------------

sealed class UnlockedAccessMode {
  bool get canRead;
  bool get canWrite;
  AccessMode get general;
}

class ReadAccessMode implements UnlockedAccessMode {
  @override
  bool get canRead => true;

  @override
  bool get canWrite => false;

  @override
  AccessMode get general => AccessMode.read;
}

class WriteAccessMode implements UnlockedAccessMode {
  @override
  bool get canRead => true;

  @override
  bool get canWrite => true;

  @override
  AccessMode get general => AccessMode.write;
}

//--------------------------------------------------------------------

sealed class Access {
  AccessMode get mode;
}

class BlindAccess implements Access {
  @override
  AccessMode get mode => AccessMode.blind;
}

class ReadAccess implements Access {
  LocalSecret localSecret;

  ReadAccess(this.localSecret);

  @override
  AccessMode get mode => AccessMode.read;
}

class WriteAccess implements Access {
  LocalSecret localSecret;

  WriteAccess(this.localSecret);

  @override
  AccessMode get mode => AccessMode.write;
}

//--------------------------------------------------------------------
