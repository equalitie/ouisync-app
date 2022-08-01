import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_state.dart';
import '../../models/main_state.dart';
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
  Widget build(BuildContext context)  => repositoriesCubit.builder((state) {
    if (state.isLoading) {
      return Column(children: const [CircularProgressIndicator(color: Colors.white)],);
    }

    final repo = state.currentRepo;
    final name = _repoName(repo);

    if (repo == null) {
      return _buildState(
        context,
        borderColor: borderColor,
        iconColor: colorNoRepo,
        textColor: colorNoRepo,
        repoName: name,
      );
    }

    final color = repo.accessMode != AccessMode.blind
        ? colorUnlockedRepo
        : colorLockedRepo;

    return _buildState(
      context,
      borderColor: borderColor,
      iconColor: colorUnlockedRepo,
      textColor: color,
      repoName: name,
    );
  });

  String _repoName(RepoState? repo) {
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
      onTap: () async { await _showRepositorySelector(context); },
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

  Future<dynamic> _showRepositorySelector(BuildContext context) => showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: Dimensions.borderBottomSheetTop,
    builder: (context) {
      return RepositoryList(repositoriesCubit);
    }
  );
}
