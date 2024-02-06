import 'dart:io' show Directory, Platform;
import 'dart:convert';
import 'dart:collection';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../utils.dart';
import '../../master_key.dart';
import 'v0/v0.dart' as v0;

class DatabaseId {
  String _id;
  DatabaseId(String databaseId) : _id = databaseId {}

  @override
  String toString() => _id;
}

//--------------------------------------------------------------------

abstract class _AuthMode {
  Map _toJson();

  static _AuthMode? _fromJson(dynamic data) {
    var decoded = _AuthModePasswordProvidedByUser._fromJson(data);
    if (decoded != null) return decoded;
    return _AuthModePasswordStoredOnDevice._fromJson(data);
  }
}

class _AuthModePasswordProvidedByUser extends _AuthMode {
  static String _tag() => "password-provided-by-user";

  @override
  Map _toJson() => {
        _tag(): null,
      };

  static _AuthMode? _fromJson(dynamic data) {
    if (data.containsKey(_tag())) return _AuthModePasswordProvidedByUser();
  }
}

class _AuthModePasswordStoredOnDevice extends _AuthMode {
  final String encryptedPwd;
  final bool confirmWithBiometrics;

  _AuthModePasswordStoredOnDevice(
      this.encryptedPwd, this.confirmWithBiometrics);

  // Returns `null` if the decryption fails. Note that this means an error and
  // it is *not* the case that the user simply chose not to store the password
  // on the device. The latter should be handled by the
  // `_AuthModePasswordStoredOnDevice` class.
  String? getRepositoryPassword(MasterKey masterKey) =>
      masterKey.decrypt(encryptedPwd);

  static String _tag() => "password-stored-on-device";

  @override
  Map _toJson() => {
        _tag(): {
          "encryptedPwd": encryptedPwd,
          "confirmWithBiometrics": confirmWithBiometrics,
        }
      };

  static _AuthMode? _fromJson(dynamic data) {
    final values = data[_tag()];
    if (values == null) return null;
    String? encryptedPwd = values["encryptedPwd"];
    if (encryptedPwd == null) return null;
    bool? confirmWithBiometrics = values["confirmWithBiometrics"];
    if (confirmWithBiometrics == null) return null;
    return _AuthModePasswordStoredOnDevice(encryptedPwd, confirmWithBiometrics);
  }
}

//--------------------------------------------------------------------

class _SettingsRepoEntry {
  _AuthMode authMode;
  RepoLocation location;

  String get name => location.name;
  Directory get dir => location.dir;

  _SettingsRepoEntry(this.authMode, this.location);

  Map toJson() {
    return {
      'authMode': authMode._toJson(),
      'location': location.path(),
    };
  }

  factory _SettingsRepoEntry.fromJson(dynamic data) {
    return _SettingsRepoEntry(_AuthMode._fromJson(data['authMode']!)!,
        RepoLocation.fromDbPath(data['location']!));
  }
}

//--------------------------------------------------------------------

class RepoSettings {
  Settings _settings;
  DatabaseId _databaseId;
  _SettingsRepoEntry _entry;

  RepoSettings(this._settings, this._databaseId, this._entry);

  RepoLocation get location => _entry.location;
  DatabaseId get databaseId => _databaseId;
  _AuthMode get authMode => _entry.authMode;
  String get name => _entry.name;
  Directory get dir => _entry.dir;

  Future<void> setAuthModePasswordProvidedByUser() async {
    _entry.authMode = _AuthModePasswordProvidedByUser();
    await _settings._storeRoot();
  }

  Future<void> setAuthModePasswordStoredOnDevice(
      String password, bool requireAuthentication) async {
    final encryptedPwd = _settings._masterKey.encrypt(password);
    _entry.authMode =
        _AuthModePasswordStoredOnDevice(encryptedPwd, requireAuthentication);
    await _settings._storeRoot();
  }

  bool hasPassword() {
    return authMode is _AuthModePasswordStoredOnDevice;
  }

  bool shouldCheckBiometricsBeforeUnlock() {
    final authMode = _entry.authMode;
    return (authMode is _AuthModePasswordStoredOnDevice) &&
        authMode.confirmWithBiometrics;
  }

  String? getPassword() {
    final authMode = _entry.authMode;
    if (authMode is _AuthModePasswordStoredOnDevice) {
      return _settings._masterKey.decrypt(authMode.encryptedPwd);
    }
    return null;
  }

  PasswordMode passwordMode() {
    return !hasPassword()
        ? PasswordMode.manual
        : shouldCheckBiometricsBeforeUnlock()
            ? PasswordMode.bio
            : PasswordMode.none;
  }
}

//--------------------------------------------------------------------

class SettingsRoot {
  static const int VERSION = 1;

  // Did the user accept the eQ values?
  bool acceptedEqualitieValues = false;
  // Show onboarding (will flip to false once shown).
  bool showOnboarding = true;
  bool launchAtStartup = true;
  bool enableSyncOnMobileInternet = true;
  int? highestSeenProtocolNumber;
  // TODO: In order to preserve plausible deniability, make sure that when a
  // current repo is locked, that this value is set to `null`.
  DatabaseId? currentRepo = null;
  Map<DatabaseId, _SettingsRepoEntry> repos = {};

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
      'version': VERSION,
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

    int version = data['version'];

    if (version != VERSION) {
      throw "Invalid settings version ($version)";
    }

    final repos = <DatabaseId, _SettingsRepoEntry>{
      for (var kv in data['repos']!.entries)
        DatabaseId(kv.key): _SettingsRepoEntry.fromJson(kv.value)
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
  static const String SETTINGS_KEY = "settings";

  final SettingsRoot _root;
  final SharedPreferences _prefs;
  final MasterKey _masterKey;

  //------------------------------------------------------------------

  Settings._(this._root, this._prefs, this._masterKey);

  Future<void> _storeRoot() async {
    await _prefs.setString(SETTINGS_KEY, json.encode(_root.toJson()));
  }

  static Future<Settings> init(
      SharedPreferences prefs, MasterKey masterKey) async {
    final json = prefs.getString(SETTINGS_KEY);
    final root = SettingsRoot.fromJson(json);

    if (prefs.getKeys().length > 1) {
      // The previous migration did not finish correctly, prefs should only
      // `SETTINGS_KEY` key after success.
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

    final Map<DatabaseId, _SettingsRepoEntry> repos = HashMap();

    for (final repo in s0.repos()) {
      final id = DatabaseId(repo.databaseId);
      final auth = s0.getAuthenticationMode(repo.name);
      var newAuth = null;
      switch (auth) {
        // TODO: Remove passwords stored in oldStorage
        case v0.AuthMode.manual:
          newAuth = _AuthModePasswordProvidedByUser();
        case v0.AuthMode.version1:
        case v0.AuthMode.version2:
          final oldStorage = v0.SecureStorage(databaseId: id);
          final password = await oldStorage.tryGetPassword(
              authMode: v0.AuthMode.noLocalPassword);
          newAuth = _AuthModePasswordStoredOnDevice(
              masterKey.encrypt(password!), true);
        case v0.AuthMode.noLocalPassword:
          final oldStorage = v0.SecureStorage(databaseId: id);
          final password = await oldStorage.tryGetPassword(
              authMode: v0.AuthMode.noLocalPassword);
          newAuth = _AuthModePasswordStoredOnDevice(
              masterKey.encrypt(password!), false);
      }
      repos[id] = _SettingsRepoEntry(newAuth, repo.info);
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
      if (key != SETTINGS_KEY) {
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

  RepoSettings? repoSettingsByName(String name) {
    var e = null;
    for (final kv in _root.repos.entries) {
      if (kv.value.name == name) {
        e = kv;
        break;
      }
    }
    if (e == null) {
      return null;
    }
    return RepoSettings(this, e.key, e.value);
  }

  RepoSettings? repoSettingsById(DatabaseId repoId) {
    final entry = _root.repos[repoId];
    if (entry == null) return null;
    return RepoSettings(this, repoId, entry);
  }

  //------------------------------------------------------------------

  String? getDefaultRepo() {
    final current = _root.currentRepo;
    if (current == null) {
      return null;
    }
    _root.repos[current]?.location.name;
  }

  Future<void> setDefaultRepo(String? name) async {
    // TODO: We should not set repositories that are protected by passwords as
    // default because that could imply that those repositories are not blind
    // and thus compromise plausible deniability.
    if (_root.currentRepo == name) {
      return;
    }

    if (name == null) {
      _root.currentRepo = null;
    } else {
      final rs = repoSettingsByName(name);
      if (rs == null) {
        return null;
      }
      _root.currentRepo = rs.databaseId;
    }

    await _storeRoot();
  }

  //------------------------------------------------------------------

  Future<void> renameRepository(
      RepoSettings repoSettings, String newName) async {
    if (repoSettings.name == newName) {
      // TODO: This should just return without throwing, but check where it's used.
      throw 'Failed to rename repo: "$newName" to same name';
    }

    if (repoSettingsByName(newName) != null) {
      throw 'Failed to rename repo: "$newName" already exists';
    }

    final oldInfo = repoSettings._entry.location;
    repoSettings._entry.location =
        RepoLocation.fromDirAndName(oldInfo.dir, newName);
    await _storeRoot();
  }

  //------------------------------------------------------------------

  Future<RepoSettings?> addRepoWithPasswordStoredOnDevice(RepoLocation location,
      {required DatabaseId databaseId,
      required String password,
      required requireBiometricCheck}) async {
    final authMode = _AuthModePasswordStoredOnDevice(
        _masterKey.encrypt(password), requireBiometricCheck);
    return await _addRepo(location, databaseId: databaseId, authMode: authMode);
  }

  Future<RepoSettings?> addRepoWithUserProvidedPassword(
    RepoLocation location, {
    required DatabaseId databaseId,
  }) async {
    final authMode = _AuthModePasswordProvidedByUser();
    return await _addRepo(location, databaseId: databaseId, authMode: authMode);
  }

  Future<RepoSettings?> _addRepo(
    RepoLocation location, {
    required DatabaseId databaseId,
    required _AuthMode authMode,
  }) async {
    if (_root.repos.containsKey(databaseId)) {
      loggy.debug(
          'Settings already contains a repo with the id "${databaseId}"');
      return null;
    }

    if (repoSettingsByName(location.name) != null) {
      loggy.debug(
          'Settings already contains a repo with the name "${location.name}"');
      return null;
    }

    final entry = _SettingsRepoEntry(authMode, location);
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
        context.join(alternativeDir.path, 'ouisync');

    return await Directory(nonAndroidAlternativePath).create();
  }

  //------------------------------------------------------------------

  String? getMountPoint() => _defaultMountPoint();
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
