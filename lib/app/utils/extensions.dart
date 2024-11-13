import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show SortBy;
import '../models/auth_mode.dart';
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
  static const _authModeKey = 'authMode';

  Future<AuthMode> getAuthMode() =>
      getMetadata(_authModeKey).then((data) => data != null
          ? AuthMode.fromJson(json.decode(data))
          : AuthModeBlindOrManual());

  Future<void> setAuthMode(AuthMode authMode) async {
    final newValue = json.encode(authMode.toJson());

    while (true) {
      // Currently we ignore any concurrent changes and always force the new value.
      final oldValue = await getMetadata(_authModeKey);

      try {
        await setMetadata({
          _authModeKey: (oldValue: oldValue, newValue: newValue),
        });

        break;
      } on Error catch (e) {
        if (e.code == ErrorCode.entryChanged) {
          continue;
        } else {
          rethrow;
        }
      }
    }
  }
}

extension ProgressExtension on Progress {
  double get fraction => total > 0 ? value.toDouble() / total.toDouble() : 1.0;

  bool get isComplete => value == total;
}

extension SortByLocalizedExtension on SortBy {
  String get localized {
    switch (this) {
      case SortBy.name:
        return S.current.sortByNameLabel;
      case SortBy.size:
        return S.current.sortBySizeLabel;
      case SortBy.type:
        return S.current.sortByTypeLabel;
    }
  }
}

extension AccessModeLocalizedExtension on AccessMode {
  String get localized {
    switch (this) {
      case AccessMode.blind:
        return S.current.accessModeBlindLabel;
      case AccessMode.read:
        return S.current.accessModeReadLabel;
      case AccessMode.write:
        return S.current.accessModeWriteLabel;
    }
  }
}
