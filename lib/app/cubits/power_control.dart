import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../generated/l10n.dart';
import '../utils/hotspot.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/settings.dart';

const _unspecifiedV4 = "0.0.0.0:0";
const _unspecifiedV6 = "[::]:0";
const bool _syncOnMobileDefault = true;
const bool _portForwardingEnabledDefault = true;

class PowerControlState {
  final ConnectivityResult connectivityType;
  final NetworkMode networkMode;
  final bool syncOnMobile;
  final bool portForwardingEnabled;

  PowerControlState({
    this.connectivityType = ConnectivityResult.none,
    this.networkMode = NetworkMode.disabled,
    this.syncOnMobile = _syncOnMobileDefault,
    this.portForwardingEnabled = false,
  });

  PowerControlState copyWith({
    ConnectivityResult? connectivityType,
    NetworkMode? networkMode,
    bool? syncOnMobile,
    bool? portForwardingEnabled,
  }) =>
      PowerControlState(
        connectivityType: connectivityType ?? this.connectivityType,
        networkMode: networkMode ?? this.networkMode,
        syncOnMobile: syncOnMobile ?? this.syncOnMobile,
        portForwardingEnabled:
            portForwardingEnabled ?? this.portForwardingEnabled,
      );

  // Null means the answer is not yet known (the init function hasn't finished
  // or was not called yet).
  bool? get isNetworkEnabled {
    switch (networkMode) {
      case NetworkMode.full:
        return true;
      case NetworkMode.saving:
      case NetworkMode.disabled:
        return false;
    }
  }

  String? get networkDisabledReason {
    switch (networkMode) {
      case NetworkMode.full:
        return null;
      case NetworkMode.saving:
        return S.current.messageSyncingIsDisabledOnMobileInternet;
      case NetworkMode.disabled:
        return S.current.messageNetworkIsUnavailable;
    }
  }
}

class PowerControl extends Cubit<PowerControlState> with OuiSyncAppLogger {
  final oui.Session _session;
  final Settings _settings;
  final Connectivity _connectivity = Connectivity();
  _Transition _networkModeTransition = _Transition.none;

  PowerControl(this._session, this._settings)
      : super(PowerControlState(
            portForwardingEnabled: _session.isPortForwardingEnabled));

  Future<void> init() async {
    unawaited(_listen());

    final syncOnMobile =
        _settings.getSyncOnMobileEnabled() ?? _syncOnMobileDefault;
    final portForwardingEnabled =
        _settings.getPortForwardingEnabled() ?? _portForwardingEnabledDefault;

    emit(state.copyWith(
      syncOnMobile: syncOnMobile,
      portForwardingEnabled: portForwardingEnabled,
    ));

    await _refresh();
  }

  Future<void> setSyncOnMobileEnabled(bool value) async {
    if (state.syncOnMobile == value) {
      return;
    }

    emit(state.copyWith(syncOnMobile: value));

    await _settings.setSyncOnMobileEnabled(value);
    await _refresh();
  }

  Future<void> setPortForwardingEnabled(bool value) async {
    if (state.portForwardingEnabled == value) {
      return;
    }

    emit(state.copyWith(portForwardingEnabled: value));

    if (value) {
      _session.enablePortForwarding();
    } else {
      _session.disablePortForwarding();
    }

    await _settings.setPortForwardingEnabled(value);
  }

  Future<void> _listen() async {
    final result = await _connectivity.checkConnectivity();
    await _onConnectivityChange(result);

    final stream = _connectivity.onConnectivityChanged;

    await for (var result in stream) {
      await _onConnectivityChange(result);
    }
  }

  Future<void> _onConnectivityChange(ConnectivityResult result) async {
    loggy.app('Connectivity event: ${result.name}');

    emit(state.copyWith(connectivityType: result));

    var newMode = NetworkMode.disabled;

    switch (result) {
      case ConnectivityResult.bluetooth:
        newMode = NetworkMode.disabled;
        break;
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        newMode = NetworkMode.full;
        break;
      case ConnectivityResult.mobile:
        if (state.syncOnMobile) {
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
    }

    await _setNetworkMode(newMode);
  }

  Future<void> _refresh() async =>
      _onConnectivityChange(await _connectivity.checkConnectivity());

  Future<void> _setNetworkMode(NetworkMode mode, {force = false}) async {
    if (mode != state.networkMode || force) {
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
      await _setNetworkMode(state.networkMode, force: true);
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
