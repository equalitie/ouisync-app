import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:stream_transform/stream_transform.dart';

import '../cubits/mount.dart';
import '../cubits/repo.dart';
import '../utils/utils.dart';

const _iconSize = 20.0;
const _iconPadding = 2.0;
final _color = Colors.black.withAlpha(64);

/// Widget that displays repository error and sync progress.
class RepoStatus extends StatelessWidget {
  RepoStatus(this.repoCubit, {super.key});

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _Error(repoCubit),
          _Progress(repoCubit),
        ],
      );
}

/// Widget that builds itself whenever the sync progress of the repository changes.
class RepoProgressBuilder extends StatefulWidget {
  final RepoCubit repoCubit;
  final Widget Function(BuildContext, Progress) builder;

  RepoProgressBuilder(
      {required this.repoCubit, required this.builder, super.key});

  @override
  State<RepoProgressBuilder> createState() => _RepoProgressBuilderState();
}

class _RepoProgressBuilderState extends State<RepoProgressBuilder> {
  late final Stream<Progress> stream = widget.repoCubit.syncProgressStream;

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: stream,
        builder: (context, snapshot) => widget.builder(
            context, snapshot.data ?? Progress(value: 0, total: 1)),
      );
}

class _Progress extends StatelessWidget {
  _Progress(this.repoCubit);

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => RepoProgressBuilder(
        repoCubit: repoCubit,
        builder: (context, progress) => progress.isComplete
            ? _buildCompleteIcon()
            : _buildIndicator(progress.fraction),
      );

  Widget _buildIndicator(double fraction) => Container(
        width: _iconSize,
        height: _iconSize,
        padding: EdgeInsetsDirectional.all(_iconPadding),
        child: CircularProgressIndicator(
          value: fraction,
          color: _color,
          strokeWidth: 2.0,
        ),
      );

  Widget _buildCompleteIcon() => Container(
        decoration: ShapeDecoration(
          color: Colors.lightGreen,
          shape: CircleBorder(),
        ),
        padding: EdgeInsetsDirectional.all(_iconPadding),
        child: Icon(
          Icons.done,
          color: Colors.white,
          size: _iconSize - 2 * _iconPadding,
        ),
      );
}

class _Error extends StatelessWidget {
  _Error(this.repoCubit);

  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => switch (repoCubit.state.mountState) {
        MountStateDisabled() ||
        MountStateMounting() ||
        MountStateSuccess() =>
          SizedBox.shrink(),
        MountStateFailure(error: final error, stack: _) => GestureDetector(
            onTap: () => _showErrorDialog(
              context,
              error.toString(),
            ),
            child: Icon(
              Icons.warning,
              color: Constants.warningColor,
              size: _iconSize + 2 * _iconPadding,
            ),
          ),
      };

  Future<void> _showErrorDialog(
    BuildContext context,
    String message,
  ) =>
      Dialogs.simpleAlertDialog(
        context,
        title: 'Failed to mount the repository',
        message: 'Error: $message',
      );
}

extension _RepoCubitExtension on RepoCubit {
  Stream<Progress> get syncProgressStream =>
      events.startWith(null).asyncMapSample((_) => syncProgress);
}
