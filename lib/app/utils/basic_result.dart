import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../models/models.dart';

abstract class BasicResult<T> {
  BasicResult({
    required this.functionName,
    required this.result,
  }) :
  assert (functionName != '');

  final String functionName;
  final T? result;

  String errorMessage = '';
}

class CreateFolderResult extends BasicResult {
  CreateFolderResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final bool result;
}

class CreateFileResult extends BasicResult {
  CreateFileResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final File? result;
}

class WriteFileResult extends BasicResult {
  WriteFileResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final File? result;
}

class   GetContentResult extends BasicResult {
  GetContentResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final List<BaseItem> result;
}

class GetContentRecursiveResult extends BasicResult {
  GetContentRecursiveResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final List<Node> result;
}

class GetFullContentResult extends BasicResult {
  GetFullContentResult({
    required this.functionName,
    required this.result
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final Node result;
}

class ReadFileResult extends BasicResult {
  ReadFileResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final List<int> result;
}