import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/utils.dart';
import 'cubits.dart';

class SecurityState extends Equatable {
  final bool isBiometricsAvailable;

  final bool currentUnlockWithBiometrics;
  final bool unlockWithBiometrics;

  final String currentAuthMode;
  final String newAuthMode;

  final String currentPassword;
  final String newPassword;
  final bool removePassword;

  final bool previewPassword;
  final bool previewNewPassword;

  final String message;

  bool get showAddPassword {
    if (currentAuthMode == Constants.authModeNoLocalPassword) {
      return newPassword.isEmpty;
    } else if (currentAuthMode == Constants.authModeManual) {
      return false;
    } else {
      final authMode = newAuthMode.isEmpty ? currentAuthMode : newAuthMode;

      if ([Constants.authModeVersion1, Constants.authModeVersion2]
          .contains(authMode)) {
        return newPassword.isEmpty;
      }
    }

    return false;
  }

  bool get showManagePassword => currentAuthMode == Constants.authModeManual
      ? true
      : newPassword.isNotEmpty;

  bool get useBiometrics =>
      isBiometricsAvailable ? unlockWithBiometrics : false;

  bool get showRemoveBiometricsWarning =>
      currentUnlockWithBiometrics && !unlockWithBiometrics;

  bool get isUnsavedNewPassword {
    if ([Constants.authModeNoLocalPassword, Constants.authModeManual]
            .contains(currentAuthMode) ==
        false) {
      return isUnsavedBiometrics
          ? newPassword.isEmpty
              ? false
              : currentPassword != newPassword
          : newPassword.isNotEmpty;
    }
    return newPassword.isEmpty ? false : currentPassword != newPassword;
  }

  bool get isUnsavedBiometrics =>
      currentUnlockWithBiometrics != unlockWithBiometrics;

  bool get hasUnsavedChanges =>
      removePassword || isUnsavedNewPassword || isUnsavedBiometrics;

  SecurityState(
      {this.isBiometricsAvailable = false,
      this.currentUnlockWithBiometrics = false,
      this.unlockWithBiometrics = false,
      this.currentAuthMode = '',
      this.newAuthMode = '',
      this.currentPassword = '',
      this.newPassword = '',
      this.removePassword = false,
      this.previewPassword = false,
      this.previewNewPassword = false,
      this.message = ''});

  SecurityState copyWith(
          {bool? isBiometricsAvailable,
          bool? currentUnlockWithBiometrics,
          bool? unlockWithBiometrics,
          String? currentAuthMode,
          String? newAuthMode,
          String? currentPassword,
          String? newPassword,
          bool? removePassword,
          bool? previewPassword,
          bool? previewNewPassword,
          String? message}) =>
      SecurityState(
          isBiometricsAvailable:
              isBiometricsAvailable ?? this.isBiometricsAvailable,
          currentUnlockWithBiometrics:
              currentUnlockWithBiometrics ?? this.currentUnlockWithBiometrics,
          unlockWithBiometrics:
              unlockWithBiometrics ?? this.unlockWithBiometrics,
          currentAuthMode: currentAuthMode ?? this.currentAuthMode,
          newAuthMode: newAuthMode ?? this.newAuthMode,
          currentPassword: currentPassword ?? this.currentPassword,
          newPassword: newPassword ?? this.newPassword,
          removePassword: removePassword ?? this.removePassword,
          previewPassword: previewPassword ?? this.previewPassword,
          previewNewPassword: previewNewPassword ?? this.previewNewPassword,
          message: message ?? this.message);

  @override
  List<Object?> get props => [
        isBiometricsAvailable,
        currentUnlockWithBiometrics,
        unlockWithBiometrics,
        currentAuthMode,
        newAuthMode,
        currentPassword,
        newPassword,
        removePassword,
        previewPassword,
        previewNewPassword,
        message
      ];
}

class SecurityCubit extends Cubit<SecurityState> with OuiSyncAppLogger {
  SecurityCubit._(this._repoCubit, this._shareToken, SecurityState state)
      : super(state);

  final RepoCubit _repoCubit;
  final ShareToken _shareToken;

  static SecurityCubit create(
      {required RepoCubit repoCubit,
      required ShareToken shareToken,
      required bool isBiometricsAvailable,
      required String authenticationMode,
      required String password}) {
    var initialState = SecurityState();

    final unlockWithBiometrics = [
      Constants.authModeVersion1,
      Constants.authModeVersion2
    ].contains(authenticationMode);

    initialState = initialState.copyWith(
        isBiometricsAvailable: isBiometricsAvailable,
        currentUnlockWithBiometrics: unlockWithBiometrics,
        unlockWithBiometrics: unlockWithBiometrics,
        currentAuthMode: authenticationMode,
        currentPassword: password);

    return SecurityCubit._(repoCubit, shareToken, initialState);
  }

  Future<bool> addPasswordToSecureStorage(
      String password, String authMode) async {
    final secureStorageResult = await SecureStorage.addRepositoryPassword(
        databaseId: _repoCubit.databaseId,
        password: password,
        authMode: authMode);

    if (secureStorageResult.exception != null) {
      loggy.app(secureStorageResult.exception);
      return false;
    }

    return true;
  }

  Future<bool> updatePasswordInSecureStorage(
      String newPassword, String authMode) async {
    final secureStorageResult = await SecureStorage.addRepositoryPassword(
        databaseId: _repoCubit.databaseId,
        password: state.currentPassword,
        authMode: authMode);

    if (secureStorageResult.exception != null) {
      loggy.app(secureStorageResult.exception);

      return false;
    }

    emit(state.copyWith(currentPassword: newPassword));

    return true;
  }

  Future<bool?> addOrRemoveVersion2InSecureStorage(String newAuthMode) async {
    final newEntryResult = await SecureStorage.addRepositoryPassword(
        databaseId: _repoCubit.databaseId,
        password: state.currentPassword,
        authMode: newAuthMode);

    if (newEntryResult.exception != null) {
      loggy.app(newEntryResult.exception);

      return null;
    }

    final oldVersion2EntryResult = await SecureStorage.deleteRepositoryPassword(
        databaseId: _repoCubit.databaseId,
        authMode: state.currentAuthMode,
        authenticationRequired: false);

    if (oldVersion2EntryResult.exception != null) {
      loggy.app(oldVersion2EntryResult.exception);

      return false;
    }

    return true;
  }

  Future<bool> removePasswordFromSecureStorage(String authMode) async {
    final secureStorageResult = await SecureStorage.deleteRepositoryPassword(
        databaseId: _repoCubit.databaseId,
        authMode: authMode,
        authenticationRequired: false);

    if (secureStorageResult.exception != null) {
      loggy.app(secureStorageResult.exception);

      return false;
    }

    emit(state.copyWith(
        currentUnlockWithBiometrics: false,
        unlockWithBiometrics: false,
        previewPassword: false));
    return true;
  }

  Future<bool> changeRepositoryPassword(String newPassword) async {
    final mode = await _shareToken.mode;
    final metaInfo = _repoCubit.metaInfo;

    if (mode == AccessMode.write) {
      return _repoCubit.setReadWritePassword(
          metaInfo, state.currentPassword, newPassword, _shareToken);
    } else {
      assert(mode == AccessMode.read);
      return _repoCubit.setReadPassword(metaInfo, newPassword, _shareToken);
    }
  }

  void repositoryPasswordChanged(String newPassword) => emit(state.copyWith(
      currentPassword: newPassword,
      newPassword: '',
      previewPassword: false,
      previewNewPassword: false));

  void setCurrentUnlockWithBiometrics(bool value) =>
      emit(state.copyWith(currentUnlockWithBiometrics: value));

  void setCurrentPassword(String password) =>
      emit(state.copyWith(currentPassword: password));

  void setCurrentAuthMode(String authMode) {
    if (state.currentAuthMode == authMode) {
      return;
    }

    _repoCubit.setAuthenticationMode(authMode);

    emit(state.copyWith(currentAuthMode: authMode));
  }

  void setNewAuthMode(String newAuthMode) {
    if (state.newAuthMode == newAuthMode) {
      return;
    }

    emit(state.copyWith(newAuthMode: newAuthMode));
  }

  void setNewPassword(String newPassword) {
    if (state.newPassword == newPassword) {
      return;
    }

    emit(state.copyWith(newPassword: newPassword));
  }

  void setRemovePassword(bool value) =>
      emit(state.copyWith(removePassword: value));

  void clearNewPassword() =>
      emit(state.copyWith(newPassword: '', previewNewPassword: false));

  void switchPreviewPassword() {
    final value = !state.previewPassword;
    emit(state.copyWith(previewPassword: value));
  }

  void switchPreviewNewPassword() {
    final value = !state.previewNewPassword;
    emit(state.copyWith(previewNewPassword: value));
  }

  void previewPassword(bool value) =>
      emit(state.copyWith(previewPassword: value));

  void previewNewPassword(bool value) =>
      emit(state.copyWith(previewNewPassword: value));

  void setUnlockWithBiometrics(value) =>
      emit(state.copyWith(unlockWithBiometrics: value));
}
