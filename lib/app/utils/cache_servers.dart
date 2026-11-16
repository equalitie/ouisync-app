import 'dart:async';
import 'dart:io';

import 'package:mutex/mutex.dart';
import 'package:ouisync/ouisync.dart';

import 'log.dart';
import 'peer_addr.dart';
import 'session_handle.dart' show SessionProxy;

final _defaultListeners = {(PeerProto.quic, 20209), (PeerProto.tcp, 20209)};

/// Utility to set and query the cache servers state.
class CacheServers with AppLogger {
  /// Use the given cache server hosts.
  CacheServers(this._session) {
    // The peers live in the session, so after a restart they have to be added again.
    _session.started.addListener(_onSessionStarted);
    _onSessionStarted();
  }

  final SessionProxy _session;
  final Set<String> _configuredHosts = {};
  final Set<String> _hosts = {};
  final _mutex = Mutex();

  // Incremented on every restart, so that an `_add` started before the restart does not record
  // its host as added to the new session.
  int _generation = 0;

  void _onSessionStarted() {
    if (_session.started.value == 0) {
      return;
    }
    _generation = _session.started.value;
    _hosts.clear();
    _addHosts(_configuredHosts);
  }

  /// Add the specified host as cache server.
  Future<void> _add(String host) async {
    if (_hosts.contains(host)) {
      return;
    }

    final generation = _generation;

    Set<(PeerProto, int)> listeners;

    // Use the remote control API to obrain the listener protocols and ports
    try {
      listeners = await _session
          .getRemoteListenerAddrs(host)
          .then(
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
    final addrs = await _dnsLookupWithRetry(host);
    loggy.debug('resolved $host: $addrs');

    // The session was replaced while we were resolving, the restart re-adds the host.
    if (generation != _generation) {
      return;
    }

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

    if (generation != _generation) {
      return;
    }

    _hosts.add(host);
  }

  // DNS lookup can fail either when the DNS servers return an error but also
  // when the device is not connected to the internet. In both cases we want to
  // keep retrying.
  // TODO: Ideally we'd want to re-do the lookup periodically to account for
  // the case the IP address of the cache server changes over time.
  Future<List<InternetAddress>> _dnsLookupWithRetry(String host) async {
    final retryDuration = const Duration(seconds: 5);
    host = _stripPort(host);
    bool errorShown = false;
    while (true) {
      final stopwatch = Stopwatch();
      stopwatch.start();
      try {
        final addrs = await InternetAddress.lookup(host);
        stopwatch.stop();
        return addrs;
      } catch (e) {
        if (!errorShown) {
          loggy.warning('failed to resolve host "$host", will retry: $e');
          errorShown = true;
        }
        stopwatch.stop();
        final Duration elapsed = stopwatch.elapsed;
        if (elapsed < retryDuration) {
          await Future.delayed(retryDuration - elapsed);
        }
      }
    }
  }

  /// Add all the specified hosts as cache servers.
  void addAll(Iterable<String> hosts) {
    _configuredHosts.addAll(hosts);
    _addHosts(hosts);
  }

  void _addHosts(Iterable<String> hosts) =>
      unawaited(Future.wait(hosts.map((host) => _add(host))));

  void close() => _session.started.removeListener(_onSessionStarted);

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

  Future<bool> _isEnabled(Future<bool> Function(String) mirrorExists) async {
    Future<bool> check(String host) async {
      try {
        return await mirrorExists(host);
      } catch (_) {
        return false;
      }
    }

    return await Future.wait(
      _hosts.map(check),
    ).then((results) => results.contains(true));
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
