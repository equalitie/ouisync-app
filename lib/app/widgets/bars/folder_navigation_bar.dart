import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' as oui;

import '../../utils/utils.dart';
import '../../cubits/cubits.dart';

class FolderNavigationBar extends StatelessWidget {
  final ReposState _reposState;

  FolderNavigationBar(this._reposState);

  @override
  Widget build(BuildContext context) {
    final path = _reposState.currentFolder!.path;
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
    final cubit = BlocProvider.of<DirectoryCubit>(ctx);

    return GestureDetector(
      onTap: () {
        if (target != path) {
          final currentRepo = _reposState.currentRepo;

          if (currentRepo == null) {
            return;
          }

          final parent = currentRepo.currentFolder.parent;
          cubit.navigateTo(ctx, currentRepo, parent);
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
