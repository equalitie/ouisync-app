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
  String _repositoryName = 'No lockboxes found';

  updateCurrentRepository(repository, name) async {
    if (name.isEmpty) {
      setState(() {
        _repositoryName = 'No lockboxes found';
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
          return _buildState(Colors.grey);
        }

        if (state is RepositoriesLoading) {
          return Column(children: [CircularProgressIndicator(color: Colors.white)],);
        }

        if (state is RepositoriesSelection) {
          return _buildState(Colors.black);
        }

        if (state is RepositoriesFailure) {
          return _buildState(Colors.red);
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

  _buildState(color) => Row(
    children: [
      Expanded( 
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
          ),
          child: Expanded(
            child: Row(
              children: [
                _repositoryIcon(color),
                SizedBox(width: 10.0),
                buildConstrainedText(_repositoryName, size: 20.0, softWrap: false, overflow: TextOverflow.fade, color: color),
                _syncSection(),
                _actionsSection(),
              ],
            )
          )
        ),
      ),
    ],
  );

  Icon _repositoryIcon(color) {
    return Icon(
      Icons.cloud_outlined,
      size: 30.0,
      color: color,
    );
  }

  Widget _syncSection() {
    return _repository != null
    ? Expanded(
      flex: 0,
      child: SyncWidget()
    )
    : Container(height: 35.0,);
  }

  Widget _actionsSection() {
    return _repository != null
    ? buildActionIcon(
      icon: Icons.keyboard_arrow_down_outlined,
      onTap: () async { await _showRepositorySelector(_repositoryName); }
    )
    : Container();
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
      return RepositoryList(
        context: context,
        cubit: widget.cubit,
        current: _repositoryName,
      );
    }
  );
}