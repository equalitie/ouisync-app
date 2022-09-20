import 'package:async/async.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class EntryAction extends StatefulWidget {
  const EntryAction({
    this.iconData,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabledValidation,
    this.disabledMessage,
    this.disabledMessageDuration = 0,
    this.contentPadding = EdgeInsets.zero,
    this.dense,
    this.visualDensity,
    this.minLeadingWidth = 20.0,
    this.textAlign = TextAlign.start,
    this.textOverflow = TextOverflow.ellipsis,
    this.textSoftWrap = true,
    this.textFontSize = Dimensions.fontAverage,
    this.textFontWeight = FontWeight.normal,
    this.textColor = Colors.black,
    Key? key}) : super(key: key);

  final IconData? iconData;
  final String title;
  final String? subtitle;
  final void Function()? onTap;
  final bool Function()? enabledValidation;
  final String? disabledMessage;
  final int disabledMessageDuration;
  final bool? dense;
  final VisualDensity? visualDensity;
  final double minLeadingWidth;
  final EdgeInsets contentPadding;
  final TextAlign textAlign;
  final TextOverflow textOverflow;
  final bool textSoftWrap;
  final double textFontSize;
  final FontWeight textFontWeight;
  final Color textColor;

  @override
  State<EntryAction> createState() => _EntryActionState();
}

class _EntryActionState extends State<EntryAction> {
  bool _enabled = true;
  Color? _itemColor;
  
  String? _message = '';
  bool _disabledMessageVisibility = false;
  Duration? _duration = const Duration(seconds: 0);

  RestartableTimer? _timer;

  @override
  void initState() {
    _validateEnabledState();
    super.initState();
  }

  void _validateEnabledState({bool init = true}) {
    final isEnabled = widget.enabledValidation?.call() ?? true; 
    
    setState(() {
      _enabled = isEnabled;
    
      _itemColor = isEnabled
        ? widget.textColor
        : Colors.grey;
      
      if (!init) {
        _message = widget.disabledMessage;
        _disabledMessageVisibility =!isEnabled;
        _duration = Duration(seconds: widget.disabledMessageDuration);

        if (_disabledMessageVisibility) {
          if (widget.disabledMessageDuration > 0) {
            _timer ??= RestartableTimer(
              _duration!,
              () =>
              setState(() => _disabledMessageVisibility = false));

            _timer?.reset();
          }
        }
      }
    });
  }

  void _hideDisabledMessage() =>
    setState(() {
      _disabledMessageVisibility = false;
      _timer?.cancel();});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(child: ListTile(
          contentPadding: widget.contentPadding,
          dense: widget.dense,
          visualDensity: widget.visualDensity,
          minLeadingWidth: widget.minLeadingWidth,
          leading: widget.iconData != null
            ? Icon(widget.iconData,
              color: _itemColor)
            : null,
          title: Text(widget.title,
            textAlign: widget.textAlign,
            softWrap: widget.textSoftWrap,
            overflow: widget.textOverflow,
            style: TextStyle(
              fontSize: widget.textFontSize,
              fontWeight: widget.textFontWeight,
              color: _itemColor
            )
          ),
          subtitle: widget.subtitle != null 
            ? Text(widget.subtitle!)
            : null,
        ),
        onTap: () {
          if (!_enabled) {
            _validateEnabledState(init: false);
            return;
          }

          widget.onTap!.call();
        },),
        Visibility(
          visible: _disabledMessageVisibility,
          child: GestureDetector(
            onTap: _hideDisabledMessage,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded( 
                    child:Text(_message ?? '',
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: Dimensions.fontSmall,
                        color: Colors.red.shade400
                      )))
                ])))),
      ],);
  }
}