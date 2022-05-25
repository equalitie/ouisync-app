import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../generated/l10n.dart';
import '../../bloc/blocs.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class FileIconAnimated 
  extends StatelessWidget
  with OuiSyncAppLogger {
  FileIconAnimated({
    Key? key,
    required this.path
  }) : super(key: key);

  final String path;

  String? _destinationPath;
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectoryBloc, DirectoryState>(
      buildWhen: (previous, current) {
        if (current is DownloadFileInProgress ||
            current is DownloadFileDone ||
            current is DownloadFileFail ||
            current is DownloadFileCancel) {
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
      BlocProvider.of<DirectoryBloc>(context).add(
        CancelDownloadFile(filePath: _getPathFromState(state)));
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
        _destinationPath = state.devicePath;

        return const Icon(
          Icons.download_done_rounded,
          size: Dimensions.sizeIconAverage);
      }

      if (state is DownloadFileCancel) {
        return const Icon(
          Icons.file_download_off,
          size: Dimensions.sizeIconAverage);
      }

      if (state is DownloadFileFail) {
        return const Icon(
          Icons.cancel,
          size: Dimensions.sizeIconAverage);
      }
    }

    return const Icon(
      Icons.insert_drive_file_outlined,
      size: Dimensions.sizeIconAverage); // Default icon;
  }

  bool _isCurrentFile (DirectoryState state) {
    final originPath = _getPathFromState(state);
    return originPath == path;
  }

  String _getPathFromState(DirectoryState state) {
    if (state is DownloadFileInProgress) {
      return state.fileName;
    }

    if (state is DownloadFileDone) {
      return state.path;
    }

    if (state is DownloadFileCancel) {
      return state.path;
    }

    if (state is DownloadFileFail) {
      return state.path;
    }

    return '';
  }
}