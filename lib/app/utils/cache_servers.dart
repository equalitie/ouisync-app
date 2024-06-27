import 'package:ouisync_plugin/ouisync_plugin.dart';

/// Utility to set and query the cache servers state.
class CacheServers {
  /// Use the given cache server hosts.
  CacheServers(this._hosts);

  /// Use no cache servers.
  static CacheServers disabled = CacheServers([]);

  final List<String> _hosts;
  final _throttle = Throttle();

  Future<void> setEnabled(Repository repo, bool enabled) async {
    Future<void> update(String host, bool enabled) async {
      try {
        if (enabled) {
          await repo.createMirror(host);
        } else {
          await repo.deleteMirror(host);
        }
      } catch (_) {}
    }

    await _throttle.invoke(
      () => Future.wait(
        _hosts.map((host) => update(host, enabled)),
      ),
    );
  }

  Future<bool> isEnabledForRepo(Repository repo) =>
      _isEnabled(repo.mirrorExists);

  Future<bool> isEnabledForShareToken(ShareToken token) =>
      _isEnabled(token.mirrorExists);

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

// Ensures an async operation is being executed at most once at a time. If the operation is invoked
// while already executing, it's delayed until the current execution completes. If it's invoked
// more than once, only the last invocation is executed.
//
// TODO: come up with more accurate name.
class Throttle {
  Future<void> Function()? curr;
  Future<void> Function()? next;

  Future<void> invoke(Future<void> Function() f) async {
    if (curr != null) {
      next = f;
      return;
    } else {
      curr = f;
    }

    while (curr != null) {
      try {
        await curr!();
        curr = next;
      } catch (e) {
        curr = null;
        rethrow;
      } finally {
        next = null;
      }
    }
  }
}
