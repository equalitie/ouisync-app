import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:locale_names/locale_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n.dart';
import '../utils/click_counter.dart';
import '../utils/utils.dart';
import '../cubits/locale.dart';
import '../widgets/widgets.dart';

class LanguagePicker extends StatelessWidget {
  LanguagePicker({required this.localeCubit, required this.canPop})
      : exitClickCounter = ClickCounter(timeoutMs: 3000);

  final LocaleCubit localeCubit;
  final bool canPop;
  final ClickCounter exitClickCounter;

  Locale? get deviceLocale => localeCubit.deviceLocale;
  Locale get currentLocale => localeCubit.currentLocale;

  @override
  Widget build(BuildContext context) => BlocBuilder<LocaleCubit, LocaleState>(
      bloc: localeCubit,
      builder: (context, localeState) => SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(S.current.titleApplicationLanguage),
                automaticallyImplyLeading: canPop,
              ),
              body: PopScope<Object?>(
                canPop: canPop,
                onPopInvokedWithResult: (bool didPop, Object? result) =>
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
          ));

  Future<void> _onBackPressed(
      BuildContext context, bool didPop, Object? result) async {
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

              final selectionColor = item.isCurrent
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null;

              final title = StringBuffer(item.locale.nativeDisplayLanguage);

              final subtitle = StringBuffer(item.locale.defaultDisplayLanguage);
              if (item.isDevice)
                subtitle.write(' (${S.current.languageOfTheDevice})');

              return ListTile(
                  tileColor: selectionColor,
                  title: Text(title.toString()),
                  subtitle: Text(subtitle.toString()),
                  trailing: Text(item.locale.countryCode ?? ''),
                  onTap: () async {
                    Navigator.of(context).pop(item.locale);
                  });
            },
          ),
        ),
      ],
    );
  }

  List<LocaleItem> _getLocaleItems() {
    final localeItems = <LocaleItem>[];

    localeItems.addAll(S.delegate.supportedLocales.map((l) {
      return LocaleItem(
        locale: l,
        isDevice: l == localeCubit.deviceLocale,
        isCurrent: l == localeCubit.currentLocale,
      );
    }));

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
    return locale.defaultDisplayLanguage
        .compareTo(other.locale.defaultDisplayLanguage);
  }
}
