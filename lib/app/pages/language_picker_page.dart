import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class LanguagePickerPage extends StatefulWidget {
  const LanguagePickerPage({
    required this.settings,
    super.key,
  });

  final Settings settings;

  @override
  State<LanguagePickerPage> createState() => _LanguagePickerPageState();
}

class _LanguagePickerPageState extends State<LanguagePickerPage> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ContentWithStickyFooterState(
            content: _buildContent(context),
            footer: Fields.dialogActions(
              context,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              buttons: _buildActions(context),
            ),
          ),
        ),
      );

  Widget _buildContent(BuildContext context) => Expanded(
      flex: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Please select the default language for the app'),
          _buildListOfLanguages(context),
        ],
      ));

  Widget _buildListOfLanguages(BuildContext context) {
    final languages = S.delegate.supportedLocales;
    final languagesCount = languages.length;

    return SingleChildScrollView(
        child: ListView.builder(
      shrinkWrap: true,
      itemCount: languagesCount,
      itemBuilder: (context, index) {
        final locale = languages[index];
        final countryCode = locale.countryCode ?? '-';
        final languageCode = locale.languageCode;
        final languageTag = locale.toLanguageTag();

        return ListTile(
          title: Text(languageCode),
          subtitle: Text(languageTag),
          trailing: Text(countryCode),
        );
      },
    ));
  }

  List<Widget> _buildActions(BuildContext context) => [
        OutlinedButton(onPressed: () {}, child: Text('SKIP')),
        ElevatedButton(
            onPressed: () async {
              await widget.settings.setSelectedAppLanguage(true);
              await widget.settings.setAppLanguage('');
              Navigator.of(context).pop(null);
            },
            autofocus: true,
            child: Text('SELECT'))
      ];
}
