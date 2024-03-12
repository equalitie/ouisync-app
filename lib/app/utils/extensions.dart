import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import 'utils.dart';

extension AnyExtension<T> on T {
  /// This is inspired by
  /// [the let function in kotlin](https://kotlinlang.org/docs/scope-functions.html#let).
  /// It allows us to call a non-member function using a postfix notation which is mostly useful
  /// for null-aware function call chaining. For example, say we want a result of calling a
  /// non-member function on an expression which might evaluate to null. Normally we would have to
  /// do something like this:
  ///
  ///     var input = expression;
  ///     return input != null ? fun(input) : null;
  ///
  /// This extension allows us to take advantage of the null-aware member access operator instead:
  ///
  ///     return expression?.let(fun);
  ///
  R let<R>(R Function(T) f) => f(this);
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension ToBoolean on String {
  bool toBoolean() {
    return (toLowerCase() == "true" || toLowerCase() == "1")
        ? true
        : (toLowerCase() == "false" || toLowerCase() == "0"
            ? false
            : throw UnsupportedError('The string is not a bool value'));
  }
}

extension UriExtension on Uri {
  bool isValidOuiSyncUri() {
    final isHttps = isScheme('HTTPS');
    final isOuiSync = host == 'ouisync.net';
    final hasCorrectPath = path == '/r';
    final hasToken = hasFragment;

    return isHttps && hasCorrectPath && isOuiSync && hasToken;
  }
}

extension ListExtension<T> on List<T> {
  List<T> withAdded(T value) {
    final out = List.of(this);
    out.add(value);
    return out;
  }
}

extension MapExtension<K, V> on Map<K, V> {
  Map<K, V> withAdded(K key, V value) {
    final out = Map.of(this);
    out[key] = value;
    return out;
  }

  Map<K, V> withRemoved(K key) {
    final out = Map.of(this);
    out.remove(key);
    return out;
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    var renderObject = currentContext?.findRenderObject();
    var matrix = renderObject?.getTransformTo(null);

    if (matrix != null && renderObject?.paintBounds != null) {
      var rect = MatrixUtils.transformRect(matrix, renderObject!.paintBounds);
      return rect;
    } else {
      return null;
    }
  }
}

extension AppThemeExtension on ThemeData {
  AppTextThemeExtension get appTextStyle =>
      extension<AppTextThemeExtension>() ??
      AppTextThemeExtension(
          titleLarge: AppTypography.titleBig,
          titleMedium: AppTypography.titleMedium,
          titleSmall: AppTypography.titleSmall,
          bodyLarge: AppTypography.bodyBig,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          bodyMicro: AppTypography.bodyMicro,
          labelLarge: AppTypography.labelBig,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall);
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension TextEditingControllerExtension on TextEditingController {
  void selectAll({int? baseOffset, int? extentOffset}) {
    if (text.isEmpty) return;

    baseOffset ??= 0;
    extentOffset ??= 0;

    selection = TextSelection(
        baseOffset: baseOffset, extentOffset: text.length - extentOffset);
  }
}

extension RepositoryExtension on Repository {
  /// Check if the repository is mirrored on at least one of the cache servers in
  /// `Constants.cacheServers`
  Future<bool> isCacheServersEnabled() => _isCacheServersEnabled(mirrorExists);

  /// Create/delete repository mirror on all the cache servers in `Constants.cacheServers`.
  Future<void> setCacheServersEnabled(bool enabled) async {
    Future<void> update(String host, bool enabled) async {
      try {
        if (enabled) {
          await createMirror(host);
        } else {
          await deleteMirror(host);
        }
      } catch (_) {}
    }

    await Future.wait(
      Constants.cacheServers.map((host) => update(host, enabled)),
    );
  }
}

extension ShareTokenExtension on ShareToken {
  /// Check if the repository of this token is mirrored on at least one of the cache servers in
  /// `Constants.cacheServers`
  Future<bool> isCacheServersEnabled() => _isCacheServersEnabled(mirrorExists);
}

Future<bool> _isCacheServersEnabled(
    Future<bool> Function(String) mirrorExists) async {
  Future<bool> check(String host) async {
    try {
      return await mirrorExists(host);
    } catch (_) {
      return false;
    }
  }

  return await Future.wait(Constants.cacheServers.map(check))
      .then((results) => results.contains(true));
}
