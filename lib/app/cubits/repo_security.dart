import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auth_mode.dart';
import '../models/local_secret.dart';
import '../utils/local_auth.dart';
import '../utils/log.dart';
import '../utils/master_key.dart';
import '../utils/option.dart';
import '../utils/password_hasher.dart';
import 'repo.dart';
import 'utils.dart';

class RepoSecurityState {
  final LocalSecretMode oldLocalSecretMode;
  final LocalSecret oldLocalSecret;
  final SecretKeyOrigin origin;
  final Option<bool> userWantsToStoreSecret;
  final bool secureWithBiometrics;
  final Option<LocalPassword> localPassword;
  // This is set to the above `localPassword` once the user clicks the "UPDATE"
  // button.  It is used to check whether the `localPassword` has changed
  // between the user clicking the "UPDATE" button and leaving the security
  // page.
  final Option<LocalPassword> updatedLocalPassword;
  final bool isBiometricsAvailable;

  RepoSecurityState({
    required this.oldLocalSecretMode,
    required this.oldLocalSecret,
    SecretKeyOrigin? origin,
    // Reflects the user's preference on storing a password for
    // `LocalSecretMode`s where storing is not implicit.
    this.userWantsToStoreSecret = const None(),
    bool? secureWithBiometrics,
    this.localPassword = const None(),
    this.updatedLocalPassword = const None(),
    this.isBiometricsAvailable = false,
  })  : origin = origin ?? oldLocalSecretMode.origin,
        secureWithBiometrics = secureWithBiometrics ??
            oldLocalSecretMode.store.isSecuredWithBiometrics;

  RepoSecurityState copyWith({
    LocalSecretMode? oldLocalSecretMode,
    LocalSecret? oldLocalSecret,
    SecretKeyOrigin? origin,
    bool? userWantsToStoreSecret,
    bool? secureWithBiometrics,
    Option<LocalPassword>? localPassword,
    Option<LocalPassword>? updatedLocalPassword,
    bool? isBiometricsAvailable,
  }) =>
      RepoSecurityState(
        oldLocalSecretMode: oldLocalSecretMode ?? this.oldLocalSecretMode,
        oldLocalSecret: oldLocalSecret ?? this.oldLocalSecret,
        origin: origin ?? this.origin,
        userWantsToStoreSecret: userWantsToStoreSecret != null
            ? Some(userWantsToStoreSecret)
            : this.userWantsToStoreSecret,
        secureWithBiometrics: secureWithBiometrics ?? this.secureWithBiometrics,
        localPassword: localPassword ?? this.localPassword,
        updatedLocalPassword: updatedLocalPassword ?? this.updatedLocalPassword,
        isBiometricsAvailable:
            isBiometricsAvailable ?? this.isBiometricsAvailable,
      );

  // If the secret is already stored and is not random then we can keep using it and only change
  // the other properties. So in those cases putting in a new password is not required.
  bool get isLocalPasswordRequired => switch (oldLocalSecretMode) {
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
      origin == SecretKeyOrigin.random ||
      switch (userWantsToStoreSecret) {
        Some(value: final store) => store,
        None() => RepoSecurityCubit.defaultStoreSecretOnDeviceEnabled
      };

  bool get hasPendingChanges {
    final originChanged = origin != oldLocalSecretMode.origin;

    final localPasswordChanged =
        localPassword is Some && localPassword != updatedLocalPassword;

    final storeChanged =
        secretWillBeStored != oldLocalSecretMode.store.isStored;

    final biometricsChanged = secureWithBiometrics !=
        oldLocalSecretMode.store.isSecuredWithBiometrics;

    return originChanged ||
        storeChanged ||
        biometricsChanged ||
        localPasswordChanged;
  }

  LocalSecretInput? get newLocalSecretInput {
    final willStore = secretWillBeStored;

    return switch ((localPassword, origin, willStore, secureWithBiometrics)) {
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

  LocalPassword? get newLocalPassword => switch ((localPassword, origin)) {
        (Some(value: final value), SecretKeyOrigin.manual) => value,
        (None(), SecretKeyOrigin.manual) || (_, SecretKeyOrigin.random) => null,
      };

  @override
  String toString() =>
      '$runtimeType(origin: $origin, userWantsToStoreSecret: $userWantsToStoreSecret, ...)';
}

class RepoSecurityCubit extends Cubit<RepoSecurityState>
    with CubitActions, AppLogger {
  // The default for whether the secret is going to be stored on the device
  // when the user wants to secure their repo using a password but hasn't yet
  // interacted with the `labelRememberPassword` toggle.
  static final bool defaultStoreSecretOnDeviceEnabled = false;

  RepoSecurityCubit({
    required LocalSecretMode oldLocalSecretMode,
    LocalSecret? oldLocalSecret,
  }) : super(RepoSecurityState(
            oldLocalSecretMode: oldLocalSecretMode,
            oldLocalSecret: oldLocalSecret ?? LocalSecretKey.random(),
            userWantsToStoreSecret: switch (oldLocalSecretMode) {
              LocalSecretMode.manual => Some(false),
              LocalSecretMode.manualStored => Some(true),
              LocalSecretMode.manualSecuredWithBiometrics => Some(true),
              LocalSecretMode.randomStored => None(),
              LocalSecretMode.randomSecuredWithBiometrics => None(),
            })) {
    unawaited(_init());
  }

  Future<void> _init() async {
    final canAuthenticate = await LocalAuth.canAuthenticate();
    emitUnlessClosed(state.copyWith(
      isBiometricsAvailable: canAuthenticate,
    ));
  }

  void setOrigin(SecretKeyOrigin value) {
    emit(state.copyWith(origin: value));
  }

  void setStore(bool value) {
    emit(state.copyWith(userWantsToStoreSecret: value));
  }

  void setSecureWithBiometrics(bool value) {
    emit(state.copyWith(secureWithBiometrics: value));
  }

  void setLocalPassword(String? value) {
    emit(state.copyWith(
      localPassword: value != null ? Some(LocalPassword(value)) : None(),
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

      Option<LocalPassword> newLocalPassword =
          newLocalSecretInput is LocalSecretManual
              ? Some(newLocalSecretInput.password)
              : None<LocalPassword>();

      emit(state.copyWith(
        oldLocalSecretMode: newAuthMode.localSecretMode,
        updatedLocalPassword: newLocalPassword,
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
          oldSecret: state.oldLocalSecret,
          newSecret: newLocalSecret,
        );
        emit(state.copyWith(oldLocalSecret: newLocalSecret.toLocalSecret()));
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
  //  print('${change.currentState} -> ${change.nextState}');
  //}
}

Future<(LocalSecretKeyAndSalt?, AuthMode)> _computeLocalSecretAndAuthMode(
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
          final localSecretKey = LocalSecretKeyAndSalt.random();
          final authMode = await AuthModeKeyStoredOnDevice.encrypt(
            masterKey,
            localSecretKey.key,
            keyOrigin: SecretKeyOrigin.random,
            secureWithBiometrics: localSecretInput.secureWithBiometrics,
          );

          return (localSecretKey, authMode);
      }
  }
}
