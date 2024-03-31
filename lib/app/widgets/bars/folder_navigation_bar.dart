import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../utils/path.dart';
import '../../utils/strings.dart';

class FolderNavigationBar extends StatelessWidget {
  final RepoCubit _repo;

  const FolderNavigationBar(this._repo);

  @override
  Widget build(BuildContext context) {
    final path = _repo.state.currentFolder.path;
    final route = _currentLocationBar(context, path, context);

    return Container(
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(child: route),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentLocationBar(
    BuildContext context,
    String path,
    BuildContext ctx,
  ) {
    final current = basename(path);
    String separator = Strings.root;

    return Row(
      children: [
        _navigation(path, ctx),
        SizedBox(width: path == separator ? 5.0 : 0.0),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              current,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _navigation(String path, BuildContext ctx) {
    final target = dirname(path);

    return GestureDetector(
        onTap: () {
          if (target != path) {
            final parent = _repo.state.currentFolder.parent;
            _repo.navigateTo(parent);
          }
        },
        child: path == Strings.root
            ? const Icon(Icons.lock_rounded)
            : const Icon(Icons.arrow_back));
  }
}
