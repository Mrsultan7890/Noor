import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:noor/services/utf8_json.dart';

void main() {
  test('decodes UTF-8 Arabic JSON even when the response charset is wrong', () {
    final response = http.Response.bytes(
      utf8.encode('{"name":"سورة الفاتحة"}'),
      200,
      headers: {'content-type': 'application/json; charset=iso-8859-1'},
    );

    final decoded = decodeUtf8JsonResponse(response) as Map<String, dynamic>;

    expect(decoded['name'], 'سورة الفاتحة');
  });
}
