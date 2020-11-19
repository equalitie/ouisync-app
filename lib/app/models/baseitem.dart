import 'package:flutter/widgets.dart';

enum OSType {
  folder,
  file,
  safe
}

abstract class BaseItem {
  String id;
  String name;
  String description;
  List<String> location;
  double size;
  String status;
  OSType type;
  Icon icon;

  void rename(String newName);
  void updateDescription(String newDescription);
  void move(List<String> newLocation);
  void setIcon(Icon icon);
  void setStatus(String status);
}