import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubit/cubits.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget with OuiSyncAppLogger {
  FileDescription({Key? key, 
    required this.repository,
    required this.fileData,
  }) : super(key: key) {
    _length.value = fileData.size;
  }

  final RepoState repository;
  final BaseItem fileData;

  final ValueNotifier<int> _length = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Fields.constrainedText(
            fileData.name,
            flex: 0,
            softWrap: true
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          ValueListenableBuilder(
            valueListenable: _length,
            builder: (context, size, widget) {
              return Fields.constrainedText(
                formattSize(size as int, units: true),
                flex: 0,
                fontSize: Dimensions.fontSmall,
                fontWeight: FontWeight.w400,
                softWrap: true
              );
            }
          ),
          Dimensions.spacingVerticalHalf,
          BlocConsumer<DirectoryCubit, DirectoryState>(
            buildWhen: (previousState, state) {
              if (state is WriteToFileInProgress ||
                  state is WriteToFileDone) {
                if (_isCurrentFile(state)) {
                  return true;
                }
              }

              return false;
            },
            builder: (context, state) {
              if (state is WriteToFileInProgress) {
                if (_isCurrentFile(state)) {
                  final progress = state.progress / state.length;
                  return Row(
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(child: LinearProgressIndicator(value: progress)),
                      TextButton(
                        onPressed: () {
                          BlocProvider.of<DirectoryCubit>(context)
                          .cancelSaveFile(repository, fileData.path);
                        },
                        child: Text(
                          S.current.actionCancelCapital,
                          style:const  TextStyle(
                            fontSize: Dimensions.fontSmall
                          ),
                        )
                      ),
                    ],
                  );
                }
              }

              return Container();
            },
            listenWhen: (previousState, state) {
              if (state is WriteToFileInProgress) {
                if (_isCurrentFile(state)) {
                  return true;
                }
              }
              return false;
            },
            listener: (context, state) {
              if (state is WriteToFileInProgress) {
                if (_isCurrentFile(state)) {
                  _length.value = state.progress;
                }
              }
            }
          ),
        ],
      ),
    );
  }

  bool _isCurrentFile (DirectoryState state) {
    final originRepository = _getRepositoryFromState(state);
    if (originRepository != repository.handle) {
      return false;
    }

    final originPath = _getPathFromState(state);
    return originPath == fileData.path;
  }

  Repository? _getRepositoryFromState(DirectoryState state) {
    if (state is WriteToFileInProgress ||
    state is WriteToFileDone) {
      return (state as dynamic).repository.handle;
    }
    return null;
  }

  String _getPathFromState(DirectoryState state) {
    if (state is WriteToFileInProgress ||
    state is WriteToFileDone) {
      return (state as dynamic).path;
    }

    return '';
  }
}
