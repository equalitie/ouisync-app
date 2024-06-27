import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/local_secret.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/local_auth.dart';
import 'package:ouisync_app/app/utils/log.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' show AccessMode, ShareToken;

import '../../generated/l10n.dart';
import '../models/repo_entry.dart';
import '../utils/strings.dart';
import 'repos.dart';

class RepoCreationState {
  static const initialLocalSecretMode = LocalSecretMode.randomStored;

  final AccessMode accessMode;
  final bool isBiometricsAvailable;
  final LocalSecretMode localSecretMode;
  final bool loading;
  final RepoCreationSubstate substate;
  final String suggestedName;
  final ShareToken? token;
  final String tokenError;
  final bool useCacheServers;

  RepoCreationState({
    this.accessMode = AccessMode.write,
    this.isBiometricsAvailable = false,
    this.loading = false,
    this.localSecretMode = initialLocalSecretMode,
    this.substate = const RepoCreationPending(),
    this.suggestedName = '',
    this.token,
    this.tokenError = '',
    this.useCacheServers = true,
  });

  RepoCreationState copyWith({
    AccessMode? accessMode,
    bool? isBiometricsAvailable,
    LocalSecretMode? localSecretMode,
    bool? loading,
    RepoCreationSubstate? substate,
    String? suggestedName,
    ShareToken? token,
    String? tokenError,
    bool? useCacheServers,
  }) =>
      RepoCreationState(
        accessMode: accessMode ?? this.accessMode,
        isBiometricsAvailable:
            isBiometricsAvailable ?? this.isBiometricsAvailable,
        localSecretMode: localSecretMode ?? this.localSecretMode,
        loading: loading ?? this.loading,
        substate: substate ?? this.substate,
        suggestedName: suggestedName ?? this.suggestedName,
        token: token ?? this.token,
        tokenError: tokenError ?? this.tokenError,
        useCacheServers: useCacheServers ?? this.useCacheServers,
      );

  RepoLocation? get location => switch (substate) {
        RepoCreationPending(location: final location) => location,
        RepoCreationValid(location: final location) ||
        RepoCreationSuccess(location: final location) ||
        RepoCreationFailure(location: final location) =>
          location,
      };

  String? get name => location?.name;

  String? get nameError => switch (substate) {
        RepoCreationPending(nameError: final nameError) => nameError,
        _ => null,
      };

  @override
  String toString() =>
      '$runtimeType(loading: $loading, substate: $substate, suggestedName: $suggestedName, useCacheServers: $useCacheServers, ..)';
}

sealed class RepoCreationSubstate {
  const RepoCreationSubstate();
}

class RepoCreationPending extends RepoCreationSubstate {
  const RepoCreationPending({
    this.location,
    this.setLocalSecret,
    this.nameError = '',
  });

  final String nameError;
  final RepoLocation? location;
  final SetLocalSecret? setLocalSecret;

  @override
  String toString() =>
      '$runtimeType(location: $location, setLocalSecret: $setLocalSecret, nameError: $nameError)';
}

class RepoCreationValid extends RepoCreationSubstate {
  const RepoCreationValid({
    required this.location,
    required this.setLocalSecret,
  });

  final RepoLocation location;
  final SetLocalSecret setLocalSecret;

  @override
  String toString() =>
      '$runtimeType(location: $location, setLocalSecret: $setLocalSecret)';
}

class RepoCreationSuccess extends RepoCreationSubstate {
  const RepoCreationSuccess({
    required this.location,
  });

  final RepoLocation location;
}

class RepoCreationFailure extends RepoCreationSubstate {
  const RepoCreationFailure({
    required this.location,
    required this.error,
  });

  final RepoLocation location;
  final String error;
}

class RepoCreationCubit extends Cubit<RepoCreationState> with AppLogger {
  RepoCreationCubit({required this.reposCubit}) : super(RepoCreationState()) {
    nameController.addListener(
      () => unawaited(_onNameChanged(nameController.text)),
    );

    setLocalSecret(RepoCreationState.initialLocalSecretMode, null);
    unawaited(_init());
  }

  final ReposCubit reposCubit;
  final nameController = TextEditingController();

  @override
  Future<void> close() async {
    nameController.dispose();
    await super.close();
  }

  Future<void> setInitialTokenValue(String? tokenValue) async {
    if (tokenValue == null) {
      return;
    }

    await _loading(() async {
      try {
        final token = await ShareToken.fromString(
          reposCubit.session,
          tokenValue,
        );

        emit(state.copyWith(
          accessMode: await token.mode,
          suggestedName: await token.suggestedName,
          token: token,
          useCacheServers:
              await reposCubit.cacheServers.isEnabledForShareToken(token),
        ));
      } catch (e, st) {
        loggy.error('Extract repository token exception:', e, st);
        emit(state.copyWith(tokenError: S.current.messageErrorTokenInvalid));
      }
    });
  }

  void acceptSuggestedName() => nameController.text = state.suggestedName;

  void setUseCacheServers(bool value) {
    emit(state.copyWith(useCacheServers: value));
  }

  void setLocalSecret(LocalSecretMode mode, LocalPassword? password) {
    final setLocalSecret = (state.accessMode == AccessMode.blind ||
            mode.origin == SecretKeyOrigin.random)
        ? LocalSecretKeyAndSalt.random()
        : password;

    RepoCreationSubstate substate;

    if (setLocalSecret == null) {
      substate = switch (state.substate) {
        RepoCreationPending(
          location: final location,
          nameError: final nameError
        ) =>
          RepoCreationPending(location: location, nameError: nameError),
        RepoCreationValid(location: final location) ||
        RepoCreationSuccess(location: final location) ||
        RepoCreationFailure(location: final location) =>
          RepoCreationPending(location: location),
      };
    } else {
      substate = switch (state.substate) {
        RepoCreationPending(location: final location) when location != null =>
          RepoCreationValid(
            location: location,
            setLocalSecret: setLocalSecret,
          ),
        RepoCreationPending(
          location: final location,
          nameError: final nameError
        ) =>
          RepoCreationPending(
            location: location,
            nameError: nameError,
            setLocalSecret: setLocalSecret,
          ),
        RepoCreationValid(location: final location) =>
          RepoCreationValid(location: location, setLocalSecret: setLocalSecret),
        RepoCreationSuccess(location: final location) ||
        RepoCreationFailure(location: final location) =>
          RepoCreationValid(
            location: location,
            setLocalSecret: setLocalSecret,
          ),
      };
    }

    emit(state.copyWith(substate: substate, localSecretMode: mode));
  }

  Future<void> save() async {
    final substate = state.substate;
    if (substate is! RepoCreationValid) {
      return;
    }

    final repoEntry = await _loading(() => reposCubit.createRepository(
          location: substate.location,
          setLocalSecret: substate.setLocalSecret,
          token: state.token,
          localSecretMode: state.localSecretMode,
          useCacheServers: state.useCacheServers,
          setCurrent: true,
        ));

    switch (repoEntry) {
      case OpenRepoEntry():
        emit(state.copyWith(
          substate: RepoCreationSuccess(location: substate.location),
        ));
      case ErrorRepoEntry():
        emit(state.copyWith(
          substate: RepoCreationFailure(
            location: substate.location,
            error: repoEntry.error,
          ),
        ));
      case LoadingRepoEntry():
      case MissingRepoEntry():
        throw 'unreachable code';
    }
  }

  Future<void> _init() => _loading(() async {
        emit(state.copyWith(
          isBiometricsAvailable: await LocalAuth.canAuthenticate(),
        ));
      });

  Future<R> _loading<R>(Future<R> Function() f) async {
    try {
      emit(state.copyWith(loading: true));
      return await f();
    } finally {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> _onNameChanged(String name) async {
    if (name.isEmpty) {
      _setInvalidName(S.current.messageErrorFormValidatorNameDefault);
      return;
    }

    if (name.contains(RegExp(Strings.entityNameRegExp))) {
      _setInvalidName(S.current.messageErrorCharactersNotAllowed);
      return;
    }

    await _loading(() async {
      final location = RepoLocation.fromParts(
        dir: await reposCubit.settings.getDefaultRepositoriesDir(),
        name: name,
      );

      final exists = await File(location.path).exists();
      if (exists) {
        _setInvalidName(S.current.messageErrorRepositoryNameExist);
        return;
      }

      _setValidName(location);
    });
  }

  void _setValidName(RepoLocation location) {
    final substate = switch (state.substate) {
      RepoCreationPending(setLocalSecret: final setLocalSecret)
          when setLocalSecret != null =>
        RepoCreationValid(
          location: location,
          setLocalSecret: setLocalSecret,
        ),
      RepoCreationPending(setLocalSecret: final setLocalSecret) =>
        RepoCreationPending(
          setLocalSecret: setLocalSecret,
          location: location,
        ),
      RepoCreationValid(setLocalSecret: final setLocalSecret) =>
        RepoCreationValid(
          location: location,
          setLocalSecret: setLocalSecret,
        ),
      RepoCreationSuccess() ||
      RepoCreationFailure() =>
        RepoCreationPending(location: location),
    };

    emit(state.copyWith(substate: substate));
  }

  void _setInvalidName(String error) {
    final substate = switch (state.substate) {
      RepoCreationPending(setLocalSecret: final setLocalSecret) =>
        RepoCreationPending(setLocalSecret: setLocalSecret, nameError: error),
      RepoCreationValid(setLocalSecret: final setLocalSecret) =>
        RepoCreationPending(setLocalSecret: setLocalSecret, nameError: error),
      RepoCreationSuccess() ||
      RepoCreationFailure() =>
        RepoCreationPending(nameError: error),
    };

    emit(state.copyWith(substate: substate));
  }

  //// DEBUG
  //@override
  //void onChange(Change<RepoCreationState> change) {
  //  super.onChange(change);
  //  print(change.nextState);
  //}
}
