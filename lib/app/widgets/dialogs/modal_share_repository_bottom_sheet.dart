import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/l10n.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../../cubits/repo/cubit.dart';
import '../selectors/access_mode_dropddown_menu.dart';
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

class _ShareRepositoryState extends State<ShareRepository> with OuiSyncAppLogger {
  final ValueNotifier<AccessMode> _accessMode =
    ValueNotifier<AccessMode>(AccessMode.blind);

  final ValueNotifier<String> _shareToken =
    ValueNotifier<String>(S.current.messageError);

  final Map<AccessMode, String> accessModeDescriptions = {
    AccessMode.blind: S.current.messageBlindReplicaExplanation,
    AccessMode.read: S.current.messageReadReplicaExplanation,
    AccessMode.write: S.current.messageWriteReplicaExplanation
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      initialData: '',
      future: createShareToken(widget.repository, _accessMode.value),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          _shareToken.value = S.current.messageAck;
          return Text(S.current.messageErrorCreatingToken);
        }

        if (snapshot.hasData) {
          _shareToken.value = snapshot.data!;

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
                AccessModeDropDownMenu(
                  accessModes: widget.availableAccessModes,
                  onChanged: _onChanged),
                Dimensions.spacingVerticalHalf,
                _buildAccessModeDescription(),
                Dimensions.spacingVerticalDouble,
                _buildShareBox()
              ]
            ),
          );
        }

        _shareToken.value = S.current.messageCreatingToken;

        return SizedBox(
          height: Dimensions.sizeCircularProgressIndicatorAverage.height,
          width: Dimensions.sizeCircularProgressIndicatorAverage.width,
          child: const CircularProgressIndicator(strokeWidth: Dimensions.strokeCircularProgressIndicatorSmall,)
        );
      }
    );
  }

  Future<String> createShareToken(RepoCubit repo, AccessMode accessMode) async {
    final shareToken = await repo.createShareToken(accessMode);
    
    if (kDebugMode) { // Print this only while debugging, tokens are secrets that shouldn't be logged otherwise.
      loggy.app('Token for sharing repository ${repo.name}: $shareToken (${accessMode.name})');
    }

    return shareToken.token;
  }

  Future<void> _onChanged(AccessMode accessMode) async {
    _accessMode.value = accessMode;
    final token = await createShareToken(widget.repository, accessMode);
    _shareToken.value = token;
  }

  Widget _buildAccessModeDescription() =>
    ValueListenableBuilder(
      valueListenable: _accessMode,
      builder:(context, accessMode, child) =>
        Padding(
          padding: Dimensions.paddingItem,
          child: Row(children: [Fields.constrainedText(
            _tokenDescription(accessMode as AccessMode),
            flex: 0,
            fontSize: Dimensions.fontMicro,
            fontWeight: FontWeight.normal,
            color: Colors.black54
          )]))
    );
  
  String _tokenDescription(AccessMode accessMode) => 
    accessModeDescriptions.values.elementAt(accessMode.index);

  Widget _buildShareBox() => Container(
    padding: Dimensions.paddingItemBox,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
      color: Constants.inputBackgroundColor
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Fields.constrainedText(
                    S.current.labelShareLink,
                    flex:0,
                    fontSize: Dimensions.fontMicro,
                    fontWeight: FontWeight.normal,
                    color: Constants.inputLabelForeColor),
                  ValueListenableBuilder(
                      valueListenable: _shareToken,
                      builder:(context, value, child) =>
                        LimitedBox(
                          maxWidth: 190.0, // TODO: Find how to do it without a fixed value
                          child: Row(
                            children: [
                              Fields.constrainedText(
                                value as String,
                                softWrap: false,
                                textOverflow: TextOverflow.fade,
                                color: Colors.black)
                            ],
                          )))
                  
                ])
            ])),
        Expanded(
          flex: 0,
          child: Row(
            children: [
              Fields.actionIcon(
                const Icon(Icons.content_copy_rounded),
                size: Dimensions.sizeIconSmall,
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  await copyStringToClipboard(_shareToken.value);
                  showSnackBar(context, content: Text(S.current.messageTokenCopiedToClipboard)) ;
                },),
              Fields.actionIcon(
                const Icon(Icons.share_outlined),
                size: Dimensions.sizeIconSmall,
                color: Theme.of(context).primaryColor,
                onPressed: () => Share.share(_shareToken.value),)
            ]))
      ],
    ));
}
