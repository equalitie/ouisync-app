import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../utils/utils.dart';
import '../controls.dart';

class RepositoryPicker extends StatelessWidget {
  const RepositoryPicker({
    required this.context,
    required this.defaultRepository
  });

  final BuildContext context;
  final String defaultRepository;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          const Icon(
            Icons.layers_rounded,
            size: 30.0,
          ),
          SizedBox(width: 4.0),
          buildConstrainedText(defaultRepository, size: 20.0, softWrap: false, overflow: TextOverflow.fade),
          buildActionIcon(icon: Icons.keyboard_arrow_down_outlined, onTap: () async { await _showRepositorySelector(defaultRepository); }),
        ],
      )
    );
  }

  Future<dynamic> _showRepositorySelector(current) => showModalBottomSheet(
    isScrollControlled: true,
    context: context, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero
      ),
    ),
    builder: (context) {
      return RepositoryList(current: defaultRepository);
    }
  );
}