import 'dart:convert';
import 'dart:async';
import 'package:udp/udp.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dns_client/dns_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NatDetection extends Cubit<NatDetectionType> {
  int _nextTask = 0;
  int? _highestRunningTask;
  final DnsClient _dns;
  StreamSubscription<ConnectivityResult>? _subscription;

  static Future<NatDetection> init() async {
    final connectivity = Connectivity();
    final initialConnection = await connectivity.checkConnectivity();
    return NatDetection._(connectivity, initialConnection);
  }

  NatDetection._(
    Connectivity connectivity,
    ConnectivityResult initialConnection,
  )   : _dns = DnsOverHttps.google(),
        super(_NatDetectionTypeWorking()) {
    _subscription = connectivity.onConnectivityChanged
        .listen((result) => _startTask(result));

    _startTask(initialConnection);
  }

  @override
  Future<void> close() async {
    final sub = _subscription;
    _subscription = null;

    if (sub != null) {
      await sub.cancel();
    }

    await super.close();
  }

  void _startTask(ConnectivityResult result) async {
    final currentTask = _nextTask;
    _highestRunningTask = currentTask;
    _nextTask += 1;

    if (result == ConnectivityResult.none ||
        result == ConnectivityResult.bluetooth) {
      return _emit(currentTask, _NatDetectionTypeOffline());
    }

    while (true) {
      if (currentTask != _highestRunningTask) {
        return;
      }

      emit(_NatDetectionTypeWorking());

      UDP? socket;

      try {
        socket = await UDP.bind(Endpoint.any());

        // Run the two concurrently.
        final ip0 = await _endpointEcho(currentTask, 0, socket);
        final ip1 = await _endpointEcho(currentTask, 1, socket);

        if (ip0 == ip1) {
          _emit(currentTask, _NatDetectionTypeNotSymmetric());
        } else {
          _emit(currentTask, _NatDetectionTypeSymmetric());
        }

        return;
      } catch (e) {
        print("Failed to get endpoint echo: $e");
        _emit(currentTask, _NatDetectionTypeError("$e"));
      } finally {
        socket?.close();
      }

      // Retry
      await Future.delayed(Duration(seconds: 60));
    }
  }

  void _emit(int currentTask, NatDetectionType natType) {
    if (_highestRunningTask! > currentTask) {
      // A new task started and this is an old result.
      return;
    }
    emit(natType);
  }

  // https://gitlab.internal.equalit.ie/kpetku/udpechoserver/
  Future<String> _endpointEcho(
    int currentTask,
    int serverId,
    UDP socket,
  ) async {
    final port = 7777;
    final ips = await _dns.lookup("natdetect$serverId.ouisync.net");
    for (final ip in ips) {
      // Indicate that this is the first version of this protocol. The remote
      // doesn't currently read it, but in future if we need to change the
      // protocol we can stay backward compatible.
      await socket.send(
          Utf8Codec().encode("p0\n"), Endpoint.unicast(ip, port: Port(port)));

      await for (final datagram
          in socket.asStream(timeout: Duration(seconds: 5))) {
        if (datagram == null) {
          break;
        }

        if (datagram.address == ip && datagram.port == port) {
          final str = Utf8Codec().decode(datagram.data);
          return str.substring(0, str.indexOf('\n'));
        }
      }

      throw "timed out";
    }

    if (ips.isEmpty) {
      throw "dns lookup failed";
    } else {
      throw "failed";
    }
  }
}

abstract class NatDetectionType {
  String message();
}

class _NatDetectionTypeOffline extends NatDetectionType {
  @override
  String message() => "Offline";
}

class _NatDetectionTypeWorking extends NatDetectionType {
  @override
  String message() => "...";
}

class _NatDetectionTypeError extends NatDetectionType {
  String msg;
  _NatDetectionTypeError(this.msg);
  @override
  String message() => "Error: $msg";
}

class _NatDetectionTypeNotSymmetric extends NatDetectionType {
  @override
  String message() => "Non Symmetric";
}

class _NatDetectionTypeSymmetric extends NatDetectionType {
  @override
  String message() => "Symmetric";
}
