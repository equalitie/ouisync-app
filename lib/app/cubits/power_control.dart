import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../generated/l10n.dart';
import 'watch.dart';
import 'repos.dart';
import '../utils/settings.dart';

class PowerControl extends WatchSelf<PowerControl> {
  final ReposCubit _repos;
  final Settings _settings;
  final Connectivity _connectivity = Connectivity();

  bool? _isNetworkEnabled;
  String? _networkDisabledReason;
  ConnectivityResult? _lastConnectionType;
  bool _syncOnMobile = false;

  PowerControl(this._repos, this._settings) {
    // TODO: Should we unsusbscribe somewhere?
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> init() async {
    _syncOnMobile = _settings.getEnableSyncOnMobile();
    final current = await _connectivity.checkConnectivity();
    _updateConnectionStatus(current);
  }

  bool isSyncEnabledOnMobile() {
    return _syncOnMobile;
  }

  Future<void> enableSyncOnMobile() async {
    _syncOnMobile = true;
    await _settings.setEnableSyncOnMobile(true);
    final lastConnectionType = _lastConnectionType;
    if (lastConnectionType != null) {
      _updateConnectionStatus(lastConnectionType);
    }
  }

  Future<void> disableSyncOnMobile() async {
    _syncOnMobile = false;
    await _settings.setEnableSyncOnMobile(false);
    final lastConnectionType = _lastConnectionType;
    if (lastConnectionType != null) {
      _updateConnectionStatus(lastConnectionType);
    }
  }

  // Null means the answer is not yet known (the init function hasn't finished
  // or was not called yet).
  bool? isNetworkEnabled() {
    return _isNetworkEnabled;
  }

  String? networkDisabledReason() {
    return _networkDisabledReason;
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool newState = true;
    String? reason;

    if (result == ConnectivityResult.mobile) {
      if (_syncOnMobile == true) {
        newState = true;
        reason = null;
      } else {
        newState = false;
        reason = S.current.messageSyncingIsDisabledOnMobileInternet;
      }
    } else if (result == ConnectivityResult.none) {
      // For now we keep the network enabled. It is because when we're tethering and
      // mobile internet is not enabled we get here as well. Ideally we would have
      // also the information about whether tethering is enabled and only in such case
      // we'd keep the connection going.
      //newState = false;
      //reason = S.current.messageNetworkIsUnavailable;
    }

    if (_isNetworkEnabled != newState || _networkDisabledReason != reason) {
      _isNetworkEnabled = newState;
      _networkDisabledReason = reason;

      if (newState) {
        _repos.enableNetwork();
      } else {
        _repos.disableNetwork();
      }

      changed();
    }

    _lastConnectionType = result;
  }
}
