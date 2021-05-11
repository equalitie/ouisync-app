import 'package:meta/meta.dart';

import '../models/models.dart';

abstract class BasicResult<T> {
  BasicResult({
    @required this.functionName,
    @required this.result,
  }) :
  assert (functionName != null),
  assert (functionName != ''),
  assert (result != null);

  final String functionName;
  final T result;

  String errorMessage = '';
}

class CreateFolderResult extends BasicResult {
  CreateFolderResult({
    @required this.functionName,
    @required this.result,
  }) :
  super(functionName: functionName, result: result);

  final String functionName;
  final bool result;
}

class CreateFileResult extends BasicResult {
  CreateFileResult({
    @required this.functionName,
    @required this.result,
  }) :
  super(functionName: functionName, result: result);

  final String functionName;
  final String result;
}

class WriteFileResult extends BasicResult {
  WriteFileResult({
    @required this.functionName,
    @required this.result,
  }) :
  super(functionName: functionName, result: result);

  final String functionName;
  final int result;
}

class GetContentResult extends BasicResult {
  GetContentResult({
    @required this.functionName,
    @required this.result,
  }) :
  super(functionName: functionName, result: result);

  final String functionName;
  final List<BaseItem> result;
}