import 'package:flutter/material.dart';

import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../../models/main_state.dart';
import '../widgets.dart';

class RepositoriesBar extends StatelessWidget with PreferredSizeWidget {
  const RepositoriesBar({
    required this.repositoriesCubit,
    required this.shareRepositoryOnTap
  });

  final RepositoriesCubit repositoriesCubit;
  final ShareRepositoryCallback shareRepositoryOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.transparent, style: BorderStyle.solid),
        ),
      ),
      padding: Dimensions.paddingRepositoryBar,
      child: Row(
        children: [
          Expanded(
            child: RepositoryPicker(
              repositoriesCubit: repositoriesCubit,
              borderColor: Colors.white,
            ),
          ),
          Fields.actionIcon(
            const Icon(Icons.share_outlined),
            onPressed: shareRepositoryOnTap,
            size: Dimensions.sizeIconSmall,
            color: Colors.white,
          )
        ],
      )
    );
  }

  @override
  Size get preferredSize {
    // TODO: This value was found experimentally, can it be done programmatically?
    return Size.fromHeight(58);
  }
}
