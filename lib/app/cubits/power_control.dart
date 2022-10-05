import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../generated/l10n.dart';
import 'watch.dart';
import 'repos.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/settings.dart';

const _unspecifiedV4 = "0.0.0.0:0";
const _unspecifiedV6 = "[::]:0";

class PowerControl extends WatchSelf<PowerControl> with OuiSyncAppLogger {
  final ReposCubit _repos;
  final Settings _settings;
  final Connectivity _connectivity = Connectivity();

  bool? _isNetworkEnabled;
  String? _networkDisabledReason;
  ConnectivityResult? _lastConnectionType;
  static final bool _syncOnMobileDefault = true;
  bool _syncOnMobile = _syncOnMobileDefault;

  PowerControl(this._repos, this._settings) {
    unawaited(_listen());
  }

  Future<void> init() async {
    _syncOnMobile = _settings.getEnableSyncOnMobile(_syncOnMobileDefault);
    final current = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(current);
  }

  bool isSyncEnabledOnMobile() {
    return _syncOnMobile;
  }

  Future<void> enableSyncOnMobile() async {
    _syncOnMobile = true;
    await _settings.setEnableSyncOnMobile(true);
    final lastConnectionType = _lastConnectionType;
    if (lastConnectionType != null) {
      await _updateConnectionStatus(lastConnectionType);
    }
  }

  Future<void> disableSyncOnMobile() async {
    _syncOnMobile = false;
    await _settings.setEnableSyncOnMobile(false);
    final lastConnectionType = _lastConnectionType;
    if (lastConnectionType != null) {
      await _updateConnectionStatus(lastConnectionType);
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

  Future<void> _listen() async {
    final stream = _connectivity.onConnectivityChanged;

    await for (var result in stream) {
      await _updateConnectionStatus(result);
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    loggy.app('Connectivity event: ${result.name}');

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
        await _repos.bindNetwork(
          quicV4: _unspecifiedV4,
          quicV6: _unspecifiedV6,
        );
      } else {
        await _repos.bindNetwork();
      }

      changed();
    }

    _lastConnectionType = result;
  }
}
