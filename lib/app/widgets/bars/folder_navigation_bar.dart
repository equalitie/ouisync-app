import 'package:flutter/material.dart';
import '../../utils/extensions.dart';
import '../widgets.dart';

import '../../cubits/cubits.dart';
import '../../utils/repo_path.dart' as repo_path;
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
            child: Row(
              children: [Expanded(child: _currentLocationBar(context, path))],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentLocationBar(BuildContext context, String path) {
    final current = repo_path.basename(path);
    String separator = Strings.root;

    final parentColor =
        context.theme.primaryTextTheme.titleMedium?.color ?? Colors.transparent;

    return Row(
      children: [
        _navigation(path),
        SizedBox(width: path == separator ? 5.0 : 0.0),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12.0, right: 12.0),
            child: ScrollableTextWidget(
              child: Text(current),
              parentColor: parentColor,
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
      child:
          path == Strings.root
              ? const Icon(Icons.lock_rounded)
              : const Icon(Icons.arrow_back),
    );
  }
}
