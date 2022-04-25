import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../../utils/utils.dart';
import '../../bloc/blocs.dart';
import '../../cubit/repository_progress.dart';
import '../../models/main_state.dart';

class FolderNavigationBar extends StatelessWidget with PreferredSizeWidget {
  final MainState _mainState;
  // This is used to make the progress go all the way from the beginning of the circle to the end.
  // If we did not use it, then after the repository gets bigger, we start seeing a circle which
  // is almost full, but with only few pixels remaining.
  _Start? _start;

  FolderNavigationBar(this._mainState);

  String? get _path {
    final currentRepo = _mainState.currentRepo;
    if (currentRepo == null) return null;
    if (currentRepo.accessMode == oui.AccessMode.blind) return null;
    return currentRepo.currentFolder.path;
  }

  @override
  Widget build(BuildContext context) =>
    BlocConsumer<DirectoryBloc, DirectoryState>(
      buildWhen: (context, state) {
        return state is DirectoryReloaded;
      },
      builder: (context, state) {
        final path = _path;

        if (path != null) {
          return _routeBar(path, context);
        } else {
          return SizedBox.shrink();
        }
      },
      listener: (context, state) {}
    );

  @override
  Size get preferredSize {
    if (_path == null) {
      return Size(0.0, 0.0);
    }
    // TODO: This value was found experimentally, can it be done programmatically?
    return Size.fromHeight(51);
  }

  Container _routeBar(String path, BuildContext context) {
    final route = _currentLocationBar(path, context);

    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.0,
            color: Colors.transparent,
            style: BorderStyle.solid
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(child: route),
              ],
            )
          ),
          _progressBar(context),
        ],
      ),
    );
  }

  Widget _progressBar(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<RepositoryProgressCubit>(context),
      buildWhen: (context, state) {
        if (!(state is RepositoryProgressUpdate)) {
          return false;
        }

        return state.repo == _mainState.currentRepo;
      },
      builder: (context, state) {
        //return ConstrainedBox(constraints: BoxConstraints.tight(Size.square(25)), child: CircularProgressIndicator());
        if (!(state is RepositoryProgressUpdate)) {
          return SizedBox.shrink();
        }

        final v = state.progress.value;
        final t = state.progress.total;

        if (v == t || t == 0) {
          return SizedBox.shrink();
        }

        var s = _start;

        if (s == null || s.total != t) {
          s = _Start(v, t);
          _start = s;
        }

        final v_ = v - s.value;
        final t_ = t - s.value;

        return ConstrainedBox(
            constraints: BoxConstraints.tight(Size.square(Dimensions.sizeIconSmall)),
            child: CircularProgressIndicator(
              backgroundColor: Constants.progressBarBackgroundColor,
              value: v_.toDouble() / t_.toDouble()
        ));
      },
      listener: (context, state) { }
    );
  }

  Widget _currentLocationBar(String path, BuildContext ctx) {
    final current = getBasename(path);
    String separator = Strings.root;

    return Row(
      children: [
        _navigation(path, ctx),
        SizedBox(
          width: path == separator
          ? 5.0
          : 0.0
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: Dimensions.paddingActionBox,
            child: Text(
              '$current',
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Dimensions.fontAverage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _navigation(String path, BuildContext ctx) {
    final target = getParentSection(path);
    final bloc = BlocProvider.of<DirectoryBloc>(ctx);

    return GestureDetector(
      onTap: () {
        if (target != path) {
          final currentRepo = _mainState.currentRepo;

          if (currentRepo == null) {
            return;
          }

          final parent = currentRepo.currentFolder.parent;
          bloc.add(NavigateTo(currentRepo, parent));
        }
      },
      child: path == Strings.root
      ? const Icon(
          Icons.lock_rounded,
          size: Dimensions.sizeIconAverage,
        )
      : const Icon(
          Icons.arrow_back,
          size: Dimensions.sizeIconAverage,
        ),
    );
  }
}

class _Start {
  _Start(this.value, this.total);
  int value;
  int total;
}
