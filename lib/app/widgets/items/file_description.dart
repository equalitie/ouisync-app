import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import 'scrollable_text_widget.dart';

class FileDescription extends StatelessWidget with AppLogger {
  FileDescription(
    this.repoCubit,
    this.entry,
    this.uploadJob,
  );

  final RepoCubit repoCubit;
  final FileEntry entry;
  final Job? uploadJob;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScrollableTextWidget(child: Text(entry.name)),
          Dimensions.spacingVerticalHalf,
          _buildDetails(context),
        ],
      );

  Widget _buildDetails(BuildContext context) {
    final uploadJob = this.uploadJob;

    if (uploadJob != null) {
      return _buildUploadDetails(context, uploadJob);
    } else {
      return _buildSyncDetails(context);
    }
  }

  Widget _buildSyncDetails(BuildContext context) => BlocProvider(
        create: (context) => FileProgress(repoCubit, entry.path),
        child: BlocBuilder<FileProgress, int?>(builder: (cubit, soFar) {
          final total = entry.size;

          if (total == null) {
            return _buildSizeWidget(context, null, true);
          }

          if (soFar == null) {
            return _buildSizeWidget(context, formatSize(total), true);
          }

          if (soFar < total) {
            return _buildSizeWidget(
                context, formatSizeProgress(total, soFar), true);
          }

          return _buildSizeWidget(context, formatSize(total), false);
        }),
      );

  Widget _buildUploadDetails(BuildContext context, Job job) =>
      BlocBuilder<Job, JobState>(
        bloc: job,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSizeWidget(context, formatSize(state.soFar), false),
            Dimensions.spacingVerticalHalf,
            _buildUploadProgress(context, job),
          ],
        ),
      );

  Widget _buildUploadProgress(BuildContext context, Job job) => Row(
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
              child: LinearProgressIndicator(
                  value: job.state.soFar / job.state.total)),
          TextButton(
              onPressed: () {
                job.cancel();
              },
              child: Text(S.current.actionCancelCapital,
                  style: context.theme.appTextStyle.bodyMicro
                      .copyWith(color: context.theme.primaryColor))),
        ],
      );

  Widget _buildSizeWidget(BuildContext context, String? text, bool loading) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (text != null)
            Fields.constrainedText(
              text,
              flex: 0,
              style: context.theme.appTextStyle.bodyMicro,
              softWrap: true,
            ),
          if (loading)
            Icon(
              Icons.hourglass_top,
              color: Colors.black.withAlpha(128),
              size: context.theme.appTextStyle.bodyMicro.fontSize,
            )
        ],
      );
}
