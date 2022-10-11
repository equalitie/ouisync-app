import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import '../../generated/l10n.dart';
import 'watch.dart';
import '../utils/hotspot.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/settings.dart';

const _unspecifiedV4 = "0.0.0.0:0";
const _unspecifiedV6 = "[::]:0";
const bool _syncOnMobileDefault = true;

class PowerControl extends WatchSelf<PowerControl> with OuiSyncAppLogger {
  final oui.Session _session;
  final Settings _settings;
  final Connectivity _connectivity = Connectivity();

  _NetworkMode _networkMode = _NetworkMode.disabled;
  _Transition _networkModeTransition = _Transition.none;

  bool _syncOnMobile = _syncOnMobileDefault;

  PowerControl(this._session, this._settings) {
    unawaited(_listen());
  }

  Future<void> init() async {
    _syncOnMobile = _settings.getEnableSyncOnMobile(_syncOnMobileDefault);
    await _refresh();
  }

  bool get isSyncEnabledOnMobile => _syncOnMobile;

  Future<void> enableSyncOnMobile() async {
    if (_syncOnMobile) {
      return;
    }

    _syncOnMobile = true;
    changed();

    await _settings.setEnableSyncOnMobile(true);
    await _refresh();
  }

  Future<void> disableSyncOnMobile() async {
    if (!_syncOnMobile) {
      return;
    }

    _syncOnMobile = false;
    changed();

    await _settings.setEnableSyncOnMobile(false);
    await _refresh();
  }

  // Null means the answer is not yet known (the init function hasn't finished
  // or was not called yet).
  bool? get isNetworkEnabled {
    switch (_networkMode) {
      case _NetworkMode.full:
        return true;
      case _NetworkMode.saving:
      case _NetworkMode.disabled:
        return false;
    }
  }

  String? get networkDisabledReason {
    switch (_networkMode) {
      case _NetworkMode.full:
        return null;
      case _NetworkMode.saving:
        return S.current.messageSyncingIsDisabledOnMobileInternet;
      case _NetworkMode.disabled:
        return S.current.messageNetworkIsUnavailable;
    }
  }

  Future<void> _listen() async {
    final stream = _connectivity.onConnectivityChanged;

    await for (var result in stream) {
      await _onConnectivityChange(result);
    }
  }

  Future<void> _onConnectivityChange(ConnectivityResult result) async {
    loggy.app('Connectivity event: ${result.name}');

    switch (result) {
      case ConnectivityResult.bluetooth:
        await _setNetworkMode(_NetworkMode.disabled);
        break;
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        await _setNetworkMode(_NetworkMode.full);
        break;
      case ConnectivityResult.mobile:
        if (_syncOnMobile) {
          await _setNetworkMode(_NetworkMode.full);
        } else {
          await _setNetworkMode(_NetworkMode.saving);
        }
        break;
      case ConnectivityResult.none:
        // For now we keep the network enabled. It is because when we're tethering and
        // mobile internet is not enabled we get here as well. Ideally we would have
        // also the information about whether tethering is enabled and only in such case
        // we'd keep the connection going.
        await _setNetworkMode(_NetworkMode.full);
        break;
    }
  }

  Future<void> _refresh() async {
    _onConnectivityChange(await _connectivity.checkConnectivity());
  }

  Future<void> _setNetworkMode(_NetworkMode mode, {force = false}) async {
    if (mode != _networkMode || force) {
      loggy.app('Network mode: $mode');

      _networkMode = mode;
      changed();
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
      case _NetworkMode.full:
        quicV4 = _unspecifiedV4;
        quicV6 = _unspecifiedV6;
        break;
      case _NetworkMode.saving:
        final ip = await findHotspotIp();
        quicV4 = ip != null ? "$ip:0" : null;
        quicV6 = null;
        break;
      case _NetworkMode.disabled:
        quicV4 = null;
        quicV6 = null;
        break;
    }

    try {
      await _session.bindNetwork(quicV4: quicV4, quicV6: quicV6);
    } catch (e) {
      _networkMode = _NetworkMode.disabled;
      rethrow;
    } finally {
      transition = _networkModeTransition;
      _networkModeTransition = _Transition.none;
      changed();
    }

    if (transition == _Transition.queued) {
      await _setNetworkMode(_networkMode, force: true);
    }
  }
}

enum _NetworkMode {
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
