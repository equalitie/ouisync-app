import 'package:ouisync_plugin/ouisync_plugin.dart';

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
  final int result; //File.length
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

class ShareFileResult extends BasicResult {
  ShareFileResult({
    required this.functionName,
    required this.result,
    required this.action
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final List<int> result;
  final String action;
}

class MoveEntryResult extends BasicResult {
  MoveEntryResult({
    required this.functionName,
    required this.result
  }): super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final String result;
}

class DeleteFileResult extends BasicResult {
  DeleteFileResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final String result;
}

class DeleteFolderResult extends BasicResult {
  DeleteFolderResult({
    required this.functionName,
    required this.result,
  }) : super(
    functionName: functionName,
    result: result
  );

  final String functionName;
  final String result;
}
