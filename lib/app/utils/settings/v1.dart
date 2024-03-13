import 'dart:io' show Directory, Platform;
import 'dart:convert';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../utils.dart';
import '../master_key.dart';
import 'v0/v0.dart' as v0;

class DatabaseId extends Equatable {
  final String _id;
  DatabaseId(String databaseId) : _id = databaseId;

  @override
  String toString() => _id;

  @override
  List<Object> get props => [_id];
}

//--------------------------------------------------------------------

sealed class AuthMode {
  Map _toJson();

  // May throw.
  static AuthMode fromJson(dynamic data) {
    var decoded = _AuthModeBlindOrManual._fromJson(data);
    if (decoded != null) return decoded;
    decoded = _AuthModePasswordStoredOnDevice._fromJson(data);
    if (decoded != null) return decoded;
    decoded = _AuthModeKeyStoredOnDevice._fromJson(data);
    if (decoded == null) throw FailedToParseAuthMode();
    return decoded;
  }
}

class _AuthModeBlindOrManual extends AuthMode {
  static String _tag() => "password-provided-by-user";

  @override
  Map _toJson() => {
        _tag(): null,
      };

  static AuthMode? _fromJson(dynamic data) {
    if (data.containsKey(_tag())) {
      return _AuthModeBlindOrManual();
    } else {
      return null;
    }
  }
}

// This is a legacy AuthMode, we used to generate high entropy (24 characters:
// upper and lower case letters, numbers, special chars) passwords and store
// those encrypted.  Because those passwords were high entropy, the fact that
// we did not run them through a password hashing function before encryption
// perhaps was not such a tragedy. And they still need to go through Argon2
// when passed to Ouisync library. Still, LocalSecretKey has much higher
// entropy (256-bits) and so only that is now used.  TODO: Should we force
// reset existing repos that use this legacy auth mode to use secret keys?
class _AuthModePasswordStoredOnDevice extends AuthMode {
  final String encryptedPassword;
  final bool confirmWithBiometrics;

  _AuthModePasswordStoredOnDevice(
      this.encryptedPassword, this.confirmWithBiometrics);

  _AuthModePasswordStoredOnDevice copyWith(
          {String? encryptedPassword, bool? confirmWithBiometrics}) =>
      _AuthModePasswordStoredOnDevice(
          encryptedPassword ?? this.encryptedPassword,
          confirmWithBiometrics ?? this.confirmWithBiometrics);

  // May throw.
  Future<LocalPassword> getRepositoryPassword(MasterKey masterKey) async {
    final decrypted = await masterKey.decrypt(encryptedPassword);
    if (decrypted == null) throw FailedToDecryptError();
    return LocalPassword(decrypted);
  }

  static String _tag() => "password-stored-on-device";

  @override
  Map _toJson() => {
        _tag(): {
          "encryptedPassword": encryptedPassword,
          "confirmWithBiometrics": confirmWithBiometrics,
        }
      };

  static AuthMode? _fromJson(dynamic data) {
    final values = data[_tag()];
    if (values == null) return null;
    String? encryptedPassword = values["encryptedPassword"];
    if (encryptedPassword == null) return null;
    bool? confirmWithBiometrics = values["confirmWithBiometrics"];
    if (confirmWithBiometrics == null) return null;
    return _AuthModePasswordStoredOnDevice(
        encryptedPassword, confirmWithBiometrics);
  }
}

class _AuthModeKeyStoredOnDevice extends AuthMode {
  final String encryptedKey;
  final bool confirmWithBiometrics;

  _AuthModeKeyStoredOnDevice(this.encryptedKey, this.confirmWithBiometrics);

  _AuthModeKeyStoredOnDevice copyWith(
          {String? encryptedKey, bool? confirmWithBiometrics}) =>
      _AuthModeKeyStoredOnDevice(encryptedKey ?? this.encryptedKey,
          confirmWithBiometrics ?? this.confirmWithBiometrics);

  // May throw.
  Future<LocalSecretKey> getRepositoryPassword(MasterKey masterKey) async {
    final decrypted = await masterKey.decryptBytes(encryptedKey);
    if (decrypted == null) throw FailedToDecryptError();
    return LocalSecretKey(decrypted);
  }

  static String _tag() => "key-stored-on-device";

  @override
  Map _toJson() => {
        _tag(): {
          "encryptedKey": encryptedKey,
          "confirmWithBiometrics": confirmWithBiometrics,
        }
      };

  static AuthMode? _fromJson(dynamic data) {
    final values = data[_tag()];
    if (values == null) return null;
    String? encryptedKey = values["encryptedKey"];
    if (encryptedKey == null) return null;
    bool? confirmWithBiometrics = values["confirmWithBiometrics"];
    if (confirmWithBiometrics == null) return null;
    return _AuthModeKeyStoredOnDevice(encryptedKey, confirmWithBiometrics);
  }
}

//--------------------------------------------------------------------

class SettingsRepoEntry {
  AuthMode authMode;
  RepoLocation location;

  String get name => location.name;
  Directory get dir => location.dir;

  SettingsRepoEntry(this.authMode, this.location);

  Map toJson() {
    return {
      'authMode': authMode._toJson(),
      'location': location.path(),
    };
  }

  // May throw.
  factory SettingsRepoEntry.fromJson(dynamic data) {
    final authMode = data['authMode'];
    final location = data['location'];
    if (authMode == null || location == null) {
      throw FailedToParseSettingsRepoEntry();
    }
    return SettingsRepoEntry(
      AuthMode.fromJson(authMode),
      RepoLocation.fromDbPath(location),
    );
  }
}

//--------------------------------------------------------------------
Future<AuthMode> _secretToAuthModeStoredOnDevice(
    LocalSecretKey key, MasterKey masterKey, bool requireAuthentication) async {
  final encryptedKey = await masterKey.encryptBytes(key.bytes);
  return _AuthModeKeyStoredOnDevice(encryptedKey, requireAuthentication);
}
//--------------------------------------------------------------------

class RepoSettings {
  final Settings _settings;
  final DatabaseId _databaseId;
  final SettingsRepoEntry _entry;

  RepoSettings(this._settings, this._databaseId, this._entry);

  RepoLocation get location => _entry.location;
  DatabaseId get databaseId => _databaseId;
  String get name => _entry.name;
  Directory get dir => _entry.dir;

  Future<void> setAuthModePasswordProvidedByUser() async {
    _entry.authMode = _AuthModeBlindOrManual();
    await _settings._storeRoot();
  }

  Future<void> setAuthModeSecretStoredOnDevice(
      LocalSecretKey secret, bool requireAuthentication) async {
    _entry.authMode = await _secretToAuthModeStoredOnDevice(
        secret, _settings._masterKey, requireAuthentication);
    await _settings._storeRoot();
  }

  bool hasLocalSecret() {
    return _entry.authMode is _AuthModePasswordStoredOnDevice ||
        _entry.authMode is _AuthModeKeyStoredOnDevice;
  }

  bool shouldCheckBiometricsBeforeUnlock() {
    final authMode = _entry.authMode;
    if (authMode is _AuthModePasswordStoredOnDevice) {
      return authMode.confirmWithBiometrics;
    }
    if (authMode is _AuthModeKeyStoredOnDevice) {
      return authMode.confirmWithBiometrics;
    }
    return false;
  }

  Future<void> setLocation(RepoLocation location) async {
    _entry.location = location;
    await _settings._storeRoot();
  }

  // Return true if changed.
  Future<bool> setConfirmWithBiometrics(bool value) async {
    final authMode = _entry.authMode;

    switch (authMode) {
      case _AuthModeBlindOrManual():
        return false;
      case _AuthModePasswordStoredOnDevice():
        if (authMode.confirmWithBiometrics == value) {
          return false;
        }
        _entry.authMode = authMode.copyWith(confirmWithBiometrics: value);
      case _AuthModeKeyStoredOnDevice():
        if (authMode.confirmWithBiometrics == value) {
          return false;
        }
        _entry.authMode = authMode.copyWith(confirmWithBiometrics: value);
    }

    await _settings._storeRoot();
    return true;
  }

  /// May throw if the function failed to decrypt the stored key.
  /// Returns null if the authMode is _AuthModeBlindOrManual.
  Future<LocalSecret?> getLocalSecret() async {
    final authMode = _entry.authMode;
    switch (authMode) {
      case _AuthModeBlindOrManual():
        return null;
      case _AuthModePasswordStoredOnDevice():
        final pwd =
            await _settings._masterKey.decrypt(authMode.encryptedPassword);
        if (pwd == null) throw FailedToDecryptError();
        return LocalPassword(pwd);
      case _AuthModeKeyStoredOnDevice():
        final key =
            await _settings._masterKey.decryptBytes(authMode.encryptedKey);
        if (key == null) throw FailedToDecryptError();
        return LocalSecretKey(key);
    }
  }

  PasswordMode get passwordMode => !hasLocalSecret()
      ? PasswordMode.manual
      : shouldCheckBiometricsBeforeUnlock()
          ? PasswordMode.bio
          : PasswordMode.none;
}

//--------------------------------------------------------------------

class SettingsRoot {
  static const int version = 1;

  // Did the user accept the eQ values?
  bool acceptedEqualitieValues = false;
  // Show onboarding (will flip to false once shown).
  bool showOnboarding = true;
  bool launchAtStartup = true;
  bool enableSyncOnMobileInternet = true;
  int? highestSeenProtocolNumber;
  // NOTE: In order to preserve plausible deniability, once the current repo is
  // locked in _AuthModeBlindOrManual, this value must set to `null`.
  DatabaseId? currentRepo;
  Map<DatabaseId, SettingsRepoEntry> repos = {};

  SettingsRoot._();

  SettingsRoot({
    required this.acceptedEqualitieValues,
    required this.showOnboarding,
    required this.launchAtStartup,
    required this.enableSyncOnMobileInternet,
    required this.highestSeenProtocolNumber,
    required this.currentRepo,
    required this.repos,
  });

  Map<String, dynamic> toJson() {
    final r = {
      'version': version,
      'acceptedEqualitieValues': acceptedEqualitieValues,
      'showOnboarding': showOnboarding,
      'launchAtStartup': launchAtStartup,
      'enableSyncOnMobileInternet': enableSyncOnMobileInternet,
      'highestSeenProtocolNumber': highestSeenProtocolNumber,
      'currentRepo': currentRepo?.toString(),
      'repos': <String, dynamic>{
        for (var kv in repos.entries) kv.key.toString(): kv.value.toJson()
      },
    };
    return r;
  }

  factory SettingsRoot.fromJson(String? s) {
    if (s == null) {
      return SettingsRoot._();
    }

    final data = json.decode(s);

    int inputVersion = data['version'];

    if (inputVersion != version) {
      throw "Invalid settings version ($inputVersion)";
    }

    final repos = <DatabaseId, SettingsRepoEntry>{
      for (var kv in data['repos']!.entries)
        DatabaseId(kv.key): SettingsRepoEntry.fromJson(kv.value)
    };

    String? currentRepo = data['currentRepo'];

    return SettingsRoot(
      acceptedEqualitieValues: data['acceptedEqualitieValues']!,
      showOnboarding: data['showOnboarding']!,
      launchAtStartup: data['launchAtStartup']!,
      enableSyncOnMobileInternet: data['enableSyncOnMobileInternet']!,
      highestSeenProtocolNumber: data['highestSeenProtocolNumber'],
      currentRepo: currentRepo != null ? DatabaseId(currentRepo) : null,
      repos: repos,
    );
  }
}

class Settings with AppLogger {
  static const String settingsKey = "settings";

  final SettingsRoot _root;
  final SharedPreferences _prefs;
  final MasterKey _masterKey;

  //------------------------------------------------------------------

  Settings._(this._root, this._prefs, this._masterKey);

  Future<void> _storeRoot() async {
    await _prefs.setString(settingsKey, json.encode(_root.toJson()));
  }

  static Future<Settings> init(
      SharedPreferences prefs, MasterKey masterKey) async {
    final json = prefs.getString(settingsKey);
    final root = SettingsRoot.fromJson(json);

    if (prefs.getKeys().length > 1) {
      // The previous migration did not finish correctly, prefs should only
      // `settingsKey` key after success.
      await Settings._removeValuesFromV0(prefs);
    }

    return Settings._(root, prefs, masterKey);
  }

  static Future<Settings> initMigrateFromV0(
      SharedPreferences prefs, MasterKey masterKey) async {
    final s0 = await v0.Settings.init(prefs);
    final eqValues = s0.getEqualitieValues();
    final showOnboarding = s0.getShowOnboarding();
    final launchAtStartup = s0.getLaunchAtStartup();
    final enableSyncOnMobileInternet = s0.getSyncOnMobileEnabled();
    final highestSeenProtocolNumber = s0.getHighestSeenProtocolNumber();
    final currentRepo = s0.getDefaultRepo();

    final Map<DatabaseId, SettingsRepoEntry> repos = HashMap();

    for (final repo in s0.repos()) {
      final id = DatabaseId(repo.databaseId);
      final auth = s0.getAuthenticationMode(repo.name);
      AuthMode? newAuth;
      v0.SecureStorage? oldPwdStorage;
      switch (auth) {
        case v0.AuthMode.manual:
          newAuth = _AuthModeBlindOrManual();
        case v0.AuthMode.version1:
        case v0.AuthMode.version2:
          oldPwdStorage = v0.SecureStorage(databaseId: id);
          final password = await oldPwdStorage.tryGetPassword(
              authMode: v0.AuthMode.noLocalPassword);
          newAuth = _AuthModePasswordStoredOnDevice(
              (await masterKey.encrypt(password!)), true);
        case v0.AuthMode.noLocalPassword:
          oldPwdStorage = v0.SecureStorage(databaseId: id);
          final password = await oldPwdStorage.tryGetPassword(
              authMode: v0.AuthMode.noLocalPassword);
          newAuth = _AuthModePasswordStoredOnDevice(
              (await masterKey.encrypt(password!)), false);
      }
      // Remove the password from the old storage.
      if (oldPwdStorage != null) {
        await oldPwdStorage.deletePassword();
      }
      // The old settings did not include the '.db' extension in RepoLocation.
      final pathWithoutExt = repo.info.path();
      final locationWithExt = RepoLocation.fromDbPath("$pathWithoutExt.db");
      repos[id] = SettingsRepoEntry(newAuth, locationWithExt);
    }

    final root = SettingsRoot(
      acceptedEqualitieValues: eqValues,
      showOnboarding: showOnboarding,
      launchAtStartup: launchAtStartup,
      enableSyncOnMobileInternet: enableSyncOnMobileInternet,
      highestSeenProtocolNumber: highestSeenProtocolNumber,
      currentRepo: (currentRepo != null) ? DatabaseId(currentRepo) : null,
      repos: repos,
    );

    final s1 = Settings._(root, prefs, masterKey);

    // The order of these operations is important to avoid data loss.
    await s1._storeRoot();
    await Settings._removeValuesFromV0(prefs);

    return s1;
  }

  // Remove keys that don't belong to this version of settings.  It's important
  // to do this **after** we've stored the root and version number of this
  // settings.
  static Future<void> _removeValuesFromV0(SharedPreferences prefs) async {
    for (final key in prefs.getKeys()) {
      if (key != settingsKey) {
        await prefs.remove(key);
      }
    }
  }

  //------------------------------------------------------------------

  bool getEqualitieValues() => _root.acceptedEqualitieValues;

  Future<void> setEqualitieValues(bool value) async {
    _root.acceptedEqualitieValues = value;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  bool getShowOnboarding() => _root.showOnboarding;

  Future<void> setShowOnboarding(bool value) async {
    _root.showOnboarding = value;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  bool getLaunchAtStartup() => _root.launchAtStartup;

  Future<void> setLaunchAtStartup(bool value) async {
    _root.launchAtStartup = value;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  bool getSyncOnMobileEnabled() => _root.enableSyncOnMobileInternet;

  Future<void> setSyncOnMobileEnabled(bool enable) async {
    _root.enableSyncOnMobileInternet = enable;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  int? getHighestSeenProtocolNumber() => _root.highestSeenProtocolNumber;

  Future<void> setHighestSeenProtocolNumber(int number) async {
    _root.highestSeenProtocolNumber = number;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  Iterable<RepoSettings> repos() =>
      _root.repos.entries.map((kv) => RepoSettings(this, kv.key, kv.value));

  //------------------------------------------------------------------

  RepoSettings? repoSettingsByLocation(RepoLocation location) {
    for (final kv in _root.repos.entries) {
      if (kv.value.location == location) {
        return RepoSettings(this, kv.key, kv.value);
      }
    }

    return null;
  }

  RepoSettings? repoSettingsById(DatabaseId repoId) {
    final entry = _root.repos[repoId];
    if (entry == null) return null;
    return RepoSettings(this, repoId, entry);
  }

  //------------------------------------------------------------------

  RepoLocation? getDefaultRepo() {
    final current = _root.currentRepo;
    if (current == null) {
      return null;
    } else {
      return _root.repos[current]?.location;
    }
  }

  Future<void> setDefaultRepo(RepoLocation? location) async {
    if (location == null) {
      if (_root.currentRepo == null) {
        return;
      }
      _root.currentRepo = null;
    } else {
      final rs = repoSettingsByLocation(location);
      if (rs == null || rs.location == location) {
        return;
      }
      // We must not set repositories for which the user provides the password
      // as "default" because they must be indistinguishable from blind
      // repositories.
      if (rs.passwordMode == PasswordMode.manual) {
        return;
      }
      _root.currentRepo = rs.databaseId;
    }

    await _storeRoot();
  }
  //------------------------------------------------------------------

  Future<void> renameRepository(
      RepoSettings repoSettings, RepoLocation newLocation) async {
    if (repoSettings.location == newLocation) {
      // TODO: This should just return without throwing, but check where it's used.
      throw 'Failed to rename repo: "${newLocation.path()}" to same name';
    }

    if (repoSettingsByLocation(newLocation) != null) {
      throw 'Failed to rename repo: "${newLocation.path()}" already exists';
    }

    repoSettings._entry.location = newLocation;
    await _storeRoot();
  }

  //------------------------------------------------------------------

  Future<RepoSettings?> addRepoWithSecretStoredOnDevice(
      RepoLocation location, LocalSecretKey secret, DatabaseId databaseId,
      {required requireBiometricCheck}) async {
    final authMode = await _secretToAuthModeStoredOnDevice(
        secret, _masterKey, requireBiometricCheck);
    return await _addRepo(location, databaseId: databaseId, authMode: authMode);
  }

  Future<RepoSettings?> addRepoWithUserProvidedPassword(
    RepoLocation location,
    DatabaseId databaseId,
  ) async {
    final authMode = _AuthModeBlindOrManual();
    return await _addRepo(location, databaseId: databaseId, authMode: authMode);
  }

  Future<RepoSettings?> _addRepo(
    RepoLocation location, {
    required DatabaseId databaseId,
    required AuthMode authMode,
  }) async {
    if (_root.repos.containsKey(databaseId)) {
      loggy.debug('Settings already contains a repo with the id "$databaseId"');
      return null;
    }

    if (repoSettingsByLocation(location) != null) {
      loggy.debug(
          'Settings already contains a repo with the location "${location.path()}"');
      return null;
    }

    final entry = SettingsRepoEntry(authMode, location);
    _root.repos[databaseId] = entry;

    await _storeRoot();

    return RepoSettings(this, databaseId, entry);
  }

  //------------------------------------------------------------------

  Future<void> forgetRepository(DatabaseId databaseId) async {
    if (_root.currentRepo == databaseId) {
      _root.currentRepo = null;
    }
    _root.repos.remove(databaseId);
    await _storeRoot();
  }

  //------------------------------------------------------------------

  Future<Directory> defaultRepoLocation() async {
    // TODO
    try {
      // Docs says this throws on non Android systems.
      // https://pub.dev/documentation/path_provider/latest/path_provider/getExternalStorageDirectory.html
      //
      // On Android this function will most likely return the user accessible
      // directory on phone's internal memory (i.e. not the SDCard). The user
      // will see it as "<DEVICE>/Phone/Android/data/org.equalitie.ouisync/files"
      //
      // Everything in this folder is deleted when the app is un/re-installed.
      final dir = await path_provider.getExternalStorageDirectory();
      if (dir != null) {
        return dir;
      }
    } catch (_) {}

    // This path is not accessible by the user using a file explorer and it
    // also gets deleted when the app is un/re-installed.
    final alternativeDir =
        await path_provider.getApplicationDocumentsDirectory();

    if (Platform.isAndroid) {
      return alternativeDir;
    }

    final context = p.Context(style: p.Style.posix);

    final nonAndroidAlternativePath =
        context.join(alternativeDir.path, 'Ouisync');

    return await Directory(nonAndroidAlternativePath).create();
  }

  //------------------------------------------------------------------

  String? getMountPoint() => _defaultMountPoint();

  void debugPrint() {
    print("============== Settings ===============");
    for (final kv in _root.repos.entries) {
      print("=== ${kv.key}");
    }
    print("=======================================");
  }
}

String? _defaultMountPoint() {
  if (Platform.isLinux || Platform.isMacOS) {
    final home = Platform.environment['HOME'];

    if (home == null) {
      return null;
    }

    return '$home/Ouisync';
  } else if (Platform.isWindows) {
    return 'O:';
  } else {
    return null;
  }
}

sealed class SettingsError {}

class FailedToDecryptError extends SettingsError {}

class FailedToParseAuthMode extends SettingsError {}

class FailedToParseSettingsRepoEntry extends SettingsError {}

class StoringPasswordsIsNoLongerSupported extends SettingsError {}
