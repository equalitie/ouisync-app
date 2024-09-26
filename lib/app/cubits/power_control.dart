import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' as oui;
import 'package:equatable/equatable.dart';

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
  final bool userWantsSyncOnMobileEnabled;
  final bool userWantsPortForwardingEnabled;
  final bool userWantsLocalDiscoveryEnabled;

  final bool? isLocalDiscoveryEnabled;

  PowerControlState({
    this.connectivityType = ConnectivityResult.none,
    this.networkMode,
    this.userWantsSyncOnMobileEnabled = false,
    this.userWantsPortForwardingEnabled = false,
    this.userWantsLocalDiscoveryEnabled = false,
    this.isLocalDiscoveryEnabled,
  });

  PowerControlState copyWith({
    ConnectivityResult? connectivityType,
    NetworkMode? networkMode,
    bool? userWantsSyncOnMobileEnabled,
    bool? userWantsPortForwardingEnabled,
    bool? userWantsLocalDiscoveryEnabled,
    bool? isLocalDiscoveryEnabled,
  }) =>
      PowerControlState(
        connectivityType: connectivityType ?? this.connectivityType,
        networkMode: networkMode ?? this.networkMode,
        userWantsSyncOnMobileEnabled:
            userWantsSyncOnMobileEnabled ?? this.userWantsSyncOnMobileEnabled,
        userWantsPortForwardingEnabled: userWantsPortForwardingEnabled ??
            this.userWantsPortForwardingEnabled,
        userWantsLocalDiscoveryEnabled: userWantsLocalDiscoveryEnabled ??
            this.userWantsLocalDiscoveryEnabled,
        isLocalDiscoveryEnabled:
            isLocalDiscoveryEnabled ?? this.isLocalDiscoveryEnabled,
      );

  // Null means the answer is not yet known (the init function hasn't finished
  // or was not called yet).
  bool? get isInternetConnectivityEnabled {
    return networkMode?.allowsInternetConnections;
  }

  String? get internetConnectivityDisabledReason {
    return networkMode?.disallowsInternetConnectivityReason;
  }

  String? get localDiscoveryDisabledReason {
    return networkMode?.disallowsLocalConnectivityReason;
  }

  @override
  String toString() =>
      "PowerControlState($connectivityType, $networkMode, userWantsSyncOnMobileEnabled:$userWantsSyncOnMobileEnabled, ...)";
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

    final userWantsLocalDiscoveryEnabled = _settings.getLocalDiscoveryEnabled();
    await setLocalDiscoveryEnabled(userWantsLocalDiscoveryEnabled);
    final isLocalDiscoveryEnabled = await _session.isLocalDiscoveryEnabled;

    // TODO: We should be getting this from `_settings` here.
    final userWantsPortForwarding = await _session.isPortForwardingEnabled;

    emitUnlessClosed(state.copyWith(
      userWantsPortForwardingEnabled: userWantsPortForwarding,
      userWantsLocalDiscoveryEnabled: userWantsLocalDiscoveryEnabled,
      isLocalDiscoveryEnabled: isLocalDiscoveryEnabled,
    ));

    await _refresh();
    await _listen();
  }

  Future<void> setSyncOnMobileEnabled(bool value) async {
    if (state.userWantsSyncOnMobileEnabled == value) {
      return;
    }

    await _settings.setSyncOnMobileEnabled(value);
    await _refresh(userWantsSyncOnMobileEnabled: value);
  }

  Future<void> setPortForwardingEnabled(bool value) async {
    if (state.userWantsPortForwardingEnabled == value) {
      return;
    }

    emit(state.copyWith(userWantsPortForwardingEnabled: value));

    await _session.setPortForwardingEnabled(value);
  }

  Future<void> setLocalDiscoveryEnabled(bool value) async {
    bool changed = state.userWantsLocalDiscoveryEnabled != value;

    if (changed) {
      await _settings.setLocalDiscoveryEnabled(value);
      await _session.setLocalDiscoveryEnabled(value);
    }

    final isLocalDiscoveryEnabled = await _session.isLocalDiscoveryEnabled;

    emitUnlessClosed(state.copyWith(
        userWantsLocalDiscoveryEnabled: value,
        isLocalDiscoveryEnabled: isLocalDiscoveryEnabled));
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
      {bool? userWantsSyncOnMobileEnabled = null}) async {
    _updateConnectivity(result,
        userWantsSyncOnMobileEnabled: userWantsSyncOnMobileEnabled);

    await setLocalDiscoveryEnabled(state.userWantsLocalDiscoveryEnabled);
  }

  Future<void> _updateConnectivity(ConnectivityResult result,
      {bool? userWantsSyncOnMobileEnabled = null}) async {
    userWantsSyncOnMobileEnabled ??= state.userWantsSyncOnMobileEnabled;

    if (result == state.connectivityType &&
        userWantsSyncOnMobileEnabled == state.userWantsSyncOnMobileEnabled) {
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
        userWantsSyncOnMobileEnabled: userWantsSyncOnMobileEnabled));

    NetworkMode newMode = NetworkModeDisabled();

    switch (result) {
      case ConnectivityResult.bluetooth:
        newMode = NetworkModeDisabled();
        break;
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        newMode = NetworkModeFull(isMobile: false);
        break;
      case ConnectivityResult.mobile:
        if (state.userWantsSyncOnMobileEnabled) {
          newMode = NetworkModeFull(isMobile: true);
        } else {
          final hotspotIp = await findHotspotIp();
          final hotspotAddr = hotspotIp != null ? "$hotspotIp:0" : null;
          newMode = NetworkModeSaving(hotspotAddr: hotspotAddr);
        }
        break;
      case ConnectivityResult.none:
        // For now we keep the network enabled. It is because when we're tethering and
        // mobile internet is not enabled we get here as well. Ideally we would have
        // also the information about whether tethering is enabled and only in such case
        // we'd keep the connection going.
        newMode = NetworkModeFull(isMobile: false);
        break;
      case ConnectivityResult.other:
    }

    await _setNetworkMode(newMode);
  }

  Future<void> _refresh(
      {bool? userWantsSyncOnMobileEnabled = null,
      bool? userWantsLocalDiscoveryEnabled = null}) async {
    final conn = (await _connectivity.checkConnectivity()).last;

    await _onConnectivityChange(conn,
        userWantsSyncOnMobileEnabled: userWantsSyncOnMobileEnabled);
  }

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
      case NetworkModeFull():
        quicV4 = _unspecifiedV4;
        quicV6 = _unspecifiedV6;
        break;
      case NetworkModeSaving(hotspotAddr: final hotspotAddr):
        quicV4 = hotspotAddr;
        quicV6 = null;
        break;
      case NetworkModeDisabled():
        quicV4 = null;
        quicV6 = null;
        break;
    }

    try {
      await _session.bindNetwork(quicV4: quicV4, quicV6: quicV6);
    } catch (e) {
      emit(state.copyWith(networkMode: NetworkModeDisabled()));
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

sealed class NetworkMode extends Equatable {
  bool get allowsInternetConnections =>
      disallowsInternetConnectivityReason == null;
  bool get allowsLocalConnections => disallowsLocalConnectivityReason == null;

  String? get disallowsInternetConnectivityReason;
  String? get disallowsLocalConnectivityReason;

  @override
  List<Object> get props => [];
}

/// Unrestricted network - any internet connection is enabled
class NetworkModeFull extends NetworkMode {
  bool isMobile;

  NetworkModeFull({required this.isMobile});

  @override
  String? get disallowsInternetConnectivityReason => null;

  @override
  String? get disallowsLocalConnectivityReason => isMobile
      ? S.current.messageLocalDiscoveryNotAvailableOnMobileNetwork
      : null;

  @override
  List<Object> get props => [isMobile];

  @override
  String toString() => "NetworkModeFull(isMobile: $isMobile)";
}

/// *Mobile* data saving mode - only local connections on the hotspot provided
/// by this device (if any) are enabled.
class NetworkModeSaving extends NetworkMode {
  String? hotspotAddr;

  NetworkModeSaving({required this.hotspotAddr});

  @override
  String? get disallowsInternetConnectivityReason =>
      S.current.messageSyncingIsDisabledOnMobileInternet;

  @override
  String? get disallowsLocalConnectivityReason => hotspotAddr == null
      ? S.current.messageLocalDiscoveryNotAvailableOnMobileNetwork
      : null;

  @override
  List<Object> get props {
    final addr = hotspotAddr;
    return addr != null ? [addr] : [];
  }

  @override
  String toString() => "NetworkModeSaving(hotspotAddr: $hotspotAddr)";
}

/// Network is disabled
class NetworkModeDisabled extends NetworkMode {
  @override
  String get disallowsInternetConnectivityReason =>
      S.current.messageNetworkIsUnavailable;

  @override
  get disallowsLocalConnectivityReason => S.current.messageNetworkIsUnavailable;

  @override
  String toString() => "NetworkModeDisabled()";
}

enum _Transition {
  none,
  ongoing,
  queued,
}
