import 'package:async/async.dart';
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
    Key? key
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
    AccessMode.write: S.current.messageWriteReplicaExplanation
  };

  bool _isDisabledMessageVisible = false;
  String _dissabledMessage = '';

  RestartableTimer? _timer;

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
              currentAccessMode: widget.repository.accessMode,
              availableAccessMode: widget.availableAccessModes,
              onChanged: _onChanged,
              onDisabledMessage: _setDisabledMessageVisibility,),
            Dimensions.spacingVerticalHalf,
            _buildAccessModeDescription(_accessMode),
            Dimensions.spacingVerticalDouble,
            _buildShareBox(),
            _buildNotAvailableMessage(),
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
        _displayToken = Constants.ouisyncUrl;
      });

      return;
    }

    final token = await createShareToken(widget.repository, accessMode);
    final displayToken = formatShareLinkForDisplay(token);
    setState(() {
      _accessMode = accessMode;

      _shareToken = token;
      _displayToken = displayToken;
    });
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
      padding: Dimensions.paddingItemBoxLoose,
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
                  _displayToken ?? Constants.ouisyncUrl,
                  flex: 0,
                  softWrap: true,
                  maxLines: 2,
                  textOverflow: TextOverflow.fade,
                  color: _shareToken != null ? Colors.black : Colors.black54),],),),
          _buildShareActions()
        ]));

  Widget _buildShareActions() => Expanded(
    flex: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(children: [
          Fields.actionIcon(
            const Icon(Icons.content_copy_rounded),
            size: Dimensions.sizeIconSmall,
            color: _getActionStateColor(_shareToken != null),
            onPressed: () async {
              if (_shareToken == null) {
                final disabledMessage = S.current.messageShareActionDisabled;
                _setDisabledMessageVisibility(
                  true,
                  disabledMessage,
                  Constants.notAvailableActionMessageDuration);

                return;
              }

              await copyStringToClipboard(_shareToken!);
              showSnackBar(context,
                  content: Text(S.current.messageTokenCopiedToClipboard));
            }),
          Fields.constrainedText(S.current.labelCopyLink,
            flex: 0,
            fontSize: Dimensions.fontMicro,
            fontWeight: FontWeight.normal,
            color: Constants.inputLabelForeColor),
        ]),
        Column(children: [
          Fields.actionIcon(
            const Icon(Icons.share_outlined),
            size: Dimensions.sizeIconSmall,
            color: _getActionStateColor(_shareToken != null),
            onPressed: () async {
              if (_shareToken == null) {
                final disabledMessage = S.current.messageShareActionDisabled;
                _setDisabledMessageVisibility(
                  true,
                  disabledMessage,
                  Constants.notAvailableActionMessageDuration);

                return;
              }

              await Share.share(_shareToken!);
            }),
          Fields.constrainedText(S.current.labelShareLink,
            flex: 0,
            fontSize: Dimensions.fontMicro,
            fontWeight: FontWeight.normal,
            color: Constants.inputLabelForeColor),
        ]),
        Column(children: [
          Fields.actionIcon(
            const Icon(Icons.qr_code_2_outlined),
            size: Dimensions.sizeIconSmall,
            color: _getActionStateColor(_shareToken != null),
            onPressed: () async {
              if (_shareToken == null) {
                final disabledMessage = S.current.messageShareActionDisabled;
                _setDisabledMessageVisibility(
                  true,
                  disabledMessage,
                  Constants.notAvailableActionMessageDuration);

                return;
              }

              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return RepositoryQRPage(shareLink: _shareToken!,);
                }));
            }),
          Fields.constrainedText(S.current.labelQRCode,
            flex: 0,
            fontSize: Dimensions.fontMicro,
            fontWeight: FontWeight.normal,
            color: Constants.inputLabelForeColor),
        ],)
      ]));

  Color _getActionStateColor(bool isEnabled) {
    if (isEnabled) {
      return Theme.of(context).primaryColor;
    }

    return Colors.grey;
  }

  Widget  _buildNotAvailableMessage() {
    return Visibility(
    visible: _isDisabledMessageVisible,
    child: GestureDetector(
      onTap: () => _setDisabledMessageVisibility(false, '', 0),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded( 
              child:Text(_dissabledMessage,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: Dimensions.fontSmall,
                  color: Colors.red.shade400
                )))
          ]))));
  }

  void _setDisabledMessageVisibility(bool visible, String message, int duration) {
    _dissabledMessage = visible
      ? message
      : '';

    setState(() => _isDisabledMessageVisible = visible);

    if (!_isDisabledMessageVisible) {
      _timer?.cancel();
      return;
    }

    if (duration > 0) {
      _timer ??= RestartableTimer(
        Duration(seconds: duration),
        () =>
        setState(() => _isDisabledMessageVisible = false));

      _timer?.reset();
    }
  }
}