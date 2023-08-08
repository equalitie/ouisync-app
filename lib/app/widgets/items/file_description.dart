import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget with AppLogger {
  FileDescription(
    this.repo,
    this.fileData,
    this._uploadJob,
  );

  final RepoCubit repo;
  final FileItem fileData;
  final Job? _uploadJob;

  late Color primaryColor;

  TextStyle? bodyStyle;
  TextStyle? bodySmallStyle;

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;

    bodyStyle = Theme.of(context).textTheme.bodyMedium;
    bodySmallStyle = Theme.of(context).textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Fields.autosizeText(fileData.name, style: bodyStyle),
        Dimensions.spacingVerticalHalf,
        _buildDetails(context),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    final uploadJob = _uploadJob;

    if (uploadJob != null) {
      return _buildUploadDetails(context, uploadJob);
    } else {
      return _buildSyncDetails(context);
    }
  }

  Widget _buildSyncDetails(BuildContext context) => BlocProvider(
        create: (context) => FileProgress(repo, fileData.path),
        child: BlocBuilder<FileProgress, int?>(builder: (cubit, soFar) {
          final total = fileData.size;

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
            _buildUploadProgress(job),
          ],
        ),
      );

  Widget _buildUploadProgress(Job job) => Row(
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
              child: LinearProgressIndicator(
                  value: job.state.soFar / job.state.total)),
          TextButton(
              onPressed: () {
                job.cancel();
              },
              child: Text(
                S.current.actionCancelCapital,
                style: bodySmallStyle?.copyWith(color: primaryColor),
              )),
        ],
      );

  Widget _buildSizeWidget(BuildContext context, String? text, bool loading) =>
      Row(
        children: [
          if (text != null)
            Fields.constrainedText(
              text,
              flex: 0,
              style: bodySmallStyle?.copyWith(fontWeight: FontWeight.w400),
              softWrap: true,
            ),
          if (loading)
            Icon(
              Icons.hourglass_top,
              color: Colors.black.withAlpha(128),
            ),
        ],
      );
}
