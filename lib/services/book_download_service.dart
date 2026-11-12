import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/book_catalog.dart';

class BookDownloadService {
  BookDownloadService({
    Dio? client,
    Future<Directory> Function()? directoryProvider,
  })  : _client = client ?? Dio(),
        _directoryProvider =
            directoryProvider ?? getApplicationDocumentsDirectory;

  final Dio _client;
  final Future<Directory> Function() _directoryProvider;

  Future<File?> getDownloadedFile(BookItem book, BookVolume volume) async {
    final file = await _fileFor(book, volume);
    if (!await file.exists()) return null;
    if (await _isPdf(file)) return file;
    await file.delete();
    return null;
  }

  Future<File> download(
    BookItem book,
    BookVolume volume, {
    void Function(int received, int total)? onProgress,
  }) async {
    final destination = await _fileFor(book, volume);
    final existing = await getDownloadedFile(book, volume);
    if (existing != null) return existing;

    await destination.parent.create(recursive: true);
    final response = await _client.download(
      volume.downloadUrl.toString(),
      destination.path,
      onReceiveProgress: onProgress,
      deleteOnError: true,
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status == 200,
      ),
    );
    if (response.statusCode != 200 || !await _isPdf(destination)) {
      if (await destination.exists()) await destination.delete();
      throw const FormatException(
        'The downloaded file is not a valid PDF from Internet Archive.',
      );
    }
    return destination;
  }

  Future<void> open(File file) async {
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw FileSystemException(
        result.message.isEmpty
            ? 'No PDF reader could open the book.'
            : result.message,
        file.path,
      );
    }
  }

  Future<File> _fileFor(BookItem book, BookVolume volume) async {
    final documentsDirectory = await _directoryProvider();
    final safeBookId = _safeName(book.id);
    final safeFileName = _safeName(volume.fileName);
    return File(
      '${documentsDirectory.path}${Platform.pathSeparator}books'
      '${Platform.pathSeparator}$safeBookId-${volume.number}-$safeFileName',
    );
  }

  Future<bool> _isPdf(File file) async {
    if (!await file.exists() || await file.length() < 5) return false;
    final handle = await file.open(mode: FileMode.read);
    try {
      final signature = await handle.read(5);
      return ascii.decode(signature, allowInvalid: true) == '%PDF-';
    } finally {
      await handle.close();
    }
  }

  String _safeName(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }
}
