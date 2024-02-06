import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';
import '../models/models.dart';
import 'cubits.dart';

class SecurityState extends Equatable {
  final bool isBiometricsAvailable;
  final PasswordMode passwordMode;
  final String password;
  final bool previewPassword;
  final String message;

  String get passwordModeTitle => passwordMode == PasswordMode.manual
      ? S.current.messageUpdateLocalPassword
      : S.current.messageAddLocalPassword;

  SecurityState(
      {required this.passwordMode,
      required this.isBiometricsAvailable,
      required this.password,
      this.previewPassword = false,
      this.message = ''});

  bool get unlockWithBiometrics => passwordMode == PasswordMode.bio;

  SecurityState copyWith(
          {bool? isBiometricsAvailable,
          bool? unlockWithBiometrics,
          PasswordMode? passwordMode,
          String? password,
          bool? previewPassword,
          String? message}) =>
      SecurityState(
          isBiometricsAvailable:
              isBiometricsAvailable ?? this.isBiometricsAvailable,
          passwordMode: passwordMode ?? this.passwordMode,
          password: password ?? this.password,
          previewPassword: previewPassword ?? this.previewPassword,
          message: message ?? this.message);

  @override
  List<Object?> get props =>
      [isBiometricsAvailable, passwordMode, password, previewPassword, message];
}

class SecurityCubit extends Cubit<SecurityState> with AppLogger {
  SecurityCubit._(this._repoCubit, SecurityState state) : super(state);

  final RepoCubit _repoCubit;

  RepoSettings get repoSettings => _repoCubit.repoSettings;

  static SecurityCubit create({
    required RepoCubit repoCubit,
    required bool isBiometricsAvailable,
    required String password,
  }) {
    var initialState = SecurityState(
      isBiometricsAvailable: isBiometricsAvailable,
      passwordMode: repoCubit.repoSettings.passwordMode,
      password: password,
    );

    return SecurityCubit._(repoCubit, initialState);
  }

  // Returns error message on error.
  Future<String?> addLocalPassword(String newPassword) async {
    // TODO: If any of the async functions here fail, the user may lose their data.

    try {
      await repoSettings.setAuthModePasswordProvidedByUser();
    } catch (e) {
      return S.current.messageErrorRemovingSecureStorage;
    }

    final changed = await _changeRepositoryPassword(newPassword);

    if (changed == false) {
      return S.current.messageErrorAddingLocalPassword;
    }

    emitPassword(newPassword);
    emitPasswordMode(PasswordMode.manual);

    return null;
  }

  // Returns error message on error.
  Future<String?> updateLocalPassword(String newPassword) async {
    final changed = await _changeRepositoryPassword(newPassword);
    if (changed == false) {
      return S.current.messageErrorAddingLocalPassword;
    }

    emitPassword(newPassword);

    return null;
  }

  Future<String?> removeLocalPassword() async {
    // TODO: If any of the async functions here fail, the user may lose their data.
    final newPassword = generateRandomPassword();

    final passwordChanged = await _changeRepositoryPassword(newPassword);
    if (passwordChanged == false) {
      return S.current.messageErrorAddingSecureStorge;
    }

    try {
      await repoSettings.setAuthModePasswordStoredOnDevice(newPassword, false);
    } catch (e) {
      return S.current.messageErrorRemovingPassword;
    }

    emitPassword(newPassword);
    emitPasswordMode(PasswordMode.none);

    return null;
  }

  Future<String?> updateUnlockRepoWithBiometrics(
    bool unlockWithBiometrics,
  ) async {
    // TODO: If any of the async functions here fail, the user may lose their data.
    if (unlockWithBiometrics == false) {
      emitUnlockWithBiometrics(false);
      emitPasswordMode(PasswordMode.none);
      return null;
    }

    final newPassword = generateRandomPassword();
    final passwordChanged = await _changeRepositoryPassword(newPassword);

    if (passwordChanged == false) {
      return S.current.messageErrorAddingSecureStorge;
    }

    try {
      await repoSettings.setAuthModePasswordStoredOnDevice(
        newPassword,
        unlockWithBiometrics,
      );
    } catch (e) {
      return S.current.messageErrorUpdatingSecureStorage;
    }

    emitPassword(newPassword);
    emitUnlockWithBiometrics(unlockWithBiometrics);
    emitPasswordMode(PasswordMode.bio);

    return null;
  }

  Future<bool> _changeRepositoryPassword(String newPassword) async {
    assert(state.password.isNotEmpty, 'ERROR: currentPassword is empty');

    if (state.password.isEmpty) {
      return false;
    }

    return _repoCubit.setPassword(
      oldPassword: state.password,
      newPassword: newPassword,
    );
  }

  void emitUnlockWithBiometrics(bool value) =>
      emit(state.copyWith(unlockWithBiometrics: value));

  void emitPassword(String password) =>
      emit(state.copyWith(password: password));

  void emitPasswordMode(PasswordMode passwordMode) =>
      _repoCubit.emitPasswordMode(passwordMode);
}
