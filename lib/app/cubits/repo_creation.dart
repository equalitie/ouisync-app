import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show AccessMode, ShareToken;

import '../../generated/l10n.dart';
import '../models/auth_mode.dart';
import '../models/local_secret.dart';
import '../models/repo_entry.dart';
import '../models/repo_location.dart';
import '../utils/dialogs.dart';
import '../utils/log.dart';
import '../utils/strings.dart';
import 'repos.dart';
import 'utils.dart';

class RepoCreationState {
  static const initialLocalSecretMode = LocalSecretMode.randomStored;

  final AccessMode accessMode;
  final LocalSecretMode localSecretMode;
  final bool loading;
  final RepoCreationSubstate substate;
  final String suggestedName;
  final ShareToken? token;
  final bool useCacheServers;

  RepoCreationState({
    this.accessMode = AccessMode.write,
    this.loading = false,
    this.localSecretMode = initialLocalSecretMode,
    this.substate = const RepoCreationPending(),
    this.suggestedName = '',
    this.token,
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
    bool? useCacheServers,
  }) =>
      RepoCreationState(
        accessMode: accessMode ?? this.accessMode,
        localSecretMode: localSecretMode ?? this.localSecretMode,
        loading: loading ?? this.loading,
        substate: substate ?? this.substate,
        suggestedName: suggestedName ?? this.suggestedName,
        token: token ?? this.token,
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
    this.nameError,
  });

  final String? nameError;
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
    nameController.addListener(_onNameChangedUnawaited);

    setLocalSecret(LocalSecretRandom());
  }

  final ReposCubit reposCubit;

  final nameController = TextEditingController();
  final positiveButtonFocusNode = FocusNode();

  @override
  Future<void> close() async {
    nameController.dispose();
    positiveButtonFocusNode.dispose();

    await super.close();
  }

  Future<void> setToken(ShareToken? token) async {
    if (token == null) {
      return;
    }

    await _loading(
      () async {
        final accessMode = await token.mode;
        final suggestedName = await token.suggestedName;
        final useCacheServers =
            await reposCubit.cacheServers.isEnabledForShareToken(token);

        emit(state.copyWith(
          accessMode: accessMode,
          suggestedName: suggestedName,
          token: token,
          useCacheServers: useCacheServers,
        ));
      },
      showLoading: true,
    );
  }

  void acceptSuggestedName() {
    nameController.text = state.suggestedName;
    positiveButtonFocusNode.requestFocus();
  }

  void setUseCacheServers(bool value) {
    emit(state.copyWith(useCacheServers: value));
  }

  void setLocalSecret(LocalSecretInput input) {
    final setLocalSecret = switch ((state.accessMode, input)) {
      (AccessMode.blind, _) ||
      (_, LocalSecretRandom()) =>
        LocalSecretKeyAndSalt.random(),
      (_, LocalSecretManual(password: final password)) => password,
    };

    RepoCreationSubstate substate;

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

    emit(state.copyWith(substate: substate, localSecretMode: input.mode));
  }

  Future<void> save() async {
    // On some devices the `_onNameChangedUnawaited` listener is still called
    // after this `save` function is called. When that happens and we already
    // created the repository, it'll complain that the repository with the name
    // in the `nameController` already exists, even though it's this cubit that
    // created it. So we remove the listener to not pester the user.
    nameController.removeListener(_onNameChangedUnawaited);

    final substate = state.substate;
    if (substate is! RepoCreationValid) {
      return;
    }

    final localSecretMode = switch (state.accessMode) {
      AccessMode.read || AccessMode.write => state.localSecretMode,
      AccessMode.blind => LocalSecretMode.manual,
    };

    final repoEntry = await _loading(() => reposCubit.createRepository(
          location: substate.location,
          setLocalSecret: substate.setLocalSecret,
          token: state.token,
          localSecretMode: localSecretMode,
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

  Future<R> _loading<R>(
    Future<R> Function() f, {
    bool showLoading = false,
  }) async {
    try {
      emit(state.copyWith(loading: true));
      return showLoading
          ? await Dialogs.executeFutureWithLoadingDialog(null, f.call())
          : await f();
    } finally {
      if (!isClosed) {
        emit(state.copyWith(loading: false));
      }
    }
  }

  void _onNameChangedUnawaited() {
    unawaited(_onNameChanged());
  }

  Future<void> _onNameChanged() async {
    final name = nameController.text;

    if (name.isEmpty) {
      if (state.location != null) {
        _setInvalidName(S.current.messageErrorFormValidatorNameDefault);
      }

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

    emitUnlessClosed(state.copyWith(substate: substate));
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

    emitUnlessClosed(state.copyWith(substate: substate));
  }

  //// DEBUG
  //@override
  //void onChange(Change<RepoCreationState> change) {
  //  super.onChange(change);
  //  print(change.nextState);
  //}
}
