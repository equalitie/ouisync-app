import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'utils.dart';

abstract class FileServer with AppLogger {
  static final _random = Random.secure();
  static final _defaultMimeTypeResolver = MimeTypeResolver();

  static final fileHandles = <String, String>{};

  static Future<io.HttpServer> initServer(
    Object address,
    int port, {
    io.SecurityContext? securityContext,
    int? backlog,
    bool shared = true
  }) async {
    backlog ??= 0;
    final server = await (securityContext == null
      ? io.HttpServer.bind(address, port, backlog: backlog, shared: shared)
      : io.HttpServer.bindSecure(
          address,
          port,
          securityContext,
          backlog: backlog,
          shared: shared,
        ));

    server.autoCompress = true;
    return server;
  }

  static Handler createFileHandler(({String handle, String? mimeType}) handleInfo, Future<File> Function(String path) openFile) {
    return (request) {
      return _handleFile(request, handleInfo.handle, () => handleInfo.mimeType, openFile);
    };
  }

  static ({String handle, String? mimeType}) getFileHandleInfoForPath(String path) {
    final encodedHandle = _getRandomHandler();
    fileHandles.putIfAbsent(encodedHandle, () => path);

    final mimeType = _defaultMimeTypeResolver.lookup(path);

    return (handle: encodedHandle, mimeType: mimeType);
  }

  static String _getRandomHandler({int length = 32}) {
    final values = List<int>.generate(length, (index) => _random.nextInt(256));

    final randomHandler = base64UrlEncode(values);
    return randomHandler;
  }

  static Future<Response> _handleFile(Request request, String handle, FutureOr<String>? Function() getContentType, Future<File> Function(String path) openFile) async {
    final contentType = await getContentType();
    final headers = {
      io.HttpHeaders.acceptRangesHeader: 'bytes',
      if (contentType != null) io.HttpHeaders.contentTypeHeader: contentType,
    };

    final queryParameters = request.url.queryParameters; 
    if (!queryParameters.containsKey(Constants.fileServerHandleQuery)) {
      return Response.badRequest(body: 'File preview: query parameter missing');
    }

    final handle = queryParameters[Constants.fileServerHandleQuery];
    final filePath = fileHandles[handle];
    if (handle == null || filePath == null) {
      return Response.notFound('File preview: file not found');
    }

    final file = await openFile(filePath);
    final size = await file.length;

    return Response.ok(
      request.method == 'HEAD' ? null : file.read(0, size).asStream(),
      headers: headers..[io.HttpHeaders.contentLengthHeader] = '$size'
    );
  }

  static void serveFileRequest(io.HttpServer server, Handler handler, {String poweredByHeader = 'Ouisync using package:shelf'}) => serveRequests(server, handler, poweredByHeader: poweredByHeader);
}