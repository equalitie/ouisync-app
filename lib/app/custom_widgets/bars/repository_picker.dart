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
    required this.onRepositorySelect,
    required this.borderColor,
    this.currentRepository,
    this.currentRepositoryName = ''
  });

  final RepositoriesCubit repositoriesCubit;
  final RepositoryCallback onRepositorySelect;
  final Color borderColor;
  final Repository? currentRepository;
  final String currentRepositoryName;

  @override
  _RepositoryPickerState createState() => _RepositoryPickerState();
}

class _RepositoryPickerState extends State<RepositoryPicker> {
  Repository? _repository;
  String _repositoryName = Strings.messageNoRepos;

  @override
  void initState() {
    super.initState();

    initRepositoryPicker();  
  }

  void initRepositoryPicker() {
    if (widget.currentRepositoryName.isEmpty) {
      return;
    } 

    setState(() {
      _repository = widget.currentRepository;
      _repositoryName = widget.currentRepositoryName;
    });
  }

  updateCurrentRepository(Repository? repository, String name) async {
    if (repository == null) { /// Every repository is initialized as a blind replica
      repository = await widget.repositoriesCubit
      .initRepository(name);
    }

    setState(() {
      _repository = repository;
      _repositoryName = name;
    });

    widget.onRepositorySelect.call(repository, name);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: widget.repositoriesCubit,
      builder: (context, state) {
        if (state is RepositoryPickerInitial) {
          return _buildState(widget.borderColor, Colors.grey);
        }

        if (state is RepositoryPickerLoading) {
          return Column(children: [CircularProgressIndicator(color: Colors.white)],);
        }

        if (state is RepositoryPickerSelection) {
          return _buildState(widget.borderColor, Colors.black);
        }

        if (state is RepositoriesFailure) {
          return _buildState(widget.borderColor, Colors.red);
        }

        return Container(child: Text(Strings.messageOoops),);
      },
      listener: (context, state) {
        if (state is RepositoryPickerSelection) {
          updateCurrentRepository(state.repository, state.name);
        }
      },
    );
  }

  _buildState(borderColor, iconColor) => Container(
    padding: Dimensions.paddingepositoryPicker,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
      border: Border.all(
        color: borderColor,
        width: 1.0,
        style: BorderStyle.solid
      ),
      color: Colors.white,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_outlined,
          size: Dimensions.sizeIconSmall,
          color: iconColor,
        ),
        Dimensions.spacingHorizontal,
        Fields.constrainedText(
          _repositoryName,
          softWrap: false,
          textOverflow: TextOverflow.fade,
          color: iconColor
        ),
        Fields.actionIcon(
          const Icon(Icons.keyboard_arrow_down_outlined),
          onPressed: () async { 
            await _showRepositorySelector(_repositoryName); 
          },
          size: Dimensions.sizeIconSmall,
        )
      ],
    )
  );

  Future<dynamic> _showRepositorySelector(current) => showModalBottomSheet(
    isScrollControlled: true,
    context: context, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimensions.radiusSmall),
        topRight: Radius.circular(Dimensions.radiusSmall),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero
      ),
    ),
    builder: (context) {
      return RepositoryList(
        context: context,
        cubit: widget.repositoriesCubit,
        current: _repositoryName,
        onRepositorySelect: widget.onRepositorySelect,
      );
    }
  );
}
