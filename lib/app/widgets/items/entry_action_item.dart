import 'package:async/async.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart' show Constants, AppTypography;

enum EntryAction { delete, download, copy, move, preview, rename, share }

class EntryActionItem extends StatefulWidget {
  const EntryActionItem({
    this.iconData,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabledValidation,
    this.disabledMessage,
    this.disabledMessageDuration = 0,
    this.contentPadding = EdgeInsetsDirectional.zero,
    this.dense = true,
    this.visualDensity = VisualDensity.compact,
    this.minLeadingWidth = 20.0,
    this.textAlign = TextAlign.start,
    this.textOverflow = TextOverflow.ellipsis,
    this.textSoftWrap = true,
    this.titleTextStyle = AppTypography.bodyMedium,
    this.subtitleTextStyle = AppTypography.bodySmall,
    this.isDanger = false,
    super.key,
  });

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
  final EdgeInsetsDirectional contentPadding;
  final TextAlign textAlign;
  final TextOverflow textOverflow;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final bool textSoftWrap;
  final bool isDanger;

  @override
  State<EntryActionItem> createState() => _EntryActionItemState();
}

class _EntryActionItemState extends State<EntryActionItem> {
  bool _enabled = true;
  Color? _itemColor;

  String? _message = '';
  bool _isDisabledMessageVisible = false;
  Duration? _duration = const Duration(seconds: 0);

  RestartableTimer? _timer;

  TextStyle? bodySmallStyle;

  @override
  void initState() {
    _validateEnabledState();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _validateEnabledState({bool init = true}) {
    final isEnabled = widget.enabledValidation?.call() ?? true;

    setState(() {
      _enabled = isEnabled;
      _itemColor =
          isEnabled
              ? widget.isDanger
                  ? Constants.dangerColor
                  : Colors.black
              : Colors.grey;

      if (!init) {
        _message = widget.disabledMessage;
        _isDisabledMessageVisible = !isEnabled;

        if (!_isDisabledMessageVisible) {
          _timer?.cancel();
        }

        if (widget.disabledMessageDuration > 0) {
          _duration = Duration(seconds: widget.disabledMessageDuration);
          _timer ??= RestartableTimer(
            _duration!,
            () => setState(() => _isDisabledMessageVisible = false),
          );

          _timer?.reset();
        }
      }
    });
  }

  void _hideDisabledMessage() => setState(() {
    _isDisabledMessageVisible = false;
    _timer?.cancel();
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        child: ListTile(
          contentPadding: widget.contentPadding,
          dense: widget.dense,
          visualDensity: widget.visualDensity,
          minLeadingWidth: widget.minLeadingWidth,
          leading:
              widget.iconData != null
                  ? Icon(widget.iconData, color: _itemColor)
                  : null,
          title: Text(
            widget.title,
            textAlign: widget.textAlign,
            softWrap: widget.textSoftWrap,
            overflow: widget.textOverflow,
            style: widget.titleTextStyle?.copyWith(color: _itemColor),
          ),
          subtitle:
              widget.subtitle != null
                  ? Text(
                    widget.subtitle!,
                    style: widget.subtitleTextStyle?.copyWith(
                      color: _itemColor,
                    ),
                  )
                  : null,
        ),
        onTap: () {
          if (widget.onTap == null) return;

          if (!_enabled) {
            _validateEnabledState(init: false);
            return;
          }

          widget.onTap!();
        },
      ),
      Visibility(
        visible: _isDisabledMessageVisible,
        child: GestureDetector(
          onTap: _hideDisabledMessage,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 20.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    _message ?? '',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    style: widget.titleTextStyle?.copyWith(
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
