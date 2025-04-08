import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' as oui;

import '../../generated/l10n.dart';
import '../utils/utils.dart'
    show AppLogger, LocalInterfaceAddr, LocalInterfaceWatch, Settings;
import '../utils/watch.dart' as watch;
import 'cubits.dart' show CubitActions;

class PowerControlState {
  final ConnectivityResult connectivityType;
  // We need the null state to express that we don't yet know what the mode is.
  // That information is needed by the warning widgets shown to the user (if
  // it's null then there is no warning). If we instead set this value to
  // `disabled` by default, then the warning would show up if only breafly
  // until `_init` finishes.
  final NetworkMode? networkMode;
  // These signify what the user wants based on what preferences they set in the app.
  // They do not signify what the actual state is.
  final bool userWantsSyncOnMobileEnabled;
  final bool userWantsPortForwardingEnabled;
  final bool userWantsLocalDiscoveryEnabled;

  final bool? isLocalDiscoveryEnabled;
  final LocalInterfaceAddr? localInterface;

  PowerControlState({
    this.connectivityType = ConnectivityResult.none,
    this.networkMode,
    this.userWantsSyncOnMobileEnabled = false,
    this.userWantsPortForwardingEnabled = false,
    this.userWantsLocalDiscoveryEnabled = false,
    this.isLocalDiscoveryEnabled,
    this.localInterface,
  });

  PowerControlState copyWith({
    ConnectivityResult? connectivityType,
    NetworkMode? networkMode,
    bool? userWantsSyncOnMobileEnabled,
    bool? userWantsPortForwardingEnabled,
    bool? userWantsLocalDiscoveryEnabled,
    bool? isLocalDiscoveryEnabled,
    LocalInterfaceAddr? localInterface,
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
        localInterface: localInterface ?? this.localInterface,
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

  PowerControlState copyWithNetworkModeUpdate({
    ConnectivityResult? connectivityType,
    LocalInterfaceAddr? localInterface,
    bool? userWantsSyncOnMobileEnabled,
    bool? userWantsLocalDiscoveryEnabled,
  }) {
    final newState = copyWith(
      connectivityType: connectivityType,
      localInterface: localInterface,
      userWantsSyncOnMobileEnabled: userWantsSyncOnMobileEnabled,
      userWantsLocalDiscoveryEnabled: userWantsLocalDiscoveryEnabled,
    );

    final newNetworkMode = PowerControl._determineNetworkMode(
        connectivityType: newState.connectivityType,
        userWantsSyncOnMobileEnabled: newState.userWantsSyncOnMobileEnabled,
        userWantsLocalDiscoveryEnabled: newState.userWantsLocalDiscoveryEnabled,
        localInterface: newState.localInterface);

    return newState.copyWith(networkMode: newNetworkMode);
  }

  @override
  String toString() =>
      "PowerControlState($connectivityType, $networkMode, userWantsSyncOnMobileEnabled:$userWantsSyncOnMobileEnabled, ...)";
}

class PowerControl extends Cubit<PowerControlState>
    with AppLogger, CubitActions {
  final oui.Session _session;
  final Settings _settings;
  final Connectivity _connectivity;
  _Transition _networkModeTransition = _Transition.none;
  final LocalInterfaceWatch _localInterfaceWatch = LocalInterfaceWatch();

  PowerControl(
    this._session,
    this._settings, {
    Connectivity? connectivity,
  })  : _connectivity = connectivity ?? Connectivity(),
        super(PowerControlState()) {
    unawaited(_init());
  }

  @override
  Future<void> close() {
    _localInterfaceWatch.close();
    return super.close();
  }

  Future<void> _init() async {
    final userWantsSyncOnMobileEnabled = _settings.getSyncOnMobileEnabled();
    final userWantsLocalDiscoveryEnabled = _settings.getLocalDiscoveryEnabled();

    // TODO: We should be getting `userWantsPortForwardingEnabled` from `_settings`.
    final userWantsPortForwardingEnabled =
        await _session.isPortForwardingEnabled();
    final isLocalDiscoveryEnabled = await _session.isLocalDiscoveryEnabled();

    final connectivityType = (await _connectivity.checkConnectivity()).last;

    final newState = state
        .copyWith(
          userWantsPortForwardingEnabled: userWantsPortForwardingEnabled,
          isLocalDiscoveryEnabled: isLocalDiscoveryEnabled,
        )
        .copyWithNetworkModeUpdate(
          connectivityType: connectivityType,
          userWantsSyncOnMobileEnabled: userWantsSyncOnMobileEnabled,
          userWantsLocalDiscoveryEnabled: userWantsLocalDiscoveryEnabled,
        );

    await _updateNetworkMode(newState);

    unawaited(_listenToConnectivityChanges());
    unawaited(_listenToLocalNetworkInterfaceChanges());
  }

  Future<void> setSyncOnMobileEnabled(bool value) async {
    if (state.userWantsSyncOnMobileEnabled == value) {
      return;
    }

    await _settings.setSyncOnMobileEnabled(value);
    final newState =
        state.copyWithNetworkModeUpdate(userWantsSyncOnMobileEnabled: value);
    await _updateNetworkMode(newState);
  }

  Future<void> setPortForwardingEnabled(bool value) async {
    if (state.userWantsPortForwardingEnabled == value) {
      return;
    }

    emitUnlessClosed(state.copyWith(userWantsPortForwardingEnabled: value));

    await _session.setPortForwardingEnabled(value);
  }

  Future<void> setLocalDiscoveryEnabled(bool value) async {
    bool changed = state.userWantsLocalDiscoveryEnabled != value;

    if (changed) {
      await _settings.setLocalDiscoveryEnabled(value);
      await _session.setLocalDiscoveryEnabled(value);
    }

    final isLocalDiscoveryEnabled = await _session.isLocalDiscoveryEnabled();

    emitUnlessClosed(state.copyWith(
        userWantsLocalDiscoveryEnabled: value,
        isLocalDiscoveryEnabled: isLocalDiscoveryEnabled));
  }

  Future<void> _listenToConnectivityChanges() async {
    final result = await _connectivity.checkConnectivity();
    await _onConnectivityChange(result.last);

    final stream = _connectivity.onConnectivityChanged;

    await for (var result in stream) {
      await _onConnectivityChange(result.last);
    }
  }

  Future<void> _listenToLocalNetworkInterfaceChanges() async {
    while (true) {
      switch (await _localInterfaceWatch.onChange()) {
        case watch.Value(value: final iface):
          await _updateNetworkMode(
              state.copyWithNetworkModeUpdate(localInterface: iface));
          break;
        case watch.Closed():
          return;
      }
    }
  }

  Future<void> _onConnectivityChange(ConnectivityResult result) async {
    await _updateNetworkMode(
        state.copyWithNetworkModeUpdate(connectivityType: result));
  }

  Future<void> _updateNetworkMode(PowerControlState newState) async {
    final oldState = state.copyWith();

    if (!emitUnlessClosed(newState)) {
      return;
    }

    if (oldState.networkMode == newState.networkMode) {
      // The Cubit/Bloc machinery knows not to rebuild widgets if the state
      // doesn't change, but in this function we also call
      // `_session.bindNetwork` which we don't necessarily want to do if the
      // connectivity type does not change. (Although with recent patches
      // `_session.bindNetwork` should be idempotent if local endpoints don't
      // change).
      loggy.debug(
          'Network mode event: ${oldState.networkMode} -> ${newState.networkMode} (ignored, same as previous)');
      return;
    }

    loggy.debug(
        'NetworkMode event: ${oldState.networkMode} -> ${newState.networkMode}');

    await _setNetworkMode(newState.networkMode);
  }

  static NetworkMode _determineNetworkMode(
      {required ConnectivityResult connectivityType,
      required bool userWantsSyncOnMobileEnabled,
      required bool userWantsLocalDiscoveryEnabled,
      required LocalInterfaceAddr? localInterface}) {
    NetworkMode newMode = NetworkModeDisabled();

    switch (connectivityType) {
      case ConnectivityResult.bluetooth:
        newMode = NetworkModeDisabled();
        break;
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        newMode = NetworkModeFull();
        break;
      case ConnectivityResult.mobile:
        if (userWantsSyncOnMobileEnabled) {
          newMode = NetworkModeFull();
        } else {
          final hotspotIp = localInterface;
          final hotspotAddr =
              hotspotIp != null && userWantsLocalDiscoveryEnabled
                  ? "$hotspotIp:0"
                  : null;
          newMode = NetworkModeSaving(hotspotAddr: hotspotAddr);
        }
        break;
      case ConnectivityResult.none:
        // For now we keep the network enabled. It is because when we're tethering and
        // mobile internet is not enabled we get here as well. Ideally we would have
        // also the information about whether tethering is enabled and only in such case
        // we'd keep the connection going.
        newMode = NetworkModeFull();
        break;
      case ConnectivityResult.other:
    }
    return newMode;
  }

  Future<void> _setNetworkMode(NetworkMode? mode, {force = false}) async {
    // For when we have not yet received connectivity type. See comment on
    // `networkMode` member of `PowerControlState`.
    if (mode == null) {
      return;
    }

    loggy.debug('Setting network mode: $mode');

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
    final List<String> addrs;

    switch (mode) {
      case NetworkModeFull():
        addrs = ['quic/0.0.0.0:0', 'quic/[::]:0'];
        break;
      case NetworkModeSaving(hotspotAddr: final hotspotAddr):
        addrs = ['quic/$hotspotAddr'];
        break;
      case NetworkModeDisabled():
        addrs = [];
        break;
    }

    try {
      await _session.bindNetwork(addrs);
    } catch (e) {
      if (!emitUnlessClosed(
          state.copyWith(networkMode: NetworkModeDisabled()))) {
        return;
      }
      rethrow;
    } finally {
      transition = _networkModeTransition;
      _networkModeTransition = _Transition.none;
    }

    if (transition == _Transition.queued) {
      await _setNetworkMode(state.networkMode, force: true);
    } else {
      emitUnlessClosed(state.copyWith());
    }
  }
}

sealed class NetworkMode extends Equatable {
  bool get allowsInternetConnections;
  bool get allowsLocalConnections;

  String? get disallowsInternetConnectivityReason;
  String? get disallowsLocalConnectivityReason;

  @override
  List<Object> get props => [];
}

/// Unrestricted network - any internet connection is enabled
class NetworkModeFull extends NetworkMode {
  NetworkModeFull();

  @override
  bool get allowsInternetConnections => true;

  @override
  bool get allowsLocalConnections => true;

  @override
  String? get disallowsInternetConnectivityReason => null;

  @override
  String? get disallowsLocalConnectivityReason => null;

  @override
  List<Object> get props => [];

  @override
  String toString() => "NetworkModeFull()";
}

/// *Mobile* data saving mode - only local connections on the hotspot provided
/// by this device (if any) are enabled.
class NetworkModeSaving extends NetworkMode {
  final String? hotspotAddr;

  NetworkModeSaving({required this.hotspotAddr});

  @override
  bool get allowsInternetConnections => false;

  @override
  bool get allowsLocalConnections => hotspotAddr != null;

  @override
  String? get disallowsInternetConnectivityReason =>
      S.current.messageSyncingIsDisabledOnMobileInternet;

  @override
  String? get disallowsLocalConnectivityReason => null;

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
  bool get allowsInternetConnections => false;

  @override
  bool get allowsLocalConnections => false;

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
