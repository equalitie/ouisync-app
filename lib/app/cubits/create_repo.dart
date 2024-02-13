import 'dart:io' as io;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../utils/utils.dart';
import 'cubits.dart';

class CreateRepositoryState extends Equatable {
  final bool isBiometricsAvailable;
  final ShareToken? shareToken;
  final bool isBlindReplica;
  final bool secureWithBiometrics;
  final bool addPassword;

  final AccessMode accessModeGranted;
  final String suggestedName;

  final bool obscurePassword;
  final bool obscureRetypePassword;

  final bool showSuggestedName;
  final bool showAccessModeMessage;
  final bool showSavePasswordWarning;
  final bool showRepositoryNameInUseWarning;

  CreateRepositoryState(
      {required this.isBiometricsAvailable,
      required this.shareToken,
      required this.isBlindReplica,
      required this.secureWithBiometrics,
      required this.addPassword,
      required this.accessModeGranted,
      required this.suggestedName,
      required this.obscurePassword,
      required this.obscureRetypePassword,
      required this.showSuggestedName,
      required this.showAccessModeMessage,
      required this.showSavePasswordWarning,
      required this.showRepositoryNameInUseWarning});

  CreateRepositoryState copyWith(
          {bool? isBiometricsAvailable,
          ShareToken? shareToken,
          bool? isBlindReplica,
          bool? secureWithBiometrics,
          bool? addPassword,
          AccessMode? accessModeGranted,
          String? suggestedName,
          bool? obscurePassword,
          bool? obscureRetypePassword,
          bool? showSuggestedName,
          bool? showAccessModeMessage,
          bool? showSavePasswordWarning,
          bool? showRepositoryNameInUseWarning}) =>
      CreateRepositoryState(
          isBiometricsAvailable:
              isBiometricsAvailable ?? this.isBiometricsAvailable,
          shareToken: shareToken ?? this.shareToken,
          isBlindReplica: isBlindReplica ?? this.isBlindReplica,
          secureWithBiometrics:
              secureWithBiometrics ?? this.secureWithBiometrics,
          addPassword: addPassword ?? this.addPassword,
          accessModeGranted: accessModeGranted ?? this.accessModeGranted,
          suggestedName: suggestedName ?? this.suggestedName,
          obscurePassword: obscurePassword ?? this.obscurePassword,
          obscureRetypePassword:
              obscureRetypePassword ?? this.obscureRetypePassword,
          showSuggestedName: showSuggestedName ?? this.showSuggestedName,
          showAccessModeMessage:
              showAccessModeMessage ?? this.showAccessModeMessage,
          showSavePasswordWarning:
              showSavePasswordWarning ?? this.showSavePasswordWarning,
          showRepositoryNameInUseWarning: showRepositoryNameInUseWarning ??
              this.showRepositoryNameInUseWarning);

  @override
  List<Object?> get props => [
        isBiometricsAvailable,
        shareToken,
        isBlindReplica,
        secureWithBiometrics,
        addPassword,
        accessModeGranted,
        suggestedName,
        obscurePassword,
        obscureRetypePassword,
        showSuggestedName,
        showAccessModeMessage,
        showSavePasswordWarning,
        showRepositoryNameInUseWarning,
      ];
}

class CreateRepositoryCubit extends Cubit<CreateRepositoryState>
    with AppLogger {
  CreateRepositoryCubit._(this._reposCubit, super.state);

  final ReposCubit _reposCubit;

  Future<io.Directory> get defaultRepoLocation =>
      _reposCubit.settings.defaultRepoLocation();

  static CreateRepositoryCubit create(
      {required ReposCubit reposCubit,
      required bool isBiometricsAvailable,
      required ShareToken? shareToken,
      required bool isBlindReplica,
      required String? suggestedName,
      required AccessMode? accessModeGranted,
      required bool showSuggestedName,
      required bool showAccessModeMessage}) {
    var initialState = CreateRepositoryState(
        isBiometricsAvailable: isBiometricsAvailable,
        shareToken: shareToken,
        isBlindReplica: isBlindReplica,
        secureWithBiometrics: false,
        addPassword: false,
        accessModeGranted: accessModeGranted ?? AccessMode.blind,
        suggestedName: suggestedName ?? '',
        obscurePassword: true,
        obscureRetypePassword: true,
        showSuggestedName: showSuggestedName,
        showAccessModeMessage: showAccessModeMessage,
        showSavePasswordWarning: false,
        showRepositoryNameInUseWarning: false);

    return CreateRepositoryCubit._(reposCubit, initialState);
  }

  void addPassword(bool add) => emit(state.copyWith(addPassword: add));

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
}
