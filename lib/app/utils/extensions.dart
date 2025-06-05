import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show EntrySelectionActions, SortBy;
import '../models/models.dart' show AuthMode, AuthModeBlindOrManual;
import 'utils.dart' show AppTextThemeExtension, AppTypography;

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

  String removePrefix(String rootPath) {
    return replaceFirst(rootPath, '').trim();
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

    // Currently we ignore any concurrent changes and always force the new value.
    bool changed = false;
    do {
      final oldValue = await getMetadata(_authModeKey);
      changed = await setMetadata([
        MetadataEdit(
          key: _authModeKey,
          oldValue: oldValue,
          newValue: newValue,
        ),
      ]);
    } while (!changed);
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

extension EntrySelectionActionsExtension on EntrySelectionActions {
  String get localized {
    switch (this) {
      case EntrySelectionActions.download:
        return S.current.actionDownload;
      case EntrySelectionActions.copy:
        return S.current.actionCopy;
      case EntrySelectionActions.move:
        return S.current.actionMove;
      case EntrySelectionActions.delete:
        return S.current.actionDelete;
    }
  }
}

extension FileReadStream on File {
  Stream<List<int>> readStream({int offset = 0, int chunkSize = 1024}) async* {
    while (true) {
      final chunk = await read(offset, chunkSize);
      offset += chunk.length;

      if (chunk.isEmpty) {
        break;
      }

      yield chunk;
    }
  }
}
