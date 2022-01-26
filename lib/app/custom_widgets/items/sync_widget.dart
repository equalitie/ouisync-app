import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/cubits.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class SyncWidget extends StatefulWidget {
  SyncWidget({
    required this.cubit
  });

  final SynchronizationCubit cubit;

  @override
  _SyncWidgetState createState() => _SyncWidgetState();
}

class _SyncWidgetState extends State<SyncWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: widget.cubit,
      builder: (context, state) {
        if (state is SynchronizationInitial) {
          return _buildState(SyncStatus.idle);
        }

        if (state is SynchronizationOngoing) {
         return _buildState(SyncStatus.syncing); 
        }

        if (state is SynchronizationDone) {
          return _buildState(SyncStatus.done);
        }

        if (state is SynchronizationFailure) {
          return _buildState(SyncStatus.failed);
        }

        return Text(':\\');
      },
    );
  }

  Container _buildState(status) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        children: [
          _iconStatus(status),
          SizedBox(width: 4.0),
          _textStatus(status)
        ],
      )
    );
  }


  Widget _iconStatus(status) {
    return Icon(
      _iconForStatus(status),
      size: 28.0,
      color: _colorForStatus(status),
    );
  }

  Widget _textStatus(status) {
    return Text(
      _textForStatus(status),
      style: TextStyle(
        fontSize: Dimensions.fontAverage,
        fontWeight: FontWeight.w900,
        color: _colorForStatus(status)
      ),
    );
  }

  IconData _iconForStatus(status) {
    return status == SyncStatus.idle
    ? Icons.keyboard_control
    : status == SyncStatus.syncing
    ? Icons.sync
    : status == SyncStatus.done
    ? Icons.check_circle
    : Icons.sync_problem;
  }

  String _textForStatus(status) {
    return status == SyncStatus.idle
    ? 'O.O'
    : status == SyncStatus.syncing
    ? 'syncing'
    : status == SyncStatus.done
    ? 'synced'
    : ':\\';
  }

  Color _colorForStatus(status) {
    return status == SyncStatus.idle
    ? Colors.black38
    : status == SyncStatus.syncing
    ? Colors.blue
    : status == SyncStatus.done
    ? Colors.green
    : Colors.red;
  }
}