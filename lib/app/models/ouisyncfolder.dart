import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/models/baseitem.dart';

class OuiSyncFolder implements BaseItem {

  List<BaseItem> items;

  OuiSyncFolder(
      id,
      name,
      location,
      size,
      status,
      {
        description = "-",
        icon = const Icon(Icons.folder)
      }) {

    this.id = id;
    this.name = name;
    this.description = description;
    this.location = location;
    this.size = size;
    this.status = status;
    this.type = OSType.folder;
    this.icon = icon;

    items = <BaseItem>[];
  }

  void addItem(BaseItem item)
  {
    items.add(item);
  }

  @override
  String id;

  @override
  String name;

  @override
  String description;

  @override
  List<String> location;

  @override
  double size;

  @override
  String status;

  @override
  OSType type;

  @override
  Icon icon;

  @override
  void rename(String newName) {
    this.name = newName;
  }

  @override
  void updateDescription(String newDescription) {
    this.description = newDescription;
  }

  @override
  void move(List<String> newLocation) {
    this.location = newLocation;
  }

  @override
  void setStatus(String status) {
    this.status = status;
  }

  @override
  void setIcon(Icon icon) {
    this.icon = icon;
  }
}