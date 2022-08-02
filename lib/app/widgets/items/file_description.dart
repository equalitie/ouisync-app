import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget with OuiSyncAppLogger {
  FileDescription(
    this.repository,
    this.fileData,
    this._uploadJob,
  );

  final RepoCubit repository;
  final BaseItem fileData;
  final Watch<Job>? _uploadJob;

  @override
  Widget build(BuildContext context) {
    final uploadJob = _uploadJob;

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
          (uploadJob == null)
            ? _fileSize(fileData.size)
            : uploadJob.builder((job) => _fileSize(job.soFar)),
          Dimensions.spacingVerticalHalf,
          (uploadJob != null) ? _uploadProgressWidget(uploadJob) : Container(),
        ],
      ),
    );
  }

  Widget _fileSize(int size) {
    return Fields.constrainedText(
      formatSize(size as int, units: true),
      flex: 0,
      fontSize: Dimensions.fontSmall,
      fontWeight: FontWeight.w400,
      softWrap: true
    );
  }

  Widget _uploadProgressWidget(Watch<Job> cubit) => cubit.builder((job) {
    final progress = job.soFar / job.total;

    return Row(
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: LinearProgressIndicator(value: progress)),
        TextButton(
          onPressed: () {
            cubit.state.cancel = true;
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
  });
}
