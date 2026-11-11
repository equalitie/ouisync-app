import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/utils/master_key.dart';

void main() {
  late _FakeStorage storage;
  late _FakeLegacyStorage legacyStorage;

  setUp(() {
    storage = _FakeStorage();
    legacyStorage = _FakeLegacyStorage();
  });

  Future<MasterKey> init({bool android = true}) => MasterKey.initWith(
    storage: storage,
    legacyStorage: android ? legacyStorage : null,
  );

  test('generates and stores a new key when there is none', () async {
    final key = await init();

    expect(storage.value, isNotNull);
    expect(_encode(key), equals(storage.value));
  });

  test('uses the stored key', () async {
    final stored = MasterKey.generateKey();
    storage.value = stored;

    final key = await init();

    expect(_encode(key), equals(stored));
    expect(storage.value, equals(stored));
  });

  test('migrates the legacy key', () async {
    final legacy = MasterKey.generateKey();
    legacyStorage.value = legacy;

    final key = await init();

    expect(_encode(key), equals(legacy));
    expect(storage.value, equals(legacy));
    expect(legacyStorage.value, isNull);
  });

  test('legacy key takes precedence over the stored one', () async {
    final legacy = MasterKey.generateKey();
    legacyStorage.value = legacy;
    storage.value = MasterKey.generateKey();

    final key = await init();

    expect(_encode(key), equals(legacy));
    expect(storage.value, equals(legacy));
    expect(legacyStorage.value, isNull);
  });

  test('fails without generating a key when the legacy key is unreadable', () async {
    legacyStorage.readError = Exception('keystore error');

    await expectLater(init(), throwsA(isA<MasterKeyUnreadable>()));

    expect(storage.value, isNull);
  });

  test('keeps the legacy key when the migrated key reads back different', () async {
    final legacy = MasterKey.generateKey();
    legacyStorage.value = legacy;
    storage.corruptWrites = true;

    await expectLater(init(), throwsA(isA<MasterKeyUnreadable>()));

    expect(legacyStorage.value, equals(legacy));
  });

  test('keeps the legacy key when writing the migrated key fails', () async {
    final legacy = MasterKey.generateKey();
    legacyStorage.value = legacy;
    storage.writeError = Exception('storage error');

    await expectLater(init(), throwsA(anything));

    expect(legacyStorage.value, equals(legacy));
  });

  test('uses the migrated key when deleting the legacy key fails', () async {
    final legacy = MasterKey.generateKey();
    legacyStorage.value = legacy;
    legacyStorage.deleteError = Exception('delete error');

    final key = await init();

    expect(_encode(key), equals(legacy));
    expect(storage.value, equals(legacy));
  });

  test('ignores the legacy storage on other platforms', () async {
    legacyStorage.value = MasterKey.generateKey();
    final stored = MasterKey.generateKey();
    storage.value = stored;

    final key = await init(android: false);

    expect(_encode(key), equals(stored));
    expect(legacyStorage.value, isNotNull);
  });
}

String _encode(MasterKey key) => base64.encode(key.secretKey.bytes);

class _FakeStorage implements MasterKeyStorage {
  String? value;
  Object? writeError;
  // Simulates a storage which doesn't return what was written.
  bool corruptWrites = false;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    if (writeError != null) {
      throw writeError!;
    }

    this.value = corruptWrites ? MasterKey.generateKey() : value;
  }
}

class _FakeLegacyStorage implements LegacyMasterKeyStorage {
  String? value;
  Object? readError;
  Object? deleteError;

  @override
  Future<String?> read() async {
    if (readError != null) {
      throw readError!;
    }

    return value;
  }

  @override
  Future<void> delete() async {
    if (deleteError != null) {
      throw deleteError!;
    }

    value = null;
  }
}
