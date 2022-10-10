import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;
import '../../generated/l10n.dart';
import 'watch.dart';
import '../utils/loggers/ouisync_app_logger.dart';
import '../utils/settings.dart';

const _unspecifiedV4 = "0.0.0.0:0";
const _unspecifiedV6 = "[::]:0";

class PowerControl extends WatchSelf<PowerControl> with OuiSyncAppLogger {
  final oui.Session _session;
  final Settings _settings;
  final Connectivity _connectivity = Connectivity();

  bool? _isNetworkEnabled;
  String? _networkDisabledReason;
  ConnectivityResult? _lastConnectionType;
  static final bool _syncOnMobileDefault = true;
  bool _syncOnMobile = _syncOnMobileDefault;

  PowerControl(this._session, this._settings) {
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

    switch (result) {
      case ConnectivityResult.bluetooth:
        await _disableNetwork();
        break;
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        await _enableNetworkFull();
        break;
      case ConnectivityResult.mobile:
        if (_syncOnMobile) {
          await _enableNetworkFull();
        } else {
          await _enableNetworkHotspot();
        }
        break;
      case ConnectivityResult.none:
        // For now we keep the network enabled. It is because when we're tethering and
        // mobile internet is not enabled we get here as well. Ideally we would have
        // also the information about whether tethering is enabled and only in such case
        // we'd keep the connection going.
        await _enableNetworkFull();
        break;
    }

    _lastConnectionType = result;
    changed();
  }

  // Enable any network connection.
  Future<void> _enableNetworkFull() async {
    await _session.bindNetwork(
      quicV4: _unspecifiedV4,
      quicV6: _unspecifiedV6,
    );

    _isNetworkEnabled = true;
    _networkDisabledReason = null;
  }

  // Enable only connections to devices connected to the hotspot provided by this device.
  Future<void> _enableNetworkHotspot() async {
    final ip = await _findHotspotIp();
    final addr = ip != null ? "$ip:0" : null;

    await _session.bindNetwork(quicV4: addr);

    _isNetworkEnabled = false;
    _networkDisabledReason = S.current.messageSyncingIsDisabledOnMobileInternet;
  }

  // Disable all connections.
  Future<void> _disableNetwork() async {
    await _session.bindNetwork();

    _isNetworkEnabled = false;
    _networkDisabledReason = S.current.messageNetworkIsUnavailable;
  }
}

// If wifi hotspot is enabled, find the ip address of the hotspot interface, otherwise returns null.
Future<String?> _findHotspotIp() async {
  // HACK: Find the hotspot ip address by enumerating all network interfaces and returning the one
  // whose address is in the 192.168.x.x range. This is based on some experimentation and also on a
  // couple of stackoverflow answers. Hard to say how reliable this is. The reason we do it this
  // way is that there doesn't seems to be any stable API to retrieve this info. Also, the hotspot
  // interface doesn't seem to appear immediately after connectivity event, so we need to poll it
  // for a short time (typically it appears within 1 seconds or so).

  // TODO: there is a hidden android API which might be potentially more reliable. See this SO
  // question for more details:
  // https://stackoverflow.com/questions/69314959/android-developer-how-to-detect-when-wifi-hotspot-is-turned-on-off

  // It seems on android the hotspot ip is always hardcoded to an ip with this prefix.
  // TODO: We need more testing to verify this.
  const hotspotIpPrefix = "192.168";

  final stopwatch = Stopwatch()..start();
  final timeout =
      Duration(seconds: 5); // poll the interfaces for up to this time.
  final delay =
      Duration(milliseconds: 250); // wait this long between each poll.

  while (stopwatch.elapsed < timeout) {
    final interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);

    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.address.startsWith(hotspotIpPrefix)) {
          return addr.address;
        }
      }
    }

    await Future.delayed(delay);
  }

  return null;
}
