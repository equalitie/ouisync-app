import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../custom_widgets.dart';

class RepositoryPicker extends StatefulWidget {
  const RepositoryPicker({
    required this.repositoriesCubit,
    required this.synchronizationCubit,
    required this.onRepositorySelect,
    required this.borderColor,
    this.currentRepository,
    this.currentRepositoryName = ''
  });

  final RepositoriesCubit repositoriesCubit;
  final SynchronizationCubit synchronizationCubit;
  final RepositoryCallback onRepositorySelect;
  final Color borderColor;
  final Repository? currentRepository;
  final String currentRepositoryName;

  @override
  _RepositoryPickerState createState() => _RepositoryPickerState();
}

class _RepositoryPickerState extends State<RepositoryPicker> {
  Repository? _repository;
  String _repositoryName = 'No repositories found';

  @override
  void initState() {
    super.initState();

    initRepositoryPicker();  
  }

  void initRepositoryPicker() {
    if (widget.currentRepository == null
    || widget.currentRepositoryName.isEmpty) {
      return;
    } 

    setState(() {
      _repository = widget.currentRepository;
      _repositoryName = widget.currentRepositoryName;
    });
  }

  updateCurrentRepository(repository, name) async {
    if (name.isEmpty) {
      setState(() {
        _repositoryName = 'No repositories found';
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
      bloc: widget.repositoriesCubit,
      builder: (context, state) {
        if (state is RepositoriesInitial) {
          return _buildState(widget.borderColor, Colors.grey);
        }

        if (state is RepositoriesLoading) {
          return Column(children: [CircularProgressIndicator(color: Colors.white)],);
        }

        if (state is RepositoriesSelection) {
          return _buildState(widget.borderColor, Colors.black);
        }

        if (state is RepositoriesFailure) {
          return _buildState(widget.borderColor, Colors.red);
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

  _buildState(borderColor, iconColor) => Container(
    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      border: Border.all(
        color: borderColor,
        width: 1.0,
        style: BorderStyle.solid
      ),
      color: Colors.white,
    ),
    child: Row(
      children: [
        _repositoryIcon(iconColor),
        SizedBox(width: 10.0),
        Fields.constrainedText(
          _repositoryName,
          size: 20.0,
          softWrap: false,
          textOverflow: TextOverflow.fade,
          color: iconColor
        ),
        _syncSection(widget.synchronizationCubit),
        _actionsSection(),
      ],
    )
  );

  Icon _repositoryIcon(color) {
    return Icon(
      Icons.cloud_outlined,
      size: 30.0,
      color: color,
    );
  }

  Widget _syncSection(syncCubit) {
    return _repository != null
    ? Expanded(
      flex: 0,
      child: SyncWidget(cubit: syncCubit)
    )
    : Container(height: 35.0,);
  }

  Widget _actionsSection() {
    return _repository != null
    ? Fields.actionIcon(
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
        cubit: widget.repositoriesCubit,
        current: _repositoryName,
      );
    }
  );
}