import 'package:ouisync/ouisync.dart' show AccessMode;
export 'package:ouisync/ouisync.dart' show AccessMode;

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
