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
  UnlockedAccess? get asUnlocked;
}

sealed class UnlockedAccess implements Access {
  UnlockedAccessMode get unlockedMode;
  LocalSecret get localSecret;

  UnlockedAccess copyWithLocalSecret(LocalSecret secret);
}

//---------------------------------

class BlindAccess implements Access {
  @override
  AccessMode get mode => AccessMode.blind;

  @override
  UnlockedAccess? get asUnlocked => null;
}

class ReadAccess implements Access, UnlockedAccess {
  @override
  LocalSecret localSecret;

  ReadAccess(this.localSecret);

  @override
  AccessMode get mode => AccessMode.read;

  @override
  UnlockedAccessMode get unlockedMode => ReadAccessMode();

  @override
  ReadAccess? get asUnlocked => this;

  @override
  ReadAccess copyWithLocalSecret(LocalSecret secret) => ReadAccess(secret);
}

class WriteAccess implements Access, UnlockedAccess {
  @override
  LocalSecret localSecret;

  WriteAccess(this.localSecret);

  @override
  AccessMode get mode => AccessMode.write;

  @override
  UnlockedAccessMode get unlockedMode => WriteAccessMode();

  @override
  WriteAccess? get asUnlocked => this;

  @override
  WriteAccess copyWithLocalSecret(LocalSecret secret) => WriteAccess(secret);
}

//--------------------------------------------------------------------
