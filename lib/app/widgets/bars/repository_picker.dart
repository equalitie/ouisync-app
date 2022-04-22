import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../../models/repo_state.dart';
import '../../models/main_state.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryPicker extends StatefulWidget {
  const RepositoryPicker({
    required this.mainState,
    required this.repositoriesCubit,
    required this.onRepositorySelect,
    required this.borderColor
  });

  final MainState mainState;
  final RepositoriesCubit repositoriesCubit;
  final RepositoryCallback onRepositorySelect;
  final Color borderColor;

  @override
  _RepositoryPickerState createState() => _RepositoryPickerState();
}

class _RepositoryPickerState extends State<RepositoryPicker> {
  String _repositoryName = S.current.messageNoRepos;

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
          final color = state.repo == null
            ? colorLockedRepo
            : state.repo.accessMode != AccessMode.blind
              ? colorUnlockedRepo
              : colorLockedRepo;

          return _buildState(
            borderColor: widget.borderColor,
            iconColor: colorUnlockedRepo,
            textColor: color
          );
        }

        if (state is RepositoryPickerUnlocked) {
          final color = state.repo.accessMode != AccessMode.blind
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

        return Container(child: Text(S.current.messageErrorDefaultShort),);
      },
      listener: (context, state) {
        if (state is RepositoryPickerSelection) {
          _updateCurrentRepository(state.repo);
        }
        if (state is RepositoryPickerUnlocked) {
          _updateCurrentRepository(
            state.repo,
            previousAccessMode: state.previousAccessMode);
        }
        if (state is RepositoryPickerInitial) {
          _updateCurrentRepository(null);
        }
      },
    );
  }

  _updateCurrentRepository(RepoState? repo, {AccessMode? previousAccessMode}) async {
    setState(() {
      if (repo != null) {
        _repositoryName = repo.name;
      } else {
        _repositoryName = S.current.messageNoRepos;
      }
    });

    await widget.onRepositorySelect.call(repo, previousAccessMode);
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
        style: BorderStyle.solid
      ),
      color: Colors.white,
    ),
    child: InkWell(
      onTap: () async { await _showRepositorySelector(_repositoryName); },
      child: Row(
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
          SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: iconColor
            )
          ),
        ]
      )
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
        mainState: widget.mainState,
        context: context,
        cubit: widget.repositoriesCubit,
        current: _repositoryName,
        onRepositorySelect: widget.onRepositorySelect,
      );
    }
  );
}
