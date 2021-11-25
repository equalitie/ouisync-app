import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/blocs.dart';
import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../custom_widgets.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({
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
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> with TickerProviderStateMixin {

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
        _routeBar(route),
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

  Container _routeBar(route) {
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
}