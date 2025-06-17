import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locale_names/locale_names.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show LocaleCubit;
import '../utils/utils.dart' show ClickCounter, Dimensions;
import '../widgets/widgets.dart'
    show ContentWithStickyFooterState, DirectionalAppBar;

class LanguagePicker extends StatelessWidget {
  LanguagePicker({
    required this.localeCubit,
    required this.canPop,
    this.onSelect,
  }) : exitClickCounter = ClickCounter(timeoutMs: 3000);

  final LocaleCubit localeCubit;
  final bool canPop;
  final ClickCounter exitClickCounter;
  final void Function()? onSelect;

  Locale? get deviceLocale => localeCubit.deviceLocale;
  Locale get currentLocale => localeCubit.currentLocale;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: DirectionalAppBar(
        title: Text(S.current.titleApplicationLanguage),
        automaticallyImplyLeading: canPop,
      ),
      body: PopScope<Object?>(
        canPop: canPop,
        onPopInvokedWithResult:
            (bool didPop, Object? result) =>
                _onBackPressed(context, didPop, result),
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

  Future<void> _onBackPressed(
    BuildContext context,
    bool didPop,
    Object? result,
  ) async {
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
    final localeItems = _getLocaleItems();

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

              final selectionColor =
                  item.isCurrent
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null;

              final title = StringBuffer(item.locale.nativeDisplayLanguage);

              final subtitle = StringBuffer(item.locale.defaultDisplayLanguage);
              if (item.isDevice) {
                subtitle.write(' (${S.current.languageOfTheDevice})');
              }

              return ListTile(
                tileColor: selectionColor,
                title: Text(title.toString()),
                subtitle: Text(subtitle.toString()),
                trailing: Text(item.locale.countryCode ?? ''),
                onTap: () async {
                  await localeCubit.changeLocale(item.locale);
                  await S.delegate.load(item.locale);

                  if (onSelect != null) onSelect!();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<LocaleItem> _getLocaleItems() {
    final localeItems = <LocaleItem>[];

    localeItems.addAll(
      S.delegate.supportedLocales.map((l) {
        return LocaleItem(
          locale: l,
          isDevice: l == localeCubit.deviceLocale,
          isCurrent: l == localeCubit.currentLocale,
        );
      }),
    );

    localeItems.sort();

    return localeItems;
  }
}

class LocaleItem implements Comparable<LocaleItem> {
  LocaleItem({
    required this.locale,
    required this.isDevice,
    required this.isCurrent,
  });

  final Locale locale;

  final bool isDevice;
  final bool isCurrent;

  @override
  int compareTo(LocaleItem other) {
    // We want current to be the smallest one (at the top).
    if (isCurrent != other.isCurrent) {
      return isCurrent ? -1 : 1;
    }
    return locale.defaultDisplayLanguage.compareTo(
      other.locale.defaultDisplayLanguage,
    );
  }
}
