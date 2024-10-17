import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../../cubits/cubits.dart';
import '../../utils/fields.dart';
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/strings.dart';

class FolderNavigationBar extends StatelessWidget {
  final RepoCubit _repo;

  const FolderNavigationBar(this._repo);

  @override
  Widget build(BuildContext context) {
    final path = _repo.state.currentFolder.path;

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
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
    final current = repo_path.basename(path);
    String separator = Strings.root;

    return Row(
      children: [
        _navigation(path),
        SizedBox(width: path == separator ? 5.0 : 0.0),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 12.0, end: 12.0),
            child: Fields.ellipsedText(
              current,
              ellipsisPosition: TextOverflowPosition.middle,
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _navigation(String path) {
    final target = repo_path.dirname(path);

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
