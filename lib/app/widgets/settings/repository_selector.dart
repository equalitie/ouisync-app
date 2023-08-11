import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_entry.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';

class RepositorySelector extends StatelessWidget with AppLogger {
  final ReposCubit repos;

  const RepositorySelector(this.repos);

  @override
  Widget build(BuildContext context) => Container(
        constraints: PlatformValues.isDesktopDevice
            ? BoxConstraints(
                maxWidth: PlatformValues.getFormFactorMaxWidth(context) * 0.7)
            : null,
        padding: Dimensions.paddingActionBox,
        decoration: const BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
            color: Constants.inputBackgroundColor),
        child: DropdownButton<RepoEntry?>(
          isExpanded: true,
          value: repos.currentRepo,
          underline: const SizedBox(),
          selectedItemBuilder: (context) => repos
              .repositoryNames()
              .map<Widget>((String repoName) => Padding(
                  padding: Dimensions.paddingItem,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Fields.idLabel(S.current.labelSelectRepository,
                              style: context.theme.appTextStyle.bodyMicro
                                  .copyWith(
                                      color: Constants.inputLabelForeColor))
                        ]),
                        Row(children: [
                          Fields.constrainedText(repoName,
                              style: context.theme.appTextStyle.labelMedium)
                        ])
                      ])))
              .toList(),
          items: repos.repos
              .map((RepoEntry repo) => DropdownMenuItem(
                  value: repo,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(repo == repos.currentRepo ? Icons.check : null,
                            size: Dimensions.sizeIconSmall,
                            color: Theme.of(context).primaryColor),
                        Dimensions.spacingHorizontalDouble,
                        Fields.constrainedText(repo.name,
                            style: context.theme.appTextStyle.labelMedium)
                      ])))
              .toList(),
          onChanged: (repo) async {
            loggy.app('Selected repository: ${repo?.name}');
            await repos.setCurrentByName(repo?.name);
          },
        ),
      );
}
