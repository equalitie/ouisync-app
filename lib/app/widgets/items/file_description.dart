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

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.autosizeText(fileData.name),
          Dimensions.spacingVerticalHalf,
          _buildDetails(context),
        ],
      );

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
            return _buildSizeWidget(null, true);
          }

          if (soFar == null) {
            return _buildSizeWidget(formatSize(total), true);
          }

          if (soFar < total) {
            return _buildSizeWidget(formatSizeProgress(total, soFar), true);
          }

          return _buildSizeWidget(formatSize(total), false);
        }),
      );

  Widget _buildUploadDetails(BuildContext context, Job job) =>
      BlocBuilder<Job, JobState>(
        bloc: job,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSizeWidget(formatSize(state.soFar), false),
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
                style: const TextStyle(fontSize: Dimensions.fontSmall),
              )),
        ],
      );
}

Widget _buildSizeWidget(String? text, bool loading) => Row(
      children: [
        if (text != null)
          Fields.constrainedText(
            text,
            flex: 0,
            fontSize: Dimensions.fontSmall,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            softWrap: true,
          ),
        if (loading)
          Icon(
            Icons.hourglass_top,
            size: Dimensions.fontSmall,
            color: Colors.black.withAlpha(128),
          ),
      ],
    );
