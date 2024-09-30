import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:locale_names/locale_names.dart';

import '../../generated/l10n.dart';
import '../utils/click_counter.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class LanguagePicker extends StatefulWidget {
  const LanguagePicker({required this.languageCodeCurrent, required this.canPop});

  final String? languageCodeCurrent;
  final bool canPop;

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> with AppLogger {
  final exitClickCounter = ClickCounter(timeoutMs: 3000);

  // English (languageCode=en) is the default locale when the device language is not supported.
  Locale deviceLocale = Locale('en');
  Locale deviceLocaleForDisplay = Locale('en');

  String selectedLanguageCode = 'en';

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('App language'),
            automaticallyImplyLeading: widget.canPop,
          ),
          body: PopScope<Object?>(
            canPop: widget.canPop,
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

    _setDeviceLocale(locales);
    final localeItems = _getLocaleItems(locales);

    setState(() =>
      selectedLanguageCode = localeItems.singleWhereOrNull((li) => li.isCurrent)?.locale.languageCode ?? 'en'
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: localeItems.length,
            itemBuilder: (context, index) {
              final item = localeItems[index];

              final languageCode = item.locale.languageCode;
              final countryCode = item.locale.countryCode;
              final localeName = Locale.fromSubtags(
                languageCode: languageCode,
                countryCode: countryCode,
              );

              final selectionColor = !item.isSupported ? Colors.grey.shade200 :
               item.isCurrent
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null;

              final title = StringBuffer(localeName.nativeDisplayLanguageScript);
              if (item.isDefault) title.write(' (default)');
              if (!item.isSupported) title.write(' (not available)');
              
              final subtitle = StringBuffer(localeName.defaultDisplayLanguage);
              if (item.isDevice) subtitle.write(' (device\'s language)');

              return ListTile(
                tileColor: selectionColor,
                title: Text(title.toString()),
                subtitle: Text(subtitle.toString()),
                trailing: Text(localeName.countryCode ?? ''),
                onTap: item.isSupported ? () async {
                  Locale? selectedLocale = S.delegate.supportedLocales.singleWhereOrNull((sl) => sl.languageCode == item.locale.languageCode);
                  assert(selectedLocale != null, 'selectedLocale is Null. The locale: ${item.locale.languageCode}');

                  if (selectedLocale == null) {
                    final errorMessage = 'Something went wrong selecting this language. Using the default language instead: English (en)';
                    showSnackBar(errorMessage, context: context, showCloseIcon: true);

                    selectedLocale = Locale('en');
                  }

                  Navigator.of(context).pop(selectedLocale);
                } : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _setDeviceLocale(List<Locale> locales) {
    final deviceLocaleName = Platform.localeName;
    final underscoreIndex = deviceLocaleName.indexOf('_');
    final baseLanguageCode = underscoreIndex >= 0 ? deviceLocaleName.substring(0, underscoreIndex) : deviceLocaleName;
    final countryCode = underscoreIndex >= 0 ? deviceLocaleName.substring(underscoreIndex).replaceAll('_', '').trim() : null;
    
    setState(() {
      deviceLocale = Locale(baseLanguageCode);
      deviceLocaleForDisplay = Locale(baseLanguageCode, countryCode);
    }); 
  }

  List<LocaleItem> _getLocaleItems(List<Locale> locales) {
    final localeItems = <LocaleItem>[];
    int localeIndex = 0;

    if (!locales.contains(deviceLocale)) {
      localeItems.add(LocaleItem(index: localeIndex, locale: deviceLocale, isDevice: true, isDefault: false, isSupported: false, isCurrent: false,));
      localeIndex++;
    }

    localeItems.addAll(S.delegate.supportedLocales.map((l) { 
      final isDevice = l.languageCode == deviceLocale.languageCode;
      final isDefault = l.languageCode == 'en';
      final isCurrent = _getIsCurrent(l);
      final item = LocaleItem(index: localeIndex, locale: l, isDevice: isDevice, isDefault: isDefault, isSupported: true, isCurrent: isCurrent,);

      localeIndex++;
      return item;
    }));

    return localeItems.sortedBy((li) => li.locale.defaultDisplayLanguage);
  }

  bool _getIsCurrent(Locale locale) {
    if (widget.languageCodeCurrent == null) {
      return false;
    }

    return locale.languageCode == widget.languageCodeCurrent;
  }
}

class LocaleItem extends Equatable {
  LocaleItem({required this.index,
    required this.locale,
    required this.isDevice,
    required this.isDefault,
    required this.isSupported,
    required this.isCurrent,
  });

  final int index;
  final Locale locale;

  final bool isDevice;
  final bool isDefault;
  final bool isSupported;
  final bool isCurrent;

  @override
  List<Object?> get props => [index, locale, isCurrent];

}
