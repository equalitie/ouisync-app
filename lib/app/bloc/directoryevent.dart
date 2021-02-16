import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class ContentRequest extends DirectoryEvent {
  const ContentRequest({
    @required this.path
  }) : assert(path != null) , assert(path != "");

  final String path;
  @override
  List<Object> get props => [
    path
  ];

}