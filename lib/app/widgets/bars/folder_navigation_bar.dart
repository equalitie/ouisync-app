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

    return Container(
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(child: _currentLocationBar(path)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentLocationBar(String path) {
    final current = basename(path);
    String separator = Strings.root;

    return Row(
      children: [
        _navigation(path),
        SizedBox(width: path == separator ? 5.0 : 0.0),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(left: 12.0, right: 12.0),
            child: Text(
              current,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _navigation(String path) {
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
