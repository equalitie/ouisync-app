import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../cubits/cubits.dart';
import '../../utils/utils.dart';

class FileIconAnimated extends StatelessWidget with AppLogger {
  FileIconAnimated(this._downloadJob);

  final Job? _downloadJob;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _getWidgetForState(context),
      onTap: () => onFileIconTap(context),
    );
  }

  void onFileIconTap(BuildContext context) {
    final job = _downloadJob;

    if (job != null) {
      job.cancel();
    }
  }

  Widget _getWidgetForState(BuildContext context) {
    final job = _downloadJob;

    if (job == null) {
      return const Icon(
        Icons.insert_drive_file_outlined,
        size: Dimensions.sizeIconAverage,
      );
    }

    return BlocBuilder<Job, JobState>(
      bloc: job,
      builder: (context, state) {
        final ratio = state.progress;
        final percentage = (ratio * 100.0).round();

        return CircularPercentIndicator(
          radius: Dimensions.sizeIconMicro,
          animation: true,
          animateFromLastPercent: true,
          percent: ratio,
          progressColor: Theme.of(context).colorScheme.secondary,
          center: Text(
            '$percentage%',
            style: context.theme.appTextStyle.bodyMicro,
          ),
        );
      },
    );

    // TODO: This code used to show a different icon once the download finished.
    //   Also after the download was done, clicking on the icon would show the
    //   location of the file on the file system. Consider bringing back this
    //   functionality.

    //if (_isCurrentFile(state)) {
    //  if (_downloadJob) {
    //  } else {
    //    IconData iconData;

    //    switch (state.result) {
    //      case DownloadFileResult.done:
    //        _destinationPath = state.devicePath;
    //        iconData = Icons.download_done_rounded;
    //        break;
    //      case DownloadFileResult.canceled:
    //        iconData = Icons.file_download_off;
    //        break;
    //      case DownloadFileResult.failed:
    //        iconData = Icons.cancel;
    //        break;
    //    }

    //    return Icon(iconData);
    //  }
    //}
  }
}
