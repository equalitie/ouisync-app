import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n.dart';
import '../../cubits/repo.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ShareRepository extends StatefulWidget {
  const ShareRepository({
    required this.repository,
    required this.availableAccessModes,
  });

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
    AccessMode.write: S.current.messageWriteReplicaExplanation
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingBottomSheet,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.bottomSheetHandle(context),
            Fields.bottomSheetTitle(widget.repository.name),
            Dimensions.spacingVerticalDouble,
            AccessModeSelector(
                accessModes: widget.availableAccessModes,
                onChanged: _onChanged),
            Dimensions.spacingVerticalHalf,
            _buildAccessModeDescription(_accessMode),
            Dimensions.spacingVerticalDouble,
            _buildShareBox()
          ]),
    );
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
        _displayToken = S.current.messageWaitingAccesMode;
      });

      return;
    }

    final token = await createShareToken(widget.repository, accessMode);
    final displayToken = _formatShareLinkForDisplay(token);
    setState(() {
      _accessMode = accessMode;

      _shareToken = token;
      _displayToken = displayToken;
    });
  }

  String _formatShareLinkForDisplay(String shareLink) {
    final shareTokenUri = Uri.parse(shareLink);
    final truncatedToken =
        '${shareTokenUri.fragment.substring(0, Constants.maxCharacterRepoTokenForDisplay)}...';

    final displayToken = shareTokenUri.replace(fragment: truncatedToken);
    return displayToken.toString();
  }

  Widget _buildAccessModeDescription(AccessMode? accessMode) => Padding(
      padding: Dimensions.paddingItem,
      child: Row(children: [
        Fields.constrainedText(_tokenDescription(accessMode),
            flex: 0,
            fontSize: Dimensions.fontMicro,
            fontWeight: FontWeight.normal,
            color: Colors.black54)
      ]));

  String _tokenDescription(AccessMode? accessMode) {
    if (accessMode == null) {
      return S.current.messageSelectAccessMode;
    }
    return accessModeDescriptions.values.elementAt(accessMode.index);
  }

  Widget _buildShareBox() => Container(
      padding: Dimensions.paddingItemBox,
      decoration: const BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
          color: Constants.inputBackgroundColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fields.constrainedText(S.current.labelRepositoryLink,
              flex: 0,
              fontSize: Dimensions.fontMicro,
              fontWeight: FontWeight.normal,
              color: Constants.inputLabelForeColor),
          Padding(
            padding: Dimensions.paddingActionBoxRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Fields.constrainedText(
                  _displayToken ?? S.current.messageWaitingAccesMode,
                  flex: 0,
                  softWrap: true,
                  maxLines: 2,
                  textOverflow: TextOverflow.fade,
                  color: Colors.black),],),),
          _buildShareActions()
        ]));

  Widget _buildShareActions() => Expanded(
    flex: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Fields.constrainedText(S.current.labelCopyLink,
          flex: 0,
          fontSize: Dimensions.fontMicro,
          fontWeight: FontWeight.normal,
          color: Constants.inputLabelForeColor),
        Fields.actionIcon(
          const Icon(Icons.content_copy_rounded),
          size: Dimensions.sizeIconSmall,
          color: Theme.of(context).primaryColor,
          onPressed: _shareToken != null ? () async {
            await copyStringToClipboard(_shareToken!);
            showSnackBar(context,
                content: Text(S.current.messageTokenCopiedToClipboard));
          } : null,
        ),
        Fields.constrainedText(S.current.labelShareLink,
          flex: 0,
          fontSize: Dimensions.fontMicro,
          fontWeight: FontWeight.normal,
          color: Constants.inputLabelForeColor),
        Fields.actionIcon(
          const Icon(Icons.share_outlined),
          size: Dimensions.sizeIconSmall,
          color: Theme.of(context).primaryColor,
          onPressed: _shareToken != null ? () => Share.share(_shareToken!) : null,
        )
      ]));
}
