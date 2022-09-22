import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../generated/l10n.dart';
import 'watch.dart';
import 'repos.dart';

class PowerControl extends WatchSelf<PowerControl> {
  final ReposCubit _repos;
  final Connectivity _connectivity = Connectivity();

  bool? _isNetworkEnabled;
  String? _networkDisabledReason;
  ConnectivityResult? _lastConnectionType;
  bool _syncOnMobile = false;

  PowerControl(this._repos) {
    // TODO: Should we unsusbscribe somewhere?
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> init() async {
    final current = await _connectivity.checkConnectivity();
    _updateConnectionStatus(current);
  }

  bool isSyncEnabledOnMobile() {
    return _syncOnMobile;
  }

  void enableSyncOnMobile() {
    _syncOnMobile = true;
    final lastConnectionType = _lastConnectionType;
    if (lastConnectionType != null) {
      _updateConnectionStatus(lastConnectionType);
    }
  }

  void disableSyncOnMobile() {
    _syncOnMobile = false;
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
      newState = false;
      reason = S.current.messageNetworkIsUnavailable;
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
