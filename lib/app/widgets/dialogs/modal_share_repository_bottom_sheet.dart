import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n.dart';
import '../../cubits/repo.dart';
import '../../pages/pages.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ShareRepository extends StatefulWidget {
  const ShareRepository({
    required this.repository,
    required this.availableAccessModes,
    Key? key,
  }) : super(key: key);

  final RepoCubit repository;
  final List<AccessMode> availableAccessModes;

  @override
  State<StatefulWidget> createState() => _ShareRepositoryState();
}

class _ShareRepositoryState extends State<ShareRepository>
    with OuiSyncAppLogger {
  AccessMode? _accessMode;

  String? _shareToken;
  String? _displayToken;

  final Map<AccessMode, String> accessModeDescriptions = {
    AccessMode.blind: S.current.messageBlindReplicaExplanation,
    AccessMode.read: S.current.messageReadReplicaExplanation,
    AccessMode.write: S.current.messageWriteReplicaExplanation,
  };

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // On certain resolutions (higer) the constrain set on this dialog when called
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
        alignment: Alignment.bottomCenter,
        padding: Dimensions.paddingBottomSheet,
        child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Fields.bottomSheetHandle(context),
                  Fields.bottomSheetTitle(widget.repository.name),
                  Dimensions.spacingVertical,
                  AccessModeSelector(
                    currentAccessMode: widget.repository.accessMode,
                    availableAccessMode: widget.availableAccessModes,
                    onChanged: _onChanged,
                    onDisabledMessage: (String message) =>
                        showSnackBar(context, content: Text(message)),
                  ),
                  Dimensions.spacingVerticalHalf,
                  _buildAccessModeDescription(_accessMode),
                  Dimensions.spacingVerticalDouble,
                  _buildShareBox()
                ])));
  }

  Future<String> createShareToken(RepoCubit repo, AccessMode accessMode) async {
    final shareToken = await repo.createShareToken(accessMode);

    if (kDebugMode) {
      // Print this only while debugging, tokens are secrets that shouldn't be logged otherwise.
      loggy.app(
          'Token for sharing repository ${repo.name}: $shareToken (${accessMode.name})');
    }

    return shareToken.token;
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
            Fields.constrainedText(
              _tokenDescription(accessMode),
              flex: 0,
              fontSize: Dimensions.fontMicro,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
            ),
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
          borderRadius: BorderRadius.all(
            Radius.circular(
              Dimensions.radiusSmall,
            ),
          ),
          color: Constants.inputBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Fields.constrainedText(
              S.current.labelRepositoryLink,
              flex: 0,
              fontSize: Dimensions.fontMicro,
              fontWeight: FontWeight.normal,
              color: Constants.inputLabelForeColor,
            ),
            Padding(
              padding: Dimensions.paddingActionBoxRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Fields.constrainedText(
                    _displayToken ?? Constants.ouisyncUrl,
                    flex: 0,
                    softWrap: true,
                    maxLines: 2,
                    textOverflow: TextOverflow.fade,
                    color: _shareToken != null ? Colors.black : Colors.black54,
                  ),
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
                    showSnackBar(context,
                        content: Text(S.current.messageShareActionDisabled));

                    return;
                  }

                  await copyStringToClipboard(_shareToken!);
                  showSnackBar(
                    context,
                    content: Text(
                      S.current.messageTokenCopiedToClipboard,
                    ),
                  );
                }),
                Fields.constrainedText(
                  S.current.labelCopyLink,
                  flex: 0,
                  fontSize: Dimensions.fontMicro,
                  fontWeight: FontWeight.normal,
                  color: Constants.inputLabelForeColor,
                ),
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
                  showSnackBar(context,
                      content: Text(S.current.messageShareActionDisabled));

                  return;
                }

                await Share.share(_shareToken!);
              }),
              Fields.constrainedText(
                S.current.labelShareLink,
                flex: 0,
                fontSize: Dimensions.fontMicro,
                fontWeight: FontWeight.normal,
                color: Constants.inputLabelForeColor,
              ),
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
                    showSnackBar(context,
                        content: Text(S.current.messageShareActionDisabled));

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
                Fields.constrainedText(
                  S.current.labelQRCode,
                  flex: 0,
                  fontSize: Dimensions.fontMicro,
                  fontWeight: FontWeight.normal,
                  color: Constants.inputLabelForeColor,
                ),
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
