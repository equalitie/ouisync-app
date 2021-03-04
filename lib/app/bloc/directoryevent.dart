import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class DirectoryEvent extends Equatable {
  const DirectoryEvent();
}

class ContentRequest extends DirectoryEvent {
  const ContentRequest({
    @required this.repoPath,
    @required this.folderPath
  }) : assert(repoPath != null && folderPath != null) , assert(repoPath != "" && folderPath != "");

  final String repoPath;
  final String folderPath;
  @override
  List<Object> get props => [
    repoPath,
    folderPath
  ];

}