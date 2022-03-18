import 'package:flutter/material.dart';

import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoriesBar extends StatefulWidget {
  const RepositoriesBar({
    required this.repositoriesCubit,
    required this.onRepositorySelect,
    required this.shareRepositoryOnTap
  });

  final RepositoriesCubit repositoriesCubit;
  final RepositoryCallback onRepositorySelect;
  final ShareRepositoryCallback shareRepositoryOnTap;

  @override
  State<RepositoriesBar> createState() => _RepositoriesBarState();
}

class _RepositoriesBarState extends State<RepositoriesBar> with TickerProviderStateMixin {

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
              repositoriesCubit: widget.repositoriesCubit,
              onRepositorySelect: widget.onRepositorySelect,
              borderColor: Colors.white,
            ),
          ),
          Fields.actionIcon(
            const Icon(Icons.share_outlined),
            onPressed: widget.shareRepositoryOnTap,
            size: Dimensions.sizeIconSmall,
            color: Colors.white,            
          )
        ],
      )
    );
  }
}
