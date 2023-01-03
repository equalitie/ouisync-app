import 'package:biometric_storage/biometric_storage.dart';

class Biometrics {
  static final BiometricStorage _storage = BiometricStorage();

  Biometrics._();

  static Future<BiometricStorageFile> _getStorageFileForKey(String key) async {
    return _storage.getStorage(key);
  }

  static Future<BiometricsResult> addRepositoryPassword(
      {required String repositoryName, required String password}) async {
    try {
      final storageFile = await _getStorageFileForKey(repositoryName);
      await storageFile.write(password);
    } on Exception catch (e) {
      return BiometricsResult(value: null, exception: e);
    }

    return BiometricsResult(value: null);
  }

  static Future<BiometricsResult> getRepositoryPassword(
      {required String repositoryName}) async {
    String? password;
    try {
      final storageFile = await _getStorageFileForKey(repositoryName);
      password = await storageFile.read();
    } on Exception catch (e) {
      return BiometricsResult(value: null, exception: e);
    }

    return BiometricsResult(value: password);
  }

  static Future<BiometricsResult> deleteRepositoryPassword(
      {required String repositoryName}) async {
    try {
      final storageFile = await _getStorageFileForKey(repositoryName);
      await storageFile.delete();
    } on Exception catch (e) {
      return BiometricsResult(value: null, exception: e);
    }

    return BiometricsResult(value: null);
  }
}

class BiometricsResult {
  BiometricsResult({required this.value, this.exception});

  final String? value;
  final Exception? exception;
}
