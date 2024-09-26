import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ouisync_app/app/widgets/widgets.dart';

import '../../generated/l10n.dart';
import '../utils/click_counter.dart';
import '../utils/utils.dart';

class LanguagePicker extends StatefulWidget {
  const LanguagePicker({required this.settings, super.key});

  final Settings settings;

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  int selected = -1;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: PopScope<Object?>(
            canPop: false,
            onPopInvokedWithResult: _onBackPressed,
            child: ContentWithStickyFooterState(
              content: _buildContent(context),
              footer: SizedBox.shrink(),
            ),
          ),
        ),
      );

  Future<void> _onBackPressed(bool didPop, Object? result) async {
    if (didPop) return;

    int clickCount = exitClickCounter.registerClick();
    if (clickCount <= 1) {
      final snackBar = SnackBar(
        content: Text(S.current.messageExitOuiSync),
        showCloseIcon: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      exitClickCounter.reset();
      exit(0);
    }
  }

  Column _buildContent(BuildContext context) {
    final locales = S.delegate.supportedLocales;

    if (selected < 0) {
      setState(() => selected = locales.indexOf(Locale('en'), 0));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(S.current.actionAccept),
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: locales.length,
            itemBuilder: (context, index) {
              final locale = locales[index].languageCode;
              final countryCode = locales[index].countryCode ?? '';

              final selectionColor = index == selected ? Colors.blue : null;
              return ListTile(
                tileColor: selectionColor,
                title: Text(countryCode),
                subtitle: Text(locale),
                onTap: () async {
                  final selectedLocale = S.delegate.supportedLocales[index];
                  await S.delegate.load(selectedLocale);
                  Navigator.of(context).pop(selectedLocale);
                  // await widget.settings
                  //     .setLanguageLocale(selectedLocale.languageCode);
                  // setState(() => selected = index);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
