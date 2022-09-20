import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'watch.dart';

class PowerControl extends WatchSelf<PowerControl> {
  final Connectivity _connectivity = Connectivity();

  bool _isNetworkEnabled = false;
  String? _networkDisabledReason;

  PowerControl() {
    // TODO: Should we unsusbscribe somewhere?
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool isNetworkEnabled() {
    return _isNetworkEnabled;
  }

  String? networkDisabledReason() {
    return _networkDisabledReason;
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    bool newState = true;
    String? reason;

    if (result == ConnectivityResult.mobile) {
      newState = false;
      reason = "Network is disabled when using mobile internet";
    } else if (result == ConnectivityResult.none) {
      newState = false;
      reason = "No network available";
    }

    if (_isNetworkEnabled != newState || _networkDisabledReason != reason) {
      _isNetworkEnabled = newState;
      _networkDisabledReason = reason;
      changed();
    }
  }
}
