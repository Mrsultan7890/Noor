import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'utf8_json.dart';

class AuthSessionExpiredException implements Exception {
  const AuthSessionExpiredException();
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://noor.bot-keep.xyz',
  );

  static Uri _endpoint(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final baseUri = Uri.parse(baseUrl);
    if (baseUri.scheme != 'https' ||
        baseUri.host.isEmpty ||
        baseUri.userInfo.isNotEmpty ||
        baseUri.hasQuery ||
        baseUri.hasFragment) {
      throw StateError('API_BASE_URL must be a valid HTTPS URL.');
    }
    return baseUri.resolve(path).replace(queryParameters: queryParameters);
  }

  String? _token;

  Future<bool> hasStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  Future<Map<String, dynamic>?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedProfile = prefs.getString('cached_profile');
    if (cachedProfile == null) return null;

    final decoded = json.decode(cachedProfile);
    if (decoded is! Map<String, dynamic>) {
      await prefs.remove('cached_profile');
      return null;
    }
    return decoded;
  }

  Future<void> _saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_profile', json.encode(profile));
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('cached_profile');
    _token = null;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String country,
    required String level,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/auth/register'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(json.encode({
          'email': email,
          'password': password,
          'username': username,
          'country': country,
          'level': level,
        })),
      );

      if (response.statusCode == 201) {
        final data = decodeUtf8JsonResponse(response);
        await _saveToken(data['access_token']);
        await _saveProfile(Map<String, dynamic>.from(data['user']));
        return data;
      } else {
        throw Exception(decodeUtf8JsonResponse(response)['detail']);
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        _endpoint('/auth/login'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(json.encode({
          'email': email,
          'password': password,
        })),
      );

      if (response.statusCode == 200) {
        final data = decodeUtf8JsonResponse(response);
        await _saveToken(data['access_token']);
        await _saveProfile(Map<String, dynamic>.from(data['user']));
        return data;
      } else {
        throw Exception(decodeUtf8JsonResponse(response)['detail']);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // User Profile
  Future<Map<String, dynamic>> getProfile() async {
    await _loadToken();
    try {
      final response = await http
          .get(
            _endpoint('/users/me'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final profile = decodeUtf8JsonResponse(response);
        await _saveProfile(profile);
        return profile;
      }
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        throw const AuthSessionExpiredException();
      }
      throw Exception('Failed to load profile (HTTP ${response.statusCode}).');
    } catch (e) {
      if (e is AuthSessionExpiredException) rethrow;
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? country,
    String? level,
    String? avatar,
  }) async {
    await _loadToken();
    try {
      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (country != null) body['country'] = country;
      if (level != null) body['level'] = level;
      if (avatar != null) body['avatar'] = avatar;

      final response = await http.put(
        _endpoint('/users/me'),
        headers: _getHeaders(),
        body: utf8.encode(json.encode(body)),
      );

      if (response.statusCode == 200) {
        final profile = decodeUtf8JsonResponse(response);
        await _saveProfile(profile);
        return profile;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        throw const AuthSessionExpiredException();
      } else {
        throw Exception('Failed to update profile');
      }
    } on AuthSessionExpiredException {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Activity Logging
  Future<Map<String, dynamic>> logActivity({
    required String userId,
    required String activityType,
    required int points,
    Map<String, dynamic>? metadata,
  }) async {
    await _loadToken();
    try {
      final response = await http.post(
        _endpoint('/users/activity'),
        headers: _getHeaders(),
        body: utf8.encode(json.encode({
          'user_id': userId,
          'activity_type': activityType,
          'points': points,
          'metadata': metadata,
          'activity_date': DateTime.now().toIso8601String().split('T').first,
        })),
      );

      if (response.statusCode == 201) {
        final result = decodeUtf8JsonResponse(response);
        final profile = result['user'];
        if (profile is Map<String, dynamic>) {
          await _saveProfile(profile);
        }
        return result;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        throw const AuthSessionExpiredException();
      } else {
        throw Exception(
          decodeUtf8JsonResponse(response)['detail'] ??
              'Failed to log activity (HTTP ${response.statusCode}).',
        );
      }
    } on AuthSessionExpiredException {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getArabicCourseProgress() async {
    await _loadToken();
    try {
      final response = await http
          .get(
            _endpoint('/users/arabic-course-progress'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = decodeUtf8JsonResponse(response);
        final profile = result['user'];
        if (profile is Map<String, dynamic>) await _saveProfile(profile);
        return result;
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AuthSessionExpiredException();
      }
      throw Exception(
        'Failed to load Arabic course progress (HTTP ${response.statusCode}).',
      );
    } on AuthSessionExpiredException {
      rethrow;
    } catch (error) {
      throw Exception('Error loading Arabic course progress: $error');
    }
  }

  Future<Map<String, dynamic>> syncArabicCourseProgress({
    required Map<String, dynamic> progress,
  }) async {
    await _loadToken();
    try {
      final response = await http
          .put(
            _endpoint('/users/arabic-course-progress'),
            headers: _getHeaders(),
            body: utf8.encode(json.encode(progress)),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = decodeUtf8JsonResponse(response);
        final profile = result['user'];
        if (profile is Map<String, dynamic>) await _saveProfile(profile);
        return result;
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AuthSessionExpiredException();
      }
      throw Exception(
        'Failed to sync Arabic course progress (HTTP ${response.statusCode}).',
      );
    } on AuthSessionExpiredException {
      rethrow;
    } catch (error) {
      throw Exception('Error syncing Arabic course progress: $error');
    }
  }

  Future<Map<String, dynamic>> getUserRank() async {
    await _loadToken();
    try {
      final response = await http
          .get(
            _endpoint('/users/rank'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return decodeUtf8JsonResponse(response);
      } else {
        throw Exception('Failed to get rank');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Leaderboard
  Future<List<dynamic>> getGlobalLeaderboard({int limit = 100}) async {
    try {
      final response = await http.get(
        _endpoint(
          '/leaderboard/global',
          queryParameters: {'limit': '$limit'},
        ),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return decodeUtf8JsonResponse(response);
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getCountryLeaderboard({
    required String country,
    int limit = 100,
  }) async {
    try {
      final response = await http.get(
        _endpoint(
          '/leaderboard/country/${Uri.encodeComponent(country)}',
          queryParameters: {'limit': '$limit'},
        ),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return decodeUtf8JsonResponse(response);
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
