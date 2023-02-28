import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../../cubits/cubits.dart';

class FolderNavigationBar extends StatelessWidget {
  final RepoCubit _repo;

  const FolderNavigationBar(this._repo);

  @override
  Widget build(BuildContext context) {
    final path = _repo.state.currentFolder.path;
    final route = _currentLocationBar(path, context);

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              width: 0.0, color: Colors.transparent, style: BorderStyle.solid),
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
              )),
        ],
      ),
    );
  }

  Widget _currentLocationBar(String path, BuildContext ctx) {
    final current = getBasename(path);
    String separator = Strings.root;

    return Row(
      children: [
        _navigation(path, ctx),
        SizedBox(width: path == separator ? 5.0 : 0.0),
        Expanded(
          flex: 1,
          child: Padding(
            padding: Dimensions.paddingActionBox,
            child: Text(
              current,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
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
    final target = getDirname(path);

    return GestureDetector(
      onTap: () {
        if (target != path) {
          final parent = _repo.state.currentFolder.parent;
          _repo.navigateTo(parent);
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
