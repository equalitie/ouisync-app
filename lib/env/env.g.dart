// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

class _Env {
  static const List<int> _enviedkeyouisyncDSN = [852533298, 2989934810];
  static const List<int> _envieddataouisyncDSN = [852533264, 2989934840];
  static final String ouisyncDSN = String.fromCharCodes(
    List.generate(_envieddataouisyncDSN.length, (i) => i, growable: false)
        .map((i) => _envieddataouisyncDSN[i] ^ _enviedkeyouisyncDSN[i])
        .toList(growable: false),
  );
}
