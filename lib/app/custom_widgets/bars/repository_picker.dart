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
    required this.borderColor
  });

  final RepositoriesCubit repositoriesCubit;
  final RepositoryCallback onRepositorySelect;
  final Color borderColor;

  @override
  _RepositoryPickerState createState() => _RepositoryPickerState();
}

class _RepositoryPickerState extends State<RepositoryPicker> {
  String _repositoryName = Strings.messageNoRepos;

  updateCurrentRepository(Repository? repository, String? name) async {
    setState(() {
      _repositoryName = name == null
      ? Strings.messageNoRepos
      : name;
    });

    if (repository == null && (name?.isEmpty ?? true)) {  
      widget.onRepositorySelect.call(null, '');
      return;
    }

    if (repository == null) { /// Every repository is initialized as a blind replica
      repository = await widget.repositoriesCubit
      .initRepository(name ?? '');
    }

    widget.onRepositorySelect.call(repository, name!);
  }

  static final Color colorNoRepo = Colors.grey;
  static final Color colorLockedRepo = Colors.grey;
  static final Color colorUnlockedRepo = Colors.black;
  static final Color colorError = Colors.red;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: widget.repositoriesCubit,
      builder: (context, state) {
        if (state is RepositoryPickerInitial) {
          return _buildState(
            borderColor: widget.borderColor,
            iconColor: colorNoRepo,
            textColor: colorNoRepo
          );
        }

        if (state is RepositoryPickerLoading) {
          return Column(children: [CircularProgressIndicator(color: Colors.white)],);
        }

        if (state is RepositoryPickerSelection) {
          final color = state.repository == null
          ? colorLockedRepo
          : state.repository!.accessMode != AccessMode.blind
          ? colorUnlockedRepo
          : colorLockedRepo;

          return _buildState(
            borderColor: widget.borderColor,
            iconColor: colorUnlockedRepo,
            textColor: color
          );
        }

        if (state is RepositoriesFailure) {
          return _buildState(
            borderColor: widget.borderColor,
            iconColor: colorError,
            textColor: colorError
          );
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

  _buildState({
    required Color borderColor,
    required Color iconColor,
    required Color textColor
  }) => Container(
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
          color: textColor
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
