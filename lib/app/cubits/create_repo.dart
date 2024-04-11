import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../utils/utils.dart';
import 'cubits.dart';

class CreateRepositoryState extends Equatable {
  final bool isBiometricsAvailable;
  final ShareToken? shareToken;
  final AccessMode accessMode;
  final LocalSecretMode localSecretMode;

  final String suggestedName;

  final bool obscurePassword;
  final bool obscureRetypePassword;

  final bool showAccessModeMessage;
  final bool showSavePasswordWarning;
  final bool showRepositoryNameInUseWarning;

  final bool useCacheServers;

  CreateRepositoryState({
    required this.isBiometricsAvailable,
    required this.shareToken,
    required this.accessMode,
    required this.localSecretMode,
    required this.suggestedName,
    required this.obscurePassword,
    required this.obscureRetypePassword,
    required this.showAccessModeMessage,
    required this.showSavePasswordWarning,
    required this.showRepositoryNameInUseWarning,
    required this.useCacheServers,
  });

  CreateRepositoryState copyWith({
    bool? isBiometricsAvailable,
    ShareToken? shareToken,
    AccessMode? accessMode,
    LocalSecretMode? localSecretMode,
    bool? secureWithBiometrics,
    String? suggestedName,
    bool? obscurePassword,
    bool? obscureRetypePassword,
    bool? showSuggestedName,
    bool? showAccessModeMessage,
    bool? showSavePasswordWarning,
    bool? showRepositoryNameInUseWarning,
    bool? useCacheServers,
  }) =>
      CreateRepositoryState(
        isBiometricsAvailable:
            isBiometricsAvailable ?? this.isBiometricsAvailable,
        shareToken: shareToken ?? this.shareToken,
        accessMode: accessMode ?? this.accessMode,
        localSecretMode: localSecretMode ?? this.localSecretMode,
        suggestedName: suggestedName ?? this.suggestedName,
        obscurePassword: obscurePassword ?? this.obscurePassword,
        obscureRetypePassword:
            obscureRetypePassword ?? this.obscureRetypePassword,
        showAccessModeMessage:
            showAccessModeMessage ?? this.showAccessModeMessage,
        showSavePasswordWarning:
            showSavePasswordWarning ?? this.showSavePasswordWarning,
        showRepositoryNameInUseWarning: showRepositoryNameInUseWarning ??
            this.showRepositoryNameInUseWarning,
        useCacheServers: useCacheServers ?? this.useCacheServers,
      );

  @override
  List<Object?> get props => [
        isBiometricsAvailable,
        shareToken,
        accessMode,
        localSecretMode,
        suggestedName,
        obscurePassword,
        obscureRetypePassword,
        showAccessModeMessage,
        showSavePasswordWarning,
        showRepositoryNameInUseWarning,
        useCacheServers,
      ];
}

class CreateRepositoryCubit extends Cubit<CreateRepositoryState>
    with AppLogger {
  CreateRepositoryCubit._(this._reposCubit, super.state);

  final ReposCubit _reposCubit;

  Future<io.Directory> get defaultRepoLocation =>
      _reposCubit.settings.defaultRepoLocation();

  static Future<CreateRepositoryCubit> create({
    required ReposCubit reposCubit,
    required bool isBiometricsAvailable,
    required AccessMode accessMode,
    required bool showSuggestedName,
    required bool showAccessModeMessage,
    ShareToken? shareToken,
    String? suggestedName,
  }) async {
    // When importing existing repository check if the cache servers have been already enabled.
    final useCacheServers =
        (shareToken != null) ? await shareToken.isCacheServersEnabled() : true;

    var initialState = CreateRepositoryState(
      isBiometricsAvailable: isBiometricsAvailable,
      shareToken: shareToken,
      accessMode: accessMode,
      localSecretMode: LocalSecretMode.randomStored,
      suggestedName: suggestedName ?? '',
      obscurePassword: true,
      obscureRetypePassword: true,
      showAccessModeMessage: showAccessModeMessage,
      showSavePasswordWarning: false,
      showRepositoryNameInUseWarning: false,
      useCacheServers: useCacheServers,
    );

    return CreateRepositoryCubit._(reposCubit, initialState);
  }

  void setLocalSecretMode(LocalSecretMode value) =>
      emit(state.copyWith(localSecretMode: value));

  void secureWithBiometrics(bool useBiometrics) =>
      emit(state.copyWith(secureWithBiometrics: useBiometrics));

  void showSuggestedName(bool show) =>
      emit(state.copyWith(showSuggestedName: show));

  void showRepositoryNameInUseWarning(bool show) =>
      emit(state.copyWith(showRepositoryNameInUseWarning: show));

  void showSavePasswordWarning(bool show) =>
      emit(state.copyWith(showSavePasswordWarning: show));

  void obscurePassword(bool obscure) =>
      emit(state.copyWith(obscurePassword: obscure));

  void obscureRetypePassword(bool obscure) =>
      emit(state.copyWith(obscureRetypePassword: obscure));

  void useCacheServers(bool enable) =>
      emit(state.copyWith(useCacheServers: enable));
}
