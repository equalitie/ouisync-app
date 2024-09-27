import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locale_names/locale_names.dart';

import '../../generated/l10n.dart';
import '../utils/click_counter.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class LanguagePicker extends StatefulWidget {
  const LanguagePicker({required this.canPop});

  final bool canPop;

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  int selected = -1;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('App language'),
            automaticallyImplyLeading: widget.canPop,
          ),
          body: PopScope<Object?>(
            canPop: false,
            onPopInvokedWithResult: _onBackPressed,
            child: Padding(
              padding: Dimensions.paddingActionBox,
              child: ContentWithStickyFooterState(
                content: _buildContent(context),
                footer: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

  Future<void> _onBackPressed(bool didPop, Object? result) async {
    if (didPop) return;

    if (widget.canPop) {};

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
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: locales.length,
            itemBuilder: (context, index) {
              final languageCode = locales[index].languageCode;
              final countryCode = locales[index].countryCode;
              final localeName = Locale.fromSubtags(
                languageCode: languageCode,
                countryCode: countryCode,
              );

              final selectionColor = index == selected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null;
              return ListTile(
                tileColor: selectionColor,
                title: Text(localeName.nativeDisplayLanguageScript),
                subtitle: Text(localeName.defaultDisplayLanguage),
                trailing: Text(localeName.countryCode ?? ''),
                onTap: () async {
                  final selectedLocale = S.delegate.supportedLocales[index];
                  Navigator.of(context).pop(selectedLocale);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
