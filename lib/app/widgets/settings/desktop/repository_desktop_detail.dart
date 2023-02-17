import 'package:flutter/material.dart';

import '../../../cubits/cubits.dart';
import '../../widgets.dart';

class RepositoryDesktopDetail extends StatelessWidget {
  RepositoryDesktopDetail(
      {required this.item,
      required this.reposCubit,
      required this.isBiometricsAvailable,
      required this.onShareRepository});

  final SettingItem item;
  final ReposCubit reposCubit;
  final bool isBiometricsAvailable;
  final void Function(RepoCubit) onShareRepository;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SizedBox.expand(
              child: Container(color: Colors.yellow, child: Text(item.name))))
    ]);
  }
}
