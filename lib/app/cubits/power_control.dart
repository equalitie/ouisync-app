import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' as oui;

import '../../generated/l10n.dart';
import '../utils/utils.dart';
import 'utils.dart';

const _unspecifiedV4 = "0.0.0.0:0";
const _unspecifiedV6 = "[::]:0";

class PowerControlState {
  final ConnectivityResult connectivityType;
  // We need the null state to express that we don't yet know what the mode is.
  // That information is needed by the warning widgets shown to the user (if
  // it's null then there is no warning). If we instead set this value to
  // `disabled` by default, then the warning would show up if only breafly
  // until `_onConnectivityChange` is invoked for the first time.
  final NetworkMode? networkMode;
  // These signify what the user wants based on what preferences they set in the app.
  // They do not signify what the actual state is.
  final bool userWantsSyncOnMobile;
  final bool userWantsPortForwardingEnabled;
  final bool userWantsLocalDiscoveryEnabled;

  PowerControlState({
    this.connectivityType = ConnectivityResult.none,
    this.networkMode,
    this.userWantsSyncOnMobile = false,
    this.userWantsPortForwardingEnabled = false,
    this.userWantsLocalDiscoveryEnabled = false,
  });

  PowerControlState copyWith({
    ConnectivityResult? connectivityType,
    NetworkMode? networkMode,
    bool? userWantsSyncOnMobile,
    bool? userWantsPortForwardingEnabled,
    bool? userWantsLocalDiscoveryEnabled,
  }) =>
      PowerControlState(
        connectivityType: connectivityType ?? this.connectivityType,
        networkMode: networkMode ?? this.networkMode,
        userWantsSyncOnMobile:
            userWantsSyncOnMobile ?? this.userWantsSyncOnMobile,
        userWantsPortForwardingEnabled: userWantsPortForwardingEnabled ??
            this.userWantsPortForwardingEnabled,
        userWantsLocalDiscoveryEnabled: userWantsLocalDiscoveryEnabled ??
            this.userWantsLocalDiscoveryEnabled,
      );

  // Null means the answer is not yet known (the init function hasn't finished
  // or was not called yet).
  bool? get isNetworkEnabled {
    final mode = networkMode;
    if (mode == null) return null;
    switch (mode) {
      case NetworkMode.full:
        return true;
      case NetworkMode.saving:
      case NetworkMode.disabled:
        return false;
    }
  }

  String? get networkDisabledReason {
    final mode = networkMode;
    if (mode == null) return null;
    switch (mode) {
      case NetworkMode.full:
        return null;
      case NetworkMode.saving:
        return S.current.messageSyncingIsDisabledOnMobileInternet;
      case NetworkMode.disabled:
        return S.current.messageNetworkIsUnavailable;
    }
  }

  @override
  String toString() =>
      "PowerControlState($connectivityType, $networkMode, userWantsSyncOnMobile:$userWantsSyncOnMobile, ...)";
}

class PowerControl extends Cubit<PowerControlState> with AppLogger {
  final oui.Session _session;
  final Settings _settings;
  final Connectivity _connectivity;
  _Transition _networkModeTransition = _Transition.none;

  PowerControl(
    this._session,
    this._settings, {
    Connectivity? connectivity,
  })  : _connectivity = connectivity ?? Connectivity(),
        super(PowerControlState()) {
    unawaited(_init());
  }

  Future<void> _init() async {
    final userWantsSyncOnMobile = _settings.getSyncOnMobileEnabled();
    await setSyncOnMobileEnabled(userWantsSyncOnMobile);

    final userWantsPortForwardingEnabled =
        await _session.isPortForwardingEnabled;
    final userWantsLocalDiscoveryEnabled =
        await _session.isLocalDiscoveryEnabled;

    emitUnlessClosed(state.copyWith(
      userWantsPortForwardingEnabled: userWantsPortForwardingEnabled,
      userWantsLocalDiscoveryEnabled: userWantsLocalDiscoveryEnabled,
    ));

    await _refresh();
    await _listen();
  }

  Future<void> setSyncOnMobileEnabled(bool value) async {
    if (state.userWantsSyncOnMobile == value) {
      return;
    }

    await _settings.setSyncOnMobileEnabled(value);
    await _refresh(userWantsSyncOnMobile: value);
  }

  Future<void> setPortForwardingEnabled(bool value) async {
    if (state.userWantsPortForwardingEnabled == value) {
      return;
    }

    emit(state.copyWith(userWantsPortForwardingEnabled: value));

    await _session.setPortForwardingEnabled(value);
  }

  Future<void> setLocalDiscoveryEnabled(bool value) async {
    if (state.userWantsLocalDiscoveryEnabled == value) {
      return;
    }

    emit(state.copyWith(userWantsLocalDiscoveryEnabled: value));

    await _session.setLocalDiscoveryEnabled(value);
  }

  Future<void> _listen() async {
    final result = await _connectivity.checkConnectivity();
    await _onConnectivityChange(result.last);

    final stream = _connectivity.onConnectivityChanged;

    await for (var result in stream) {
      await _onConnectivityChange(result.last);
    }
  }

  Future<void> _onConnectivityChange(ConnectivityResult result,
      {bool? userWantsSyncOnMobile = null}) async {
    userWantsSyncOnMobile ??= state.userWantsSyncOnMobile;

    if (result == state.connectivityType &&
        userWantsSyncOnMobile == state.userWantsSyncOnMobile) {
      // The Cubit/Bloc machinery knows not to rebuild widgets if the state
      // doesn't change, but in this function we also call
      // `_session.bindNetwork` which we don't necessarily want to do if the
      // connectivity type does not change. (Although with recent patches
      // `_session.bindNetwork` should be idempotent if local endpoints don't
      // change).
      loggy.app(
          'Connectivity event: ${result.name} (ignored, same as previous)');
      return;
    }

    loggy.app('Connectivity event: ${result.name}');

    emit(state.copyWith(
        connectivityType: result,
        userWantsSyncOnMobile: userWantsSyncOnMobile));

    var newMode = NetworkMode.disabled;

    switch (result) {
      case ConnectivityResult.bluetooth:
        newMode = NetworkMode.disabled;
        break;
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        newMode = NetworkMode.full;
        break;
      case ConnectivityResult.mobile:
        if (state.userWantsSyncOnMobile) {
          newMode = NetworkMode.full;
        } else {
          newMode = NetworkMode.saving;
        }
        break;
      case ConnectivityResult.none:
        // For now we keep the network enabled. It is because when we're tethering and
        // mobile internet is not enabled we get here as well. Ideally we would have
        // also the information about whether tethering is enabled and only in such case
        // we'd keep the connection going.
        newMode = NetworkMode.full;
        break;
      case ConnectivityResult.other:
    }

    await _setNetworkMode(newMode);
  }

  Future<void> _refresh({bool? userWantsSyncOnMobile = null}) async =>
      _onConnectivityChange((await _connectivity.checkConnectivity()).last,
          userWantsSyncOnMobile: userWantsSyncOnMobile);

  Future<void> _setNetworkMode(NetworkMode mode, {force = false}) async {
    if (state.networkMode == null || mode != state.networkMode || force) {
      loggy.app('Network mode: $mode');
      emit(state.copyWith(networkMode: mode));
    } else {
      return;
    }

    switch (_networkModeTransition) {
      case _Transition.none:
        _networkModeTransition = _Transition.ongoing;
        break;
      case _Transition.ongoing:
      case _Transition.queued:
        _networkModeTransition = _Transition.queued;
        return;
    }

    var transition = _Transition.none;
    String? quicV4;
    String? quicV6;

    switch (mode) {
      case NetworkMode.full:
        quicV4 = _unspecifiedV4;
        quicV6 = _unspecifiedV6;
        break;
      case NetworkMode.saving:
        final ip = await findHotspotIp();
        quicV4 = ip != null ? "$ip:0" : null;
        quicV6 = null;
        break;
      case NetworkMode.disabled:
        quicV4 = null;
        quicV6 = null;
        break;
    }

    try {
      await _session.bindNetwork(quicV4: quicV4, quicV6: quicV6);
    } catch (e) {
      emit(state.copyWith(networkMode: NetworkMode.disabled));
      rethrow;
    } finally {
      transition = _networkModeTransition;
      _networkModeTransition = _Transition.none;
    }

    if (transition == _Transition.queued) {
      // We set state.networkMode above, so it can't be null.
      await _setNetworkMode(state.networkMode!, force: true);
    } else {
      emit(state.copyWith());
    }
  }
}

enum NetworkMode {
  /// Unrestricted network - any connection is enabled
  full,

  /// Mobile data saving mode - only local connections on the hotspot provided by this device
  /// (if any) are enabled.
  saving,

  /// Network is disabled
  disabled,
}

enum _Transition {
  none,
  ongoing,
  queued,
}
