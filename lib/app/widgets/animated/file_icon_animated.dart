import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../../models/models.dart' as model;

class FileIconAnimated 
  extends StatelessWidget
  with OuiSyncAppLogger {
  FileIconAnimated({
    required this.repository,
    required this.path,
    Key? key,
  }) : super(key: key);

  final model.RepoState repository;
  final String path;

  String? _destinationPath;
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectoryCubit, DirectoryState>(
      buildWhen: (previous, current) {
        if (current is DownloadFileInProgress ||
            current is DownloadFileDone) {
              return _isCurrentFile(current);}

        return false;
      },
      builder: (context, state) {
        return GestureDetector(
          child: _getWidgetForState(context, state),
          onTap: () => onFileIconTap(context, state),);
      },);
    
  }

  void onFileIconTap(BuildContext context, DirectoryState state) {
    if (_destinationPath?.isNotEmpty ?? false) {
      _showDownloadLocation(context);
      return;
    } 

    if (_downloading) {
      BlocProvider.of<DirectoryCubit>(context).cancelDownloadFile(
        repository,
        _getPathFromState(state));
    }
  }

  void _showDownloadLocation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.current.titleDownloadLocation),
          content: SingleChildScrollView(
            child: ListBody(children: [
              Text(S.current.labelDownloadedTo),
              Text(_destinationPath ?? '?')]),
          ),
          actions: [ TextButton(
            child: Text(S.current.actionCloseCapital),
            onPressed: () => Navigator.of(context, rootNavigator: false).pop(false),
          )],
        );
      }
    );
  }

  Widget _getWidgetForState(BuildContext context, DirectoryState state) {
    if (_isCurrentFile(state)) {
      _destinationPath = null;
      _downloading = false;

      if (state is DownloadFileInProgress) {
        _downloading = true;

        final ratio = state.progress / state.length;
        final percentage = (ratio * 100.0).round();

        return CircularPercentIndicator(
          radius: Dimensions.sizeIconMicro,
          animation: true,
          animateFromLastPercent: true,
          percent: ratio,
          progressColor: Theme.of(context).colorScheme.secondary,
          center: Text(
            '$percentage%',
            style: const TextStyle(fontSize: Dimensions.fontMicro)));
      }

      if (state is DownloadFileDone) {
        IconData iconData;
        switch (state.result) {
          case DownloadFileResult.done:
            _destinationPath = state.devicePath;
            iconData = Icons.download_done_rounded;
            break;
          case DownloadFileResult.canceled:
            iconData = Icons.file_download_off;
            break;
          case DownloadFileResult.failed:
            iconData = Icons.cancel;
            break;
        }

        return Icon(iconData);
      }
    }

    return const Icon(
      Icons.insert_drive_file_outlined,
      size: Dimensions.sizeIconAverage); // Default icon;
  }

  bool _isCurrentFile (DirectoryState state) {
    final originRepository = _getRepositoryFromState(state);
    if (originRepository != repository.handle) {
      return false;
    }

    final originPath = _getPathFromState(state);
    return originPath == path;
  }

  Repository? _getRepositoryFromState(DirectoryState state) {
    if (state is DownloadFileInProgress) {
      return state.repository.handle;
    }

    if (state is DownloadFileDone) {
      return state.repository.handle;
    }

    return null;
  }

  String _getPathFromState(DirectoryState state) {
    if (state is DownloadFileInProgress) {
      return state.fileName;
    }

    if (state is DownloadFileDone) {
      return state.path;
    }

    return '';
  }
}
