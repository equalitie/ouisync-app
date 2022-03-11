import 'package:ouisync_plugin/ouisync_plugin.dart';

class NamedRepo {
  String name;
  Repository repo;

  NamedRepo(this.name, this.repo);

  // NOTE: This operator is required for the DropdownMenuButton to show
  // entries properly.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NamedRepo &&
      other.repo == repo &&
      other.name == name;
  }
}
