import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../bloc/blocs.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget with OuiSyncAppLogger {
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
            buildWhen: (previousState, state) {
              if (state is WriteToFileInProgress ||
              state is WriteToFileDone ||
              state is WriteToFileCanceled ||
              state is WriteToFileFailure){
                if ((state as dynamic).path == this.fileData.path) {
                  return true;
                }
              }

              return false;
            },
            builder: (context, state) {
              if (state is WriteToFileInProgress) {
                if (state.path == this.fileData.path) {
                  final progress = state.progress / state.length;
                  return Row(
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(child: LinearProgressIndicator(value: progress)),
                      TextButton(
                        onPressed: () async {
                          if (state.path == this.fileData.path) {
                            showSnackBar(context, content: Text(S.current.messageCancelingFileWriting(state.fileName)));
                            BlocProvider.of<DirectoryBloc>(context).add(CancelSaveFile(filePath: this.fileData.path));
                          }
                        },
                        child: Text(
                          S.current.actionCancelCapital,
                          style: TextStyle(
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
                if ((state as dynamic).path == this.fileData.path) {
                  return true;
                }
              }
              return false;
            },
            listener: (context, state) {
              if (state is WriteToFileInProgress) {
                if (state.path == this.fileData.path) {
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
