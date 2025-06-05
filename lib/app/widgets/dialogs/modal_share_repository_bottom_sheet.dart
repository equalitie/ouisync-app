import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n.dart';
import '../../cubits/repo.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ShareRepository extends StatefulWidget {
  const ShareRepository({
    required this.repository,
    required this.availableAccessModes,
    super.key,
  });

  final RepoCubit repository;
  final List<AccessMode> availableAccessModes;

  @override
  State<StatefulWidget> createState() => _ShareRepositoryState();
}

class _ShareRepositoryState extends State<ShareRepository> with AppLogger {
  AccessMode? _accessMode;

  String? _shareToken;
  String? _displayToken;

  final Map<AccessMode, String> accessModeDescriptions = {
    AccessMode.blind: S.current.messageBlindReplicaExplanation,
    AccessMode.read: S.current.messageReadReplicaExplanation,
    AccessMode.write: S.current.messageWriteReplicaExplanation,
  };

  final scrollController = ScrollController();

  TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    labelStyle = context.theme.appTextStyle.bodyMicro
        .copyWith(color: Constants.inputLabelForeColor);

    // On certain resolutions (higher) the constrain set on this dialog when called
    // causes the content to scroll, giving the appearance of a smaller padding
    // at the bottom of the content.
    //
    // That is why we force the scroll all the way back, so the removed space is
    // taken from the top and not the bottom

    // TODO: Remove once the constrains for this dialog are not longer needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });

    return Container(
        alignment: AlignmentDirectional.bottomCenter,
        padding:
            MediaQuery.paddingOf(context).add(Dimensions.paddingBottomSheet),
        child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Fields.bottomSheetHandle(context),
                  Fields.bottomSheetTitle(widget.repository.name,
                      style: context.theme.appTextStyle.titleMedium),
                  Dimensions.spacingVertical,
                  AccessModeSelector(
                    currentAccessMode: widget.repository.state.accessMode,
                    availableAccessMode: widget.availableAccessModes,
                    onChanged: _onChanged,
                    onDisabledMessage: (String message) => showSnackBar(
                      message,
                      context: context,
                    ),
                  ),
                  Dimensions.spacingVerticalHalf,
                  _buildAccessModeDescription(_accessMode),
                  Dimensions.spacingVerticalDouble,
                  _buildShareBox()
                ])));
  }

  Future<String> createShareToken(RepoCubit repo, AccessMode accessMode) async {
    final shareToken = await repo.createShareToken(accessMode);
    return shareToken.toString();
  }

  Future<void> _onChanged(AccessMode? accessMode) async {
    if (accessMode == null) {
      setState(() {
        _accessMode = null;
        _shareToken = null;
        _displayToken = Constants.ouisyncUrl;
      });

      return;
    }

    final token = await createShareToken(
      widget.repository,
      accessMode,
    );

    final displayToken = formatShareLinkForDisplay(token);

    setState(() {
      _accessMode = accessMode;
      _shareToken = token;
      _displayToken = displayToken;
    });
  }

  Widget _buildAccessModeDescription(AccessMode? accessMode) => Padding(
        padding: Dimensions.paddingItem,
        child: Row(
          children: [
            Fields.constrainedText(_tokenDescription(accessMode),
                style: context.theme.appTextStyle.bodyMicro
                    .copyWith(color: Colors.black54),
                softWrap: true,
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis),
          ],
        ),
      );

  String _tokenDescription(AccessMode? accessMode) {
    if (accessMode == null) {
      return S.current.messageSelectAccessMode;
    }
    return accessModeDescriptions.values.elementAt(accessMode.index);
  }

  Widget _buildShareBox() => Container(
        padding: Dimensions.paddingItemBoxLoose,
        decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(Dimensions.radiusSmall),
          ),
          color: Constants.inputBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Fields.constrainedText(S.current.labelRepositoryLink,
                flex: 0, style: labelStyle),
            Padding(
              padding: Dimensions.paddingActionBoxRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Fields.constrainedText(_displayToken ?? Constants.ouisyncUrl,
                      style: TextStyle().copyWith(
                          color: _shareToken != null
                              ? Colors.black
                              : Colors.black54),
                      softWrap: true,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            _buildShareActions(),
          ],
        ),
      );

  Widget _buildShareActions() => Expanded(
        flex: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Fields.actionIcon(const Icon(Icons.content_copy_rounded),
                    size: Dimensions.sizeIconSmall,
                    color: _getActionStateColor(_shareToken != null),
                    onPressed: () async {
                  if (_shareToken == null) {
                    showSnackBar(
                      S.current.messageShareActionDisabled,
                      context: context,
                    );

                    return;
                  }

                  await copyStringToClipboard(_shareToken!);

                  showSnackBar(
                    S.current.messageTokenCopiedToClipboard,
                    context: context,
                  );
                }),
                Fields.constrainedText(S.current.labelCopyLink,
                    flex: 0, style: labelStyle),
              ],
            ),
            Column(children: [
              Fields.actionIcon(
                  const Icon(
                    Icons.share_outlined,
                  ),
                  size: Dimensions.sizeIconSmall,
                  color: _getActionStateColor(_shareToken != null),
                  onPressed: () async {
                if (_shareToken == null) {
                  showSnackBar(
                    S.current.messageShareActionDisabled,
                    context: context,
                  );

                  return;
                }

                Rect? origin;

                /// We need the sharePositionOrigin parameter for iPads and macOS, or it would throw an exception.
                if (Platform.isIOS || Platform.isMacOS) {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  origin = (renderBox?.localToGlobal(Offset.zero) ??
                          Offset(0.0, 0.0)) &
                      (renderBox?.size ?? Size.zero);
                }

                await Share.share(_shareToken!, sharePositionOrigin: origin);
              }),
              Fields.constrainedText(S.current.labelShareLink,
                  flex: 0, style: labelStyle),
            ]),
            Column(
              children: [
                Fields.actionIcon(
                    const Icon(
                      Icons.qr_code_2_outlined,
                    ),
                    size: Dimensions.sizeIconSmall,
                    color: _getActionStateColor(_shareToken != null),
                    onPressed: () async {
                  if (_shareToken == null) {
                    showSnackBar(
                      S.current.messageShareActionDisabled,
                      context: context,
                    );

                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return RepositoryQRPage(
                        shareLink: _shareToken!,
                      );
                    }),
                  );
                }),
                Fields.constrainedText(S.current.labelQRCode,
                    flex: 0, style: labelStyle),
              ],
            )
          ],
        ),
      );

  Color _getActionStateColor(bool isEnabled) {
    if (isEnabled) {
      return Theme.of(context).primaryColor;
    }

    return Colors.grey;
  }
}
