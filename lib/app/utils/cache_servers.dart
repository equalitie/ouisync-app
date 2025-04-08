import 'dart:async';
import 'dart:io';

import 'package:mutex/mutex.dart';
import 'package:ouisync/ouisync.dart';

import 'log.dart';
import 'peer_addr.dart';

final _defaultListeners = {(PeerProto.quic, 20209), (PeerProto.tcp, 20209)};

/// Utility to set and query the cache servers state.
class CacheServers with AppLogger {
  /// Use the given cache server hosts.
  CacheServers(this._session);

  final Session _session;
  final Set<String> _hosts = {};
  final _mutex = Mutex();

  /// Add the specified host as cache server.
  Future<void> add(String host) async {
    if (_hosts.contains(host)) {
      return;
    }

    Set<(PeerProto, int)> listeners;

    // Use the remote control API to obrain the listener protocols and ports
    try {
      listeners = await _session.getRemoteListenerAddrs(host).then(
            (addrs) => addrs
                .map(PeerAddr.parse)
                .nonNulls
                .map((addr) => (addr.proto, addr.port))
                .toSet(),
          );
      loggy.debug('got listeners for $host: $listeners');
    } catch (e) {
      // Fallback to defaults on failure (e.g., the host does not support the remote control API)
      loggy.debug('failed to get listeners for $host: ', e);
      listeners = _defaultListeners;
    }

    // Resolve the ip addresses of the host
    final addrs = await InternetAddress.lookup(_stripPort(host));
    loggy.debug('resolved $host: $addrs');

    final peers = addrs
        .expand(
          (addr) => listeners.map(
            (listener) => PeerAddr(listener.$1, addr, listener.$2),
          ),
        )
        .map((addr) => addr.toString())
        .toList();

    // Add the host as peer, obtaininig the peer address(es) by composing them from the
    // listener protocols, ports and the resolved ip addresses.
    await _session.addUserProvidedPeers(peers);
    loggy.debug('added $host as peer: $peers');

    _hosts.add(host);
  }

  /// Add all the specified hosts as cache servers.
  Future<void> addAll(Iterable<String> hosts) =>
      Future.wait(hosts.map((host) => add(host)));

  /// Enable or disable cache servers for the specified repo. Note that currently this
  /// enables/disables all defined cache servers together.
  Future<void> setEnabled(Repository repo, bool enabled) async {
    Future<void> update(String host) async {
      try {
        if (enabled) {
          await repo.createMirror(host);
        } else {
          await repo.deleteMirror(host);
        }
      } catch (_) {}
    }

    await _mutex.protect(() => Future.wait(_hosts.map(update)));
  }

  /// Check whether the given repo is mirrored on at least one of the defined cache servers.
  Future<bool> isEnabledForRepo(Repository repo) =>
      _isEnabled(repo.mirrorExists);

  /// Check whether the repo with the given token is mirrored on at least one of the defined cache
  /// servers.
  Future<bool> isEnabledForShareToken(ShareToken token) =>
      _isEnabled((host) => _session.mirrorExists(token, host));

  Future<bool> _isEnabled(
    Future<bool> Function(String) mirrorExists,
  ) async {
    Future<bool> check(String host) async {
      try {
        return await mirrorExists(host);
      } catch (_) {
        return false;
      }
    }

    return await Future.wait(_hosts.map(check))
        .then((results) => results.contains(true));
  }
}

String _stripPort(String host) {
  final i = host.lastIndexOf(':');
  if (i >= 0) {
    return host.substring(0, i);
  } else {
    return host;
  }
}
