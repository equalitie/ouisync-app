import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/utils.dart';
import '../../bloc/blocs.dart';
import '../../models/main_state.dart';

class FolderNavigationBar extends StatelessWidget with PreferredSizeWidget {
  final MainState _mainState;

  FolderNavigationBar(this._mainState);

  String? get _path => _mainState.current?.currentFolder.path;

  @override
  Widget build(BuildContext context) =>
    BlocConsumer<DirectoryBloc, DirectoryState>(
      buildWhen: (context, state) {
        return state is DirectoryLoadSuccess;
      },
      builder: (context, state) {
        final path = _path;

        if (path != null) {
          return _routeBar(route: _currentLocationBar(path, context));
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

  static Container _routeBar({ required Widget route })
    => Container(
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
        ],
      ),
    );

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
          final currentRepo = _mainState.current;

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
