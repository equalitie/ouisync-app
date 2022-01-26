import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/blocs.dart';
import '../../utils/utils.dart';

class FolderNavigationBar extends StatelessWidget {
  const FolderNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        if (state is RouteLoadSuccess) {
          return Fields.routeBar(route: state.route);
        }

        return Fields.routeBar(route: Text(''));
      }
    );
  }
}