import 'dart:async';
import 'dart:io' as io;

import 'package:ouisync/ouisync.dart';
import 'package:shelf/shelf.dart';

import 'utils.dart';

Handler createStaticFileHandler(
  String fileHandle,
  String? contentType,
  Future<File> Function(String path) openFile,
  Cipher pathCipher,
) {
  return (request) {
    return _handleFile(
      request,
      fileHandle,
      () => contentType,
      openFile,
      pathCipher,
    );
  };
}

Future<Response> _handleFile(
  Request request,
  String handle,
  FutureOr<String>? Function() getContentType,
  Future<File> Function(String path) openFile,
  Cipher pathCipher,
) async {
  final contentType = await getContentType();
  final headers = {
    io.HttpHeaders.acceptRangesHeader: 'bytes',
    if (contentType != null) io.HttpHeaders.contentTypeHeader: contentType,
  };

  final queryParameters = request.url.queryParameters;
  if (!queryParameters.containsKey(Constants.fileServerHandleQuery)) {
    return Response.badRequest(body: '\n\nFile handle is missing');
  }

  final handle = queryParameters[Constants.fileServerHandleQuery];
  if (handle == null) {
    return Response.notFound('\n\nFile not found for handle');
  }

  final filePath = await pathCipher.decrypt(handle);

  if (filePath == null) {
    return Response.notFound('\n\nFailed to decrypt path');
  }

  final file = await openFile(filePath);
  final fileSize = await file.length;

  return Response.ok(
      request.method == 'HEAD' ? null : file.read(0, fileSize).asStream(),
      headers: headers..[io.HttpHeaders.contentLengthHeader] = '$fileSize');
}
