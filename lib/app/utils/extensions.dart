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
