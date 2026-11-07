import 'dart:convert';

import 'package:http/http.dart' as http;

dynamic decodeUtf8JsonResponse(http.Response response) {
  return json.decode(utf8.decode(response.bodyBytes));
}
