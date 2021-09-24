import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/blocs.dart';
import '../../utils/utils.dart';

class RouteBar extends StatelessWidget {
  const RouteBar({
    required this.animationController
  });

  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        if (state is RouteLoadSuccess) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: state.route,
                            ),
                            Expanded(
                              flex: 0,
                              child: SpinningIcon(
                                controller: animationController,
                                icon: const Icon(Icons.sync_rounded),
                                onPressed: () {}
                              )
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.0,
                  thickness: 2.0,
                )
              ],
            ),
          );
        }

        return Container(
          child: Text('...')
        );
      }
    );
  }
}