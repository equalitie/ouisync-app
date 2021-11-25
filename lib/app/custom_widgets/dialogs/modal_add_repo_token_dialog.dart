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

  TextEditingController _textEditingController = TextEditingController(text: null);

  String _suggestedName = '';
  bool _showSuggestedName = false;

  String? _repoName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: this.widget.formKey,
      autovalidateMode: AutovalidateMode.disabled,
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
            autofocus: true,
            onChanged: (value) {
              if (value.isEmpty) {
                return;
              }

              bool showSuggestedNameSection = false;

              try {
                _suggestedName = this.widget.cubit.session
                .extractSuggestedNameFromShareToken(value);  

                if (_suggestedName.isNotEmpty) {
                  _repoName = _suggestedName;
                  showSuggestedNameSection = true;  
                }
              } catch (e) {
                print('Error extracting the repository token:\n${e.toString()}');                

                _suggestedName = '';
                _repoName = '';

                _textEditingController.text = '';

                showSuggestedNameSection = false;

                showToast('The token seems to be invalid.');
              }

              setState(() { _showSuggestedName = showSuggestedNameSection; });
            }
          ),
          SizedBox(height: 20.0,),
          buildEntry(
            context: context,
            textEditingController: _textEditingController,
            label: 'Repository name: ',
            hint: 'Give the repo a name',
            onSaved: (value) => _onSaved(widget.cubit, value),
            validator: formNameValidator,
            autovalidateMode: AutovalidateMode.disabled
          ),
          Visibility(
            visible: _showSuggestedName,
            child: GestureDetector(
              onTap: () {
                _textEditingController.text = _suggestedName;
              },
              child: buildConstrainedText(
                'Suggested: $_repoName\n(tap for using this name)',
                size: 15.0,
                fontWeight: FontWeight.normal,
                color: Colors.black54
              ),
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