import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart'
    show
        AccessMode,
        SetLocalSecret,
        SetLocalSecretKeyAndSalt,
        SetLocalSecretPassword,
        ShareToken;

import '../../generated/l10n.dart';
import '../models/models.dart'
    show
        ErrorRepoEntry,
        LocalSecretInput,
        LocalSecretManual,
        LocalSecretMode,
        LocalSecretRandom,
        LoadingRepoEntry,
        MissingRepoEntry,
        OpenRepoEntry,
        RepoLocation;
import '../utils/random.dart';
import '../utils/utils.dart' show AppLogger, Strings;
import 'cubits.dart' show CubitActions, ReposCubit;

class RepoCreationState {
  static const initialLocalSecretMode = LocalSecretMode.randomStored;

  final AccessMode accessMode;
  final LocalSecretMode localSecretMode;
  final RepoCreationSubstate substate;
  final String suggestedName;
  final ShareToken? token;
  final bool useCacheServers;

  RepoCreationState({
    this.accessMode = AccessMode.write,
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
    RepoCreationSubstate? substate,
    String? suggestedName,
    ShareToken? token,
    bool? useCacheServers,
  }) => RepoCreationState(
    accessMode: accessMode ?? this.accessMode,
    localSecretMode: localSecretMode ?? this.localSecretMode,
    substate: substate ?? this.substate,
    suggestedName: suggestedName ?? this.suggestedName,
    token: token ?? this.token,
    useCacheServers: useCacheServers ?? this.useCacheServers,
  );

  RepoLocation? get location => switch (substate) {
    RepoCreationPending(location: final location) => location,
    RepoCreationValid(location: final location) ||
    RepoCreationFailure(location: final location) => location,
    RepoCreationSuccess(entry: final entry) => entry.location,
  };

  String? get name => location?.name;

  String? get nameError => switch (substate) {
    RepoCreationPending(nameError: final nameError) => nameError,
    _ => null,
  };

  String? get dir => switch (substate) {
    RepoCreationPending(dir: final dir) => dir,
    _ => location?.dir,
  };

  @override
  String toString() =>
      '$runtimeType(substate: $substate, suggestedName: $suggestedName, useCacheServers: $useCacheServers, ..)';
}

sealed class RepoCreationSubstate {
  const RepoCreationSubstate();
}

class RepoCreationPending extends RepoCreationSubstate {
  const RepoCreationPending({
    this.name,
    this.nameError,
    this.dir,
    this.setLocalSecret,
  });

  final String? name;
  final String? nameError;
  final String? dir;
  final SetLocalSecret? setLocalSecret;

  RepoLocation? get location => (name != null && dir != null)
      ? RepoLocation(dir: dir!, name: name!)
      : null;

  RepoCreationPending copyWith({String? dir, SetLocalSecret? setLocalSecret}) =>
      RepoCreationPending(
        name: name,
        nameError: nameError,
        dir: dir ?? this.dir,
        setLocalSecret: setLocalSecret ?? this.setLocalSecret,
      );

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

  RepoCreationValid copyWith({
    RepoLocation? location,
    SetLocalSecret? setLocalSecret,
  }) => RepoCreationValid(
    location: location ?? this.location,
    setLocalSecret: setLocalSecret ?? this.setLocalSecret,
  );

  @override
  String toString() =>
      '$runtimeType(location: $location, setLocalSecret: $setLocalSecret)';
}

class RepoCreationSuccess extends RepoCreationSubstate {
  const RepoCreationSuccess({required this.entry});

  final OpenRepoEntry entry;
}

class RepoCreationFailure extends RepoCreationSubstate {
  const RepoCreationFailure({required this.location, required this.error});

  final RepoLocation location;
  final String error;

  RepoCreationFailure copyWith({RepoLocation? location, String? error}) =>
      RepoCreationFailure(
        location: location ?? this.location,
        error: error ?? this.error,
      );
}

class RepoCreationCubit extends Cubit<RepoCreationState>
    with CubitActions, AppLogger {
  RepoCreationCubit({required this.reposCubit}) : super(RepoCreationState()) {
    nameController.addListener(_onLocationChangedUnawaited);

    setLocalSecret(LocalSecretRandom());

    // Set initial dir to the first store dir
    unawaited(
      reposCubit.session
          .getStoreDirs()
          .then((dirs) {
            final substate = state.substate;
            final dir = dirs.firstOrNull;

            if (dir == null) {
              return;
            }

            if (substate is! RepoCreationPending || substate.dir != null) {
              return;
            }

            emitUnlessClosed(
              state.copyWith(substate: substate.copyWith(dir: dir)),
            );
          })
          .then((_) => _onLocationChanged()),
    );
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

    final accessMode = await reposCubit.session.getShareTokenAccessMode(token);
    final suggestedName = await reposCubit.session.getShareTokenSuggestedName(
      token,
    );
    final useCacheServers = await reposCubit.cacheServers
        .isEnabledForShareToken(token);

    emitUnlessClosed(
      state.copyWith(
        accessMode: accessMode,
        suggestedName: suggestedName,
        token: token,
        useCacheServers: useCacheServers,
      ),
    );
  }

  void acceptSuggestedName() {
    nameController.text = state.suggestedName;
    positiveButtonFocusNode.requestFocus();
  }

  void setUseCacheServers(bool value) {
    emitUnlessClosed(state.copyWith(useCacheServers: value));
  }

  void setLocalSecret(LocalSecretInput input) {
    final setLocalSecret = switch ((state.accessMode, input)) {
      (AccessMode.blind, _) || (_, LocalSecretRandom()) =>
        SetLocalSecretKeyAndSalt(key: randomSecretKey(), salt: randomSalt()),
      (_, LocalSecretManual(password: final password)) =>
        SetLocalSecretPassword(password),
    };

    final oldSubstate = state.substate;
    final newSubstate = switch (oldSubstate) {
      RepoCreationPending(location: final location) when location != null =>
        RepoCreationValid(location: location, setLocalSecret: setLocalSecret),
      RepoCreationPending() => oldSubstate.copyWith(
        setLocalSecret: setLocalSecret,
      ),
      RepoCreationValid() => oldSubstate.copyWith(
        setLocalSecret: setLocalSecret,
      ),
      RepoCreationSuccess(entry: final entry) => RepoCreationValid(
        location: entry.location,
        setLocalSecret: setLocalSecret,
      ),
      RepoCreationFailure(location: final location) => RepoCreationValid(
        location: location,
        setLocalSecret: setLocalSecret,
      ),
    };

    emitUnlessClosed(
      state.copyWith(substate: newSubstate, localSecretMode: input.mode),
    );
  }

  void setDir(String dir) {
    final oldSubstate = state.substate;
    final newSubstate = switch (oldSubstate) {
      RepoCreationPending() => oldSubstate.copyWith(dir: dir),
      RepoCreationValid(location: final location) => oldSubstate.copyWith(
        location: location.relocate(dir),
      ),
      RepoCreationSuccess() => oldSubstate,
      RepoCreationFailure(location: final location) => oldSubstate.copyWith(
        location: location.relocate(dir),
      ),
    };

    emitUnlessClosed(state.copyWith(substate: newSubstate));
  }

  Future<void> save() async {
    // On some devices the `_onLocationChangedUnawaited` listener is still called
    // after this `save` function is called. When that happens and we already
    // created the repository, it'll complain that the repository with the name
    // in the `nameController` already exists, even though it's this cubit that
    // created it. So we remove the listener to not pester the user.
    nameController.removeListener(_onLocationChangedUnawaited);

    final substate = state.substate;
    if (substate is! RepoCreationValid) {
      return;
    }

    final localSecretMode = switch (state.accessMode) {
      AccessMode.read || AccessMode.write => state.localSecretMode,
      AccessMode.blind => LocalSecretMode.manual,
    };

    final repoEntry = await reposCubit.createRepository(
      location: substate.location,
      setLocalSecret: substate.setLocalSecret,
      token: state.token,
      localSecretMode: localSecretMode,
      useCacheServers: state.useCacheServers,
      setCurrent: true,
    );

    switch (repoEntry) {
      case OpenRepoEntry():
        emitUnlessClosed(
          state.copyWith(substate: RepoCreationSuccess(entry: repoEntry)),
        );
      case ErrorRepoEntry():
        emitUnlessClosed(
          state.copyWith(
            substate: RepoCreationFailure(
              location: substate.location,
              error: repoEntry.error,
            ),
          ),
        );
      case LoadingRepoEntry():
      case MissingRepoEntry():
        throw 'unreachable code';
    }
  }

  void _onLocationChangedUnawaited() {
    unawaited(_onLocationChanged());
  }

  Future<void> _onLocationChanged() async {
    final name = nameController.text.trim();

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

    final dir = state.dir;
    if (dir == null) {
      return;
    }

    // Check whether repo with this name already exists in this store dir
    final location = RepoLocation(dir: dir, name: name);
    final exists = await File(location.path).exists();

    if (exists) {
      _setInvalidName(S.current.messageErrorRepositoryNameExist);
      return;
    }

    _setLocation(location);
  }

  void _setLocation(RepoLocation location) {
    final substate = switch (state.substate) {
      RepoCreationPending(setLocalSecret: final setLocalSecret)
          when setLocalSecret != null =>
        RepoCreationValid(location: location, setLocalSecret: setLocalSecret),
      RepoCreationPending(setLocalSecret: final setLocalSecret) =>
        RepoCreationPending(
          setLocalSecret: setLocalSecret,
          name: location.name,
          dir: location.dir,
        ),
      RepoCreationValid(setLocalSecret: final setLocalSecret) =>
        RepoCreationValid(location: location, setLocalSecret: setLocalSecret),
      RepoCreationSuccess() || RepoCreationFailure() => RepoCreationPending(
        name: location.name,
        dir: location.dir,
      ),
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
      RepoCreationFailure() => RepoCreationPending(nameError: error),
    };

    emitUnlessClosed(state.copyWith(substate: substate));
  }

  //// DEBUG
  //@override
  //void onChange(Change<RepoCreationState> change) {
  //  super.onChange(change);
  //  loggy.debug(change.nextState);
  //}
}
