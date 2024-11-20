import 'package:ouisync/ouisync.dart' show AccessMode, LocalSecret;
export 'package:ouisync/ouisync.dart' show AccessMode;

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

sealed class Access {}

class BlindAccess implements Access {}

class ReadAccess implements Access {
  LocalSecret localSecret;

  ReadAccess(this.localSecret);
}

class WriteAccess implements Access {
  LocalSecret localSecret;

  WriteAccess(this.localSecret);
}

//--------------------------------------------------------------------
