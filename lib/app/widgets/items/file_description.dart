import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget {
  FileDescription({
    required this.repository,
    required this.fileData
  }) {
    _length.value = fileData.size;
  }

  final Repository repository;
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
          BlocConsumer<DirectoryBloc, DirectoryState>(
            buildWhen: (previousState, state) {// (context, state) {
              if (state is WriteToFileInProgress ||
              state is WriteToFileDone ||
              state is WriteToFileFailure){
                if ((state as dynamic).fileName == this.fileData.name) {
                  return true;
                }
              }

              return false;
            },
            builder: (context, state) {
              if (state is WriteToFileInProgress) {
                if (state.fileName == this.fileData.name) {
                  final progress = state.progress / state.length;
                  return LinearProgressIndicator(value: progress);
                }
              }

              return Container();
            },
            listenWhen: (previousState, state) {
              if (state is WriteToFileInProgress) {
                if (state.fileName == this.fileData.name) {
                  return true;
                }
              }
              return false;
            },
            listener: (context, state) {
              if (state is WriteToFileInProgress) {
                if (state.fileName == this.fileData.name) {
                  _length.value = state.progress;
                }
              }
            }
          ),
        ],
      ),
    );
  }
}
