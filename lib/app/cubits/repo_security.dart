import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart'
    show Password, SetLocalSecretKeyAndSalt, SetLocalSecretExtension;

import '../models/models.dart'
    show
        AuthMode,
        AuthModeBlindOrManual,
        AuthModeKeyStoredOnDevice,
        AuthModePasswordStoredOnDevice,
        UnlockedAccess,
        LocalSecretInput,
        LocalSecretManual,
        LocalSecretMode,
        LocalSecretRandom,
        SecretKeyOrigin,
        SecretKeyStore;
import '../utils/random.dart';
import '../utils/utils.dart'
    show AppLogger, LocalAuth, MasterKey, None, Option, PasswordHasher, Some;
import 'repo.dart';
import 'utils.dart';

//--------------------------------------------------------------------

class RepoSecurityCurrentState {
  final LocalSecretMode localSecretMode;
  final UnlockedAccess access;
  // This is `Some` when the user submits local password and it is used to
  // determine whether the password has changed since the last submission.
  final Option<Password> localPassword;

  RepoSecurityCurrentState({
    required this.localSecretMode,
    required this.access,
    this.localPassword = const None(),
  });

  RepoSecurityCurrentState copyWith({
    LocalSecretMode? localSecretMode,
    UnlockedAccess? access,
    Option<Password>? localPassword,
  }) =>
      RepoSecurityCurrentState(
          localSecretMode: localSecretMode ?? this.localSecretMode,
          access: access ?? this.access,
          localPassword: localPassword ?? this.localPassword);
}

//--------------------------------------------------------------------

class RepoSecurityState with AppLogger {
  final RepoSecurityCurrentState current;

  final SecretKeyOrigin plannedOrigin;
  final bool plannedStoreSecret;
  final BiometricsValue plannedWithBiometrics;
  final Option<Password> plannedPassword;

  final bool isBiometricsAvailable;

  RepoSecurityState({
    required this.current,
    SecretKeyOrigin? plannedOrigin,
    bool? plannedStoreSecret,
    BiometricsValue? plannedWithBiometrics,
    this.plannedPassword = const None(),
    this.isBiometricsAvailable = false,
  })  : plannedOrigin = plannedOrigin ?? current.localSecretMode.origin,
        plannedStoreSecret =
            plannedStoreSecret ?? current.localSecretMode.store.isStored,
        plannedWithBiometrics = plannedWithBiometrics ??
            BiometricsValue(current.localSecretMode.isSecuredWithBiometrics);

  RepoSecurityState copyWith({
    RepoSecurityCurrentState? current,
    SecretKeyOrigin? plannedOrigin,
    bool? plannedStoreSecret,
    BiometricsValue? plannedWithBiometrics,
    Option<Password>? plannedPassword,
    bool? isBiometricsAvailable,
  }) =>
      RepoSecurityState(
        current: current ?? this.current,
        plannedOrigin: plannedOrigin ?? this.plannedOrigin,
        plannedStoreSecret: plannedStoreSecret ?? this.plannedStoreSecret,
        plannedWithBiometrics:
            plannedWithBiometrics ?? this.plannedWithBiometrics,
        plannedPassword: plannedPassword ?? this.plannedPassword,
        isBiometricsAvailable:
            isBiometricsAvailable ?? this.isBiometricsAvailable,
      );

  // If the secret is already stored and is not random then we can keep using it and only change
  // the other properties. So in those cases putting in a new password is not required.
  bool get isLocalPasswordRequired => switch (current.localSecretMode) {
        LocalSecretMode.manual ||
        LocalSecretMode.randomStored ||
        LocalSecretMode.randomSecuredWithBiometrics =>
          true,
        LocalSecretMode.manualStored ||
        LocalSecretMode.manualSecuredWithBiometrics =>
          false,
      };

  bool get isSecureWithBiometricsEnabled =>
      isBiometricsAvailable && secretWillBeStored;

  bool get isValid => newLocalSecretInput != null;

  bool get secretWillBeStored =>
      plannedOrigin == SecretKeyOrigin.random || plannedStoreSecret;

  bool get hasPendingChanges {
    final originChanged = plannedOrigin != current.localSecretMode.origin;

    final localPasswordChanged =
        plannedPassword is Some && plannedPassword != current.localPassword;

    final storeChanged =
        secretWillBeStored != current.localSecretMode.store.isStored;

    final biometricsChanged = plannedWithBiometrics.toBool !=
        current.localSecretMode.isSecuredWithBiometrics;

    return originChanged ||
        storeChanged ||
        biometricsChanged ||
        localPasswordChanged;
  }

  // DEBUG
  //void printSecurityState() {
  //  loggy.debug("  current.localSecretMode: ${current.localSecretMode}");
  //  loggy.debug("  current.access: ${current.access}");
  //  loggy.debug("  current.localPassword: ${current.localPassword}");
  //  loggy.debug("  plannedOrigin: $plannedOrigin");
  //  loggy.debug("  plannedStoreSecret: $plannedStoreSecret");
  //  loggy.debug("  plannedWithBiometrics: $plannedWithBiometrics");
  //  loggy.debug("  plannedPassword: $current.localPassword");
  //  loggy.debug("  isBiometricsAvailable: $isBiometricsAvailable");
  //}

  LocalSecretInput? get newLocalSecretInput {
    final willStore = secretWillBeStored;

    return switch ((
      plannedPassword,
      plannedOrigin,
      willStore,
      plannedWithBiometrics.toBool
    )) {
      (Some(value: final password), SecretKeyOrigin.manual, false, _) =>
        LocalSecretManual(
          password: password,
          store: SecretKeyStore.notStored,
        ),
      (Some(value: final password), SecretKeyOrigin.manual, true, false) =>
        LocalSecretManual(
          password: password,
          store: SecretKeyStore.stored,
        ),
      (Some(value: final password), SecretKeyOrigin.manual, true, true) =>
        LocalSecretManual(
          password: password,
          store: SecretKeyStore.securedWithBiometrics,
        ),
      (None(), SecretKeyOrigin.manual, _, _) => null,
      (_, SecretKeyOrigin.random, _, false) =>
        LocalSecretRandom(secureWithBiometrics: false),
      (_, SecretKeyOrigin.random, _, true) =>
        LocalSecretRandom(secureWithBiometrics: true),
    };
  }

  Password? get newLocalPassword => switch ((plannedPassword, plannedOrigin)) {
        (Some(value: final value), SecretKeyOrigin.manual) => value,
        (None(), SecretKeyOrigin.manual) || (_, SecretKeyOrigin.random) => null,
      };

  @override
  String toString() =>
      '$runtimeType(plannedOrigin: $plannedOrigin, plannedStoreSecret: $plannedStoreSecret, ...)';
}

//--------------------------------------------------------------------

class RepoSecurityCubit extends Cubit<RepoSecurityState>
    with CubitActions, AppLogger {
  RepoSecurityCubit({
    required LocalSecretMode currentLocalSecretMode,
    required UnlockedAccess currentAccess,
  }) : super(RepoSecurityState(
            current: RepoSecurityCurrentState(
              localSecretMode: currentLocalSecretMode,
              access: currentAccess,
            ),
            plannedStoreSecret: currentLocalSecretMode.isStored)) {
    unawaited(_init());
  }

  Future<void> _init() async {
    final canAuthenticate = await LocalAuth.canAuthenticate();
    emitUnlessClosed(state.copyWith(
      isBiometricsAvailable: canAuthenticate,
    ));
  }

  void setOrigin(SecretKeyOrigin value) {
    emitUnlessClosed(state.copyWith(plannedOrigin: value));
  }

  void setStore(bool value) {
    final plannedWithBiometrics =
        switch ((value, state.plannedWithBiometrics)) {
      (true, BiometricsTrue()) => BiometricsTrue(),
      (true, BiometricsFalse()) => BiometricsFalse(),
      (true, BiometricsImpliedFalse()) => BiometricsTrue(),
      (false, BiometricsTrue()) => BiometricsImpliedFalse(),
      (false, BiometricsFalse()) => BiometricsFalse(),
      (false, BiometricsImpliedFalse()) => BiometricsImpliedFalse(),
    };

    emitUnlessClosed(state.copyWith(
        plannedStoreSecret: value,
        plannedWithBiometrics: plannedWithBiometrics));
  }

  void setSecureWithBiometrics(bool value) {
    emitUnlessClosed(
        state.copyWith(plannedWithBiometrics: BiometricsValue(value)));
  }

  void setLocalPassword(String? value) {
    emitUnlessClosed(state.copyWith(
      plannedPassword: value != null ? Some(Password(value)) : None(),
    ));
  }

  Future<bool> apply(
    RepoCubit repoCubit, {
    required PasswordHasher passwordHasher,
    required MasterKey masterKey,
  }) async {
    final newLocalSecretInput = state.newLocalSecretInput;
    if (newLocalSecretInput == null) {
      return false;
    }

    final (newLocalSecret, newAuthMode) = await _computeLocalSecretAndAuthMode(
      repoCubit,
      newLocalSecretInput,
      passwordHasher,
      masterKey,
    );

    // Keep the old auth mode in case we need to revert to it on error.
    final oldAuthMode = repoCubit.state.authMode;

    // Save the new auth mode
    try {
      await repoCubit.setAuthMode(newAuthMode);

      Option<Password> newLocalPassword =
          newLocalSecretInput is LocalSecretManual
              ? Some(newLocalSecretInput.password)
              : None<Password>();

      emitUnlessClosed(state.copyWith(
        current: state.current.copyWith(
            localSecretMode: newAuthMode.localSecretMode,
            localPassword: newLocalPassword),
      ));

      loggy.debug('Repo auth mode updated: $newAuthMode');
    } catch (e, st) {
      loggy.error(
        'Failed to update repo auth mode:',
        e,
        st,
      );

      return false;
    }

    // Save the new local secret, if it changed
    if (newLocalSecret != null) {
      try {
        await repoCubit.setLocalSecret(
          oldSecret: state.current.access.localSecret,
          newSecret: newLocalSecret,
        );
        emitUnlessClosed(state.copyWith(
            current: state.current.copyWith(
                access: state.current.access
                    .copyWithLocalSecret(newLocalSecret.toLocalSecret()))));
        loggy.debug('Repo local secret updated');
      } catch (e, st) {
        loggy.error(
          'Failed to update repo local secret:',
          e,
          st,
        );

        // Revert to the old auth mode
        await repoCubit.setAuthMode(oldAuthMode);

        return false;
      }
    }

    return true;
  }

  //// DEBUG
  //@override
  //void onChange(Change<RepoSecurityState> change) {
  //  super.onChange(change);
  //  loggy.debug('${change.currentState} -> ${change.nextState}');
  //}
}

Future<(SetLocalSecretKeyAndSalt?, AuthMode)> _computeLocalSecretAndAuthMode(
  RepoCubit repoCubit,
  LocalSecretInput localSecretInput,
  PasswordHasher passwordHasher,
  MasterKey masterKey,
) async {
  switch (localSecretInput) {
    case LocalSecretManual():
      final localSecretKey =
          await passwordHasher.hashPassword(localSecretInput.password);

      final authMode = switch (localSecretInput.store) {
        SecretKeyStore.notStored => AuthModeBlindOrManual(),
        SecretKeyStore.stored ||
        SecretKeyStore.securedWithBiometrics =>
          await AuthModeKeyStoredOnDevice.encrypt(
            masterKey,
            localSecretKey.key,
            keyOrigin: SecretKeyOrigin.manual,
            secureWithBiometrics:
                localSecretInput.store == SecretKeyStore.securedWithBiometrics,
          ),
      };

      return (localSecretKey, authMode);
    case LocalSecretRandom():
      final oldAuthMode = repoCubit.state.authMode;

      switch (oldAuthMode) {
        case AuthModeKeyStoredOnDevice(keyOrigin: SecretKeyOrigin.random):
          final authMode = oldAuthMode.copyWith(
            secureWithBiometrics: localSecretInput.secureWithBiometrics,
          );

          return (null, authMode);
        case AuthModeKeyStoredOnDevice(keyOrigin: SecretKeyOrigin.manual):
        case AuthModePasswordStoredOnDevice():
        case AuthModeBlindOrManual():
          final setLocalSecret = SetLocalSecretKeyAndSalt(
            key: randomSecretKey(),
            salt: randomSalt(),
          );
          final authMode = await AuthModeKeyStoredOnDevice.encrypt(
            masterKey,
            setLocalSecret.key,
            keyOrigin: SecretKeyOrigin.random,
            secureWithBiometrics: localSecretInput.secureWithBiometrics,
          );

          return (setLocalSecret, authMode);
      }
  }
}

//--------------------------------------------------------------------

sealed class BiometricsValue {
  bool get toBool;

  factory BiometricsValue(bool b) => b ? BiometricsTrue() : BiometricsFalse();
}

class BiometricsTrue implements BiometricsValue {
  @override
  bool get toBool => true;
}

class BiometricsFalse implements BiometricsValue {
  @override
  bool get toBool => false;
}

class BiometricsImpliedFalse implements BiometricsValue {
  @override
  bool get toBool => false;
}

//--------------------------------------------------------------------
