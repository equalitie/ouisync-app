import 'package:flutter/material.dart';

import 'utils.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
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
        baseOffset: baseOffset, extentOffset: text.length + extentOffset);
  }
}
