import 'dart:ui' show Locale;

String serializeLocale(Locale locale) {
  final l = locale.languageCode;
  final c = locale.countryCode;
  final s = locale.scriptCode;

  return switch ((c, s)) {
    (null, null) => l,
    (final String c, null) => "${l}_$c",
    (null, final String s) => "${l}__$s",
    (final String c, final String s) => "${l}_${c}_$s",
  };
}

Locale? deserializeLocale(String str) {
  if (str.isEmpty) {
    return null;
  }

  final (languageCode, rest) = _splitOnce(str, '_');

  if (languageCode.isEmpty) {
    return null;
  }

  if (rest.isEmpty) {
    return Locale(languageCode);
  }

  final (countryCode, scriptCode) = _splitOnce(rest, '_');

  if (countryCode.isEmpty && scriptCode.isEmpty) {
    return Locale(languageCode);
  } else if (scriptCode.isEmpty) {
    return Locale(languageCode, countryCode);
  } else if (countryCode.isEmpty) {
    return Locale.fromSubtags(
        languageCode: languageCode, scriptCode: scriptCode);
  } else {
    return Locale.fromSubtags(
        languageCode: languageCode,
        countryCode: countryCode,
        scriptCode: scriptCode);
  }
}

(String, String) _splitOnce(String str, String splitter) {
  final pos = str.indexOf(splitter);
  if (pos == -1) {
    return (str, "");
  }
  final first = str.substring(0, pos);
  final second = str.substring(pos + splitter.length);
  return (first, second);
}
