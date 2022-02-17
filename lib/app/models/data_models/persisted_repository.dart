import 'dart:convert';

import 'package:ouisync_plugin/ouisync_plugin.dart';

class PersistedRepository {
  Repository repository;
  String name;
  PersistedRepository({
    required this.repository,
    required this.name,
  });

  void update(String newName, Repository newRepository, void Function(String) callback) {
    if (this.repository != newRepository) {
      this.repository.close();
      this.repository = newRepository;
    }

    this.name = newName;
  }

  PersistedRepository copyWith({
    Repository? repository,
    String? name,
    Subscription? subscription,
  }) {
    return PersistedRepository(
      repository: repository ?? this.repository,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'repository': repository,
      'name': name,
    };
  }

  factory PersistedRepository.fromMap(Map<String, dynamic> map) {
    return PersistedRepository(
      repository: map['repository'],
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PersistedRepository.fromJson(String source) => PersistedRepository.fromMap(json.decode(source));

  @override
  String toString() => 'PersistedRepository(repository: $repository, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PersistedRepository &&
      other.repository == repository &&
      other.name == name;
  }

  @override
  int get hashCode => repository.hashCode ^ name.hashCode;
}
