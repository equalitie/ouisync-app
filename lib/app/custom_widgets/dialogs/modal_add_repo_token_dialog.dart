import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../cubit/cubits.dart';
import '../../utils/utils.dart';

class AddRepositoryWithToken extends StatefulWidget {
  const AddRepositoryWithToken({
    Key? key,
    required this.context,
    required this.cubit,
    required this.formKey
  }) : super(key: key);

  final BuildContext context;
  final RepositoriesCubit cubit;
  final GlobalKey<FormState> formKey;

  @override
  State<AddRepositoryWithToken> createState() => _AddRepositoryWithTokenState();
}

class _AddRepositoryWithTokenState extends State<AddRepositoryWithToken> {
  String _suggestedName = '';
  String? _repoName;
  bool _showSuggestedName = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: this.widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16.0))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCreateFolderWidget(this.widget.context),
          ],
        ),
      )
    );
  }

  Widget _buildCreateFolderWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildEntry(
            context: context,
            label: 'Repository token: ',
            hint: 'Paste the token here',
            onSaved: (value) {},
            validator: _repositoryTokenValidator,
            autofocus: true
          ),
          SizedBox(height: 20.0,),
          buildEntry(
            context: context,
            label: 'Repository name: ',
            hint: 'Give the repo a name',
            onSaved: (value) => _onSaved(widget.cubit, value),
            validator: formNameValidator,
            // onTap: () {
            //   if (_suggestedName.isNotEmpty) {
            //     _repoName = _suggestedName;
            //     setState(() { _showSuggestedName = true; });
            //   }
            // }
          ),
          Visibility(
            visible: _showSuggestedName,
            child: Row(
              children: [
                buildConstrainedText('Suggested: $_repoName'),
                ElevatedButton(
                  onPressed: () {
                    
                  },
                  child: Text('Use')
                )
              ],
            )
          ),
          buildActionsSection(context, _actions(context)),
        ]
      )
    );
  }

  String? _repositoryTokenValidator(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please enter a token';
    }

    try {
      _suggestedName = this.widget.cubit.session.extractSuggestedNameFromShareToken(value!);
    } catch (e) {
      _suggestedName = '';
      return 'Please enter a valid token';
    }

    return null;
  }

  void _onSaved(RepositoriesCubit cubit, newRepositoryName) {
    cubit.openRepository(newRepositoryName);

    Navigator.of(this.widget.context).pop(newRepositoryName);
  }

  List<Widget> _actions(context) => [
    ElevatedButton(
      onPressed: () {
        if (this.widget.formKey.currentState!.validate()) {
            this.widget.formKey.currentState!.save();
          }
      },
      child: Text('Create')
    ),
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: () => Navigator.of(context).pop(''),
      child: Text('Cancel')
    ),
  ];
}