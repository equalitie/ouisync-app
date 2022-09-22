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

  PowerControl(this._repos) {
    // TODO: Should we unsusbscribe somewhere?
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> init() async {
    final current = await _connectivity.checkConnectivity();
    _updateConnectionStatus(current);
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
      newState = false;
      reason = S.current.messageSyncingIsDisabledOnMobileInternet;
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
  }
}
