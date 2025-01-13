import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

typedef SaveFileCallback = Future<void> Function(String sourceFilePath);

class SaveSharedMedia extends StatefulWidget {
  const SaveSharedMedia(
    this.reposCubit, {
    required this.sharedMediaPaths,
    required this.canSaveMedia,
    required this.onUpdateBottomSheet,
    required this.onSaveFile,
  });

  final ReposCubit reposCubit;
  final List<String> sharedMediaPaths;
  final Future<bool> Function() canSaveMedia;
  final void Function(
    BottomSheetType type,
    double padding,
    String entry,
  ) onUpdateBottomSheet;
  final SaveFileCallback onSaveFile;

  @override
  State<SaveSharedMedia> createState() => _SaveSharedMediaState();
}

class _SaveSharedMediaState extends State<SaveSharedMedia> {
  final bodyKey = GlobalKey();
  Size? widgetSize;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild());

    super.initState();
  }

  void afterBuild() {
    final widgetContext = bodyKey.currentContext;
    if (widgetContext == null) return;

    widgetSize = widgetContext.size;

    widgetContext.size?.let((it) {
          widget.onUpdateBottomSheet(
            BottomSheetType.move,
            it.height,
            '',
          );
        }) ??
        0.0;
  }

  double mediaListMaxHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    /// We limit the size of the list of files to just 20% of the viewport, this
    /// way we prevent issues if the user is adding a lot of files.
    mediaListMaxHeight = MediaQuery.of(context).size.height * 0.2;

    return Container(
      key: bodyKey,
      padding: Dimensions.paddingBottomSheet,
      decoration: Dimensions.decorationBottomSheetAlternative,
      child: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.bottomSheetTitle(
              S.current.titleAddFile,
              style: context.theme.appTextStyle.titleMedium,
            ),
            _buildMediaList(widget.sharedMediaPaths),
            _buildFilesCount(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaList(List<String> mediaPaths) {
    if (mediaPaths.length == 1) {
      return _MediaDescription(mediaPath: mediaPaths.first);
    }

    return Container(
      constraints: BoxConstraints.loose(Size.fromHeight(mediaListMaxHeight)),
      height: mediaListMaxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.all(Radius.circular(6.0)),
        color: Color.fromARGB(150, 255, 255, 255),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Colors.black12,
        ),
        itemCount: mediaPaths.length,
        itemBuilder: (context, index) {
          final path = mediaPaths[index];
          return _MediaDescription(mediaPath: path);
        },
      ),
    );
  }

  Widget _buildFilesCount() {
    final totalFiles = widget.sharedMediaPaths.length;
    final pluralizedMessage =
        totalFiles == 1 ? S.current.messageFile : S.current.messageFiles;

    return Padding(
      padding: EdgeInsetsDirectional.all(4.0),
      child: Text(
        '$totalFiles $pluralizedMessage',
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildActions() => BlocBuilder<ReposCubit, ReposState>(
        bloc: widget.reposCubit,
        builder: (context, state) => Fields.dialogActions(
          buttons: _actions(state),
          padding: const EdgeInsetsDirectional.only(top: 20.0),
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      );

  List<Widget> _actions(ReposState reposState) {
    final isRepoList = reposState.current == null;

    return [
      NegativeButton(
        text: S.current.actionCancel,
        buttonsAspectRatio: Dimensions.aspectRatioBottomDialogButton,
        onPressed: () {
          widget.onUpdateBottomSheet(BottomSheetType.gone, 0.0, '');
          widget.reposCubit.bottomSheet.hide();
        },
      ),
      PositiveButton(
        text: S.current.actionSave,
        onPressed: isRepoList
            ? null
            : () async {
                final canSaveMedia = await widget.canSaveMedia();
                if (!canSaveMedia) {
                  return;
                }
                for (final path in widget.sharedMediaPaths) {
                  await widget.onSaveFile(path);
                }

                widget.onUpdateBottomSheet(BottomSheetType.gone, 0.0, '');
                widget.reposCubit.bottomSheet.hide();
              },
        buttonsAspectRatio: Dimensions.aspectRatioBottomDialogButton,
      ),
    ];
  }
}

class _MediaDescription extends StatelessWidget {
  const _MediaDescription({required this.mediaPath});

  final String mediaPath;

  @override
  Widget build(BuildContext context) {
    final parent = p.dirname(mediaPath);
    final name = p.basename(mediaPath);

    return Container(
      padding: Dimensions.paddingListItem,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 0,
                child: const Icon(Icons.insert_drive_file_outlined,
                    size: Dimensions.sizeIconAverage),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    name,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    parent,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
