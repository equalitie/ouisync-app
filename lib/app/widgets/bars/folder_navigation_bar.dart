import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/blocs.dart';
import '../../utils/utils.dart';

class FolderNavigationBar extends StatelessWidget with PreferredSizeWidget {
  final String? _path;
  final Function _action;

  FolderNavigationBar(this._path, this._action);

  @override
  Widget build(BuildContext context) {
    final path = _path;

    if (path != null) {
      return _routeBar(route: _currentLocationBar(path, _action));
    } else {
      return SizedBox.shrink();
    }
  }

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

  Widget _currentLocationBar(String path, Function action) {
    final current = removeParentFromPath(path);
    return Row(
      children: [
        _navigation(path, action),
        SizedBox(
          width: path == Strings.rootPath
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

  GestureDetector _navigation(String path, Function action) {
    final target = extractParentFromPath(path);

    return GestureDetector(
      onTap: () {
        if (target != path) {
          action.call();
        }
      },
      child: path == Strings.rootPath
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
