import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubit/cubits.dart';
import '../../models/repo_state.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryPicker extends StatelessWidget {
  static const Color colorNoRepo = Colors.grey;
  static const Color colorLockedRepo = Colors.grey;
  static const Color colorUnlockedRepo = Colors.black;
  static const Color colorError = Colors.red;

  const RepositoryPicker({
    required this.repositoriesCubit,
    required this.borderColor,
    Key? key,
  }) : super(key: key);

  final RepositoriesCubit repositoriesCubit;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: repositoriesCubit,
      builder: (context, state) {
        if (state is RepositoryPickerInitial) {
          return _buildState(
            context,
            borderColor: borderColor,
            iconColor: colorNoRepo,
            textColor: colorNoRepo,
            repoName: _repoName(state),
          );
        }

        if (state is RepositoryPickerLoading) {
          return Column(children: const [CircularProgressIndicator(color: Colors.white)],);
        }

        if (state is RepositoryPickerSelection) {
          final color = state.repo == null
            ? colorLockedRepo
            : state.repo.accessMode != AccessMode.blind
              ? colorUnlockedRepo
              : colorLockedRepo;

          return _buildState(
            context,
            borderColor: borderColor,
            iconColor: colorUnlockedRepo,
            textColor: color,
            repoName: _repoName(state),
          );
        }

        if (state is RepositoryPickerUnlocked) {
          final color = state.repo.accessMode != AccessMode.blind
          ? colorUnlockedRepo
          : colorLockedRepo;

          return _buildState(
            context,
            borderColor: borderColor,
            iconColor: colorUnlockedRepo,
            textColor: color,
            repoName: _repoName(state),
          );
        }

        if (state is RepositoriesFailure) {
          return _buildState(
            context,
            borderColor: borderColor,
            iconColor: colorError,
            textColor: colorError,
            repoName: _repoName(state),
          );
        }

        return Container(child: Text(S.current.messageErrorDefaultShort),);
      },
      listener: (context, state) {
        if (state is RepositoryPickerSelection) {
          repositoriesCubit.mainState.setCurrent(state.repo);
        }
        if (state is RepositoryPickerUnlocked) {
          repositoriesCubit.mainState.setCurrent(state.repo);
        }
        if (state is RepositoryPickerInitial) {
          repositoriesCubit.mainState.setCurrent(null);
        }
      },
    );
  }

  String _repoName(RepositoryPickerState state) {
    RepoState? repo = null;

    if (state is RepositoryPickerSelection) {
      repo = state.repo;
    }
    if (state is RepositoryPickerUnlocked) {
      repo = state.repo;
    }

    if (repo != null) {
      return repo.name;
    } else {
      return S.current.messageNoRepos;
    }
  }

  _buildState(
    BuildContext context, {
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
    required String repoName,
  }) => Container(
    padding: Dimensions.paddingepositoryPicker,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
      border: Border.all(
        color: borderColor,
        style: BorderStyle.solid
      ),
      color: Colors.white,
    ),
    child: InkWell(
      onTap: () async { await _showRepositorySelector(context, repoName); },
      child: Row(
        children: [
          Icon(
            Icons.cloud_outlined,
            size: Dimensions.sizeIconSmall,
            color: iconColor,
          ),
          Dimensions.spacingHorizontal,
          Fields.constrainedText(
            repoName,
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

  Future<dynamic> _showRepositorySelector(BuildContext context, String repoName) => showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) {
      return RepositoryList(
        context: context,
        cubit: repositoriesCubit,
        current: repoName,
      );
    }
  );
}
