import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../controls.dart';

class RepositoryPicker extends StatefulWidget {
  const RepositoryPicker({
    required this.cubit,
    required this.onRepositorySelect
  });

  final RepositoriesCubit cubit;
  final RepositoryCallback onRepositorySelect;

  @override
  _RepositoryPickerState createState() => _RepositoryPickerState();
}

class _RepositoryPickerState extends State<RepositoryPicker> {
  Repository? _repository;
  String _repositoryName = '<empty>';

  updateCurrentRepository(repository, name) async {
    if (name.isEmpty) {
      setState(() {
        _repositoryName = 'No rap';
      });

      return;
    }

    if (_repositoryName != name) {
      setState(() {
        _repository = repository;
        _repositoryName = name;
      });
    }

    widget.onRepositorySelect.call(repository, name);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: widget.cubit,
      builder: (context, state) {
        if (state is RepositoriesInitial) {
          final greyIcon = const Icon(
            Icons.layers_rounded,
            size: 30.0,
            color: Colors.grey,
          );
          return _buildState(greyIcon);
        }

        if (state is RepositoriesLoading) {
          return CircularProgressIndicator();
        }

        if (state is RepositoriesSelection) {
          final normalIcon = const Icon(
            Icons.layers_rounded,
            size: 30.0,
          );
          return _buildState(normalIcon);
        }

        if (state is RepositoriesFailure) {
          final redIcon = const Icon(
            Icons.layers_rounded,
            size: 30.0,
            color: Colors.red,
          );
          return _buildState(redIcon);
        }

        return Container(child: Text('Ooops...'),);
      },
      listener: (context, state) {
        if (state is RepositoriesSelection) {
          updateCurrentRepository(state.repository, state.name);
        }
      },
    );
  }

  _buildState(icon) => Container(
    child: Row(
      children: [
        icon,
        SizedBox(width: 4.0),
        buildConstrainedText(_repositoryName, size: 20.0, softWrap: false, overflow: TextOverflow.fade),
        _repository != null
        ? buildActionIcon(icon: Icons.keyboard_arrow_down_outlined, onTap: () async { await _showRepositorySelector(_repositoryName); })
        : Container(),
      ],
    ),
  );

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
      return RepositoryList(
        context: context,
        cubit: widget.cubit,
        current: _repositoryName
      );
    }
  );
}