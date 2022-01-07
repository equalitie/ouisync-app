import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_app/app/utils/utils.dart';

import '../../bloc/blocs.dart';
import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../custom_widgets.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({
    required this.repositoriesCubit,
    required this.synchronizationCubit,
    required this.onRepositorySelect,
    required this.shareRepositoryOnTap
  });

  final RepositoriesCubit repositoriesCubit;
  final SynchronizationCubit synchronizationCubit;
  final RepositoryCallback onRepositorySelect;
  final ShareRepositoryCallback shareRepositoryOnTap;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        if (state is RouteLoadSuccess) {
          return _buildBar(state.route);
        }

        return _buildBar(Text(''));
      }
    );
  }

  _buildBar(route) {
    return Column(
      children: [
        _repositoriesBar(),
        Fields.routeBar(route: route),
      ],
    );
  }

  Container _repositoriesBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.transparent, style: BorderStyle.solid),
        ),
      ),
      padding: EdgeInsets.only(right: 10.0, left: 10.0, bottom: 10.0),
      child: Row(
        children: [
          _repositoryPicker(),
          SizedBox(width: 10.0,),
          _shareAction()
        ],
      )
    );
  }

  Expanded _repositoryPicker() {
    return Expanded(
          child: RepositoryPicker(
            repositoriesCubit: widget.repositoriesCubit,
            synchronizationCubit: widget.synchronizationCubit,
            onRepositorySelect: widget.onRepositorySelect,
            borderColor: Colors.white,
          ),
        );
  }

  GestureDetector _shareAction() {
    return GestureDetector(
      onTap: widget.shareRepositoryOnTap,
      child: const Icon(
        Icons.share_outlined,
        size: 40.0,
        color: Colors.white,
      ),
    );
  }
}