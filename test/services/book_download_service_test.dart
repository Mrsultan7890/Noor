import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/models/book_catalog.dart';
import 'package:noor/services/book_download_service.dart';

class _StaticHttpAdapter implements HttpClientAdapter {
  _StaticHttpAdapter(this.bytes);

  final List<int> bytes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentLengthHeader: ['${bytes.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<BookCatalog> _loadCatalog() async {
  final json = jsonDecode(await rootBundle.loadString('data/books.json'))
      as Map<String, dynamic>;
  return BookCatalog.fromJson(json);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('downloads PDF data to the app books directory', () async {
    final catalog = await _loadCatalog();
    final book = catalog.books.first;
    final volume = book.volumes.first;
    final tempDirectory = await Directory.systemTemp.createTemp('noor-books-');
    addTearDown(() => tempDirectory.delete(recursive: true));

    final dio = Dio()
      ..httpClientAdapter = _StaticHttpAdapter(ascii.encode('%PDF-1.7\n'));
    final service = BookDownloadService(
      client: dio,
      directoryProvider: () async => tempDirectory,
    );

    final file = await service.download(book, volume);

    expect(await file.exists(), isTrue);
    expect(await file.readAsString(), '%PDF-1.7\n');
    expect(
      (await service.getDownloadedFile(book, volume))?.path,
      file.path,
    );
  });

  test('rejects and removes a non-PDF response', () async {
    final catalog = await _loadCatalog();
    final book = catalog.books.first;
    final volume = book.volumes.first;
    final tempDirectory = await Directory.systemTemp.createTemp('noor-books-');
    addTearDown(() => tempDirectory.delete(recursive: true));

    final dio = Dio()
      ..httpClientAdapter =
          _StaticHttpAdapter(ascii.encode('<html>no PDF</html>'));
    final service = BookDownloadService(
      client: dio,
      directoryProvider: () async => tempDirectory,
    );

    await expectLater(
      service.download(book, volume),
      throwsFormatException,
    );
    expect(
      await tempDirectory
          .list(recursive: true)
          .where((entity) => entity is File)
          .length,
      0,
    );
  });
}
