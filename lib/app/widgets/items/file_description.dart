import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDescription extends StatefulWidget with AppLogger {
  FileDescription(
    this.repoCubit,
    this.entry,
    this.uploadJob,
  );

  final RepoCubit repoCubit;
  final FileEntry entry;
  final Job? uploadJob;

  @override
  State<FileDescription> createState() => _FileDescriptionState();
}

class _FileDescriptionState extends State<FileDescription> {
  final _scrollController = ScrollController();

  bool showStartEllipsis = false;

  bool showEndEllipsis = false;
  bool maintainEndEllipsisSpace = false;

  final ellipsisWidget = const Text('...');

  @override
  void initState() {
    executeOnNextFrame(() {
      final extentTotal = _scrollController.position.extentTotal;
      final viewPort = _scrollController.position.extentInside;

      final willScroll = extentTotal > viewPort;

      maintainEndEllipsisSpace = willScroll;
      setState(() => showEndEllipsis = willScroll);
    });

    _scrollController.addListener(
      () => setState(() {
        if (_scrollController.positions.isEmpty) return;

        final offset = _scrollController.offset;
        final maxScroll = _scrollController.position.maxScrollExtent;

        showStartEllipsis = offset > 1;
        showEndEllipsis = (maxScroll - offset) > 0;
      }),
    );

    super.initState();
  }

  void executeOnNextFrame(void Function() f) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => f.call());

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Visibility(
                visible: showStartEllipsis,
                child: ellipsisWidget,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Text(
                    widget.entry.name,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Visibility(
                visible: showEndEllipsis,
                maintainSize: maintainEndEllipsisSpace,
                maintainAnimation: maintainEndEllipsisSpace,
                maintainState: maintainEndEllipsisSpace,
                child: ellipsisWidget,
              ),
            ],
          ),
          Dimensions.spacingVerticalHalf,
          _buildDetails(context),
        ],
      );

  Widget _buildDetails(BuildContext context) {
    final uploadJob = widget.uploadJob;

    if (uploadJob != null) {
      return _buildUploadDetails(context, uploadJob);
    } else {
      return _buildSyncDetails(context);
    }
  }

  Widget _buildSyncDetails(BuildContext context) => BlocProvider(
        create: (context) => FileProgress(widget.repoCubit, widget.entry.path),
        child: BlocBuilder<FileProgress, int?>(builder: (cubit, soFar) {
          final total = widget.entry.size;

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
