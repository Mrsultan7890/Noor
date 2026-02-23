import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend on laptop, app on phone (same WiFi)
  static const String baseUrl = 'http://192.168.0.217:8000'; // Laptop IP (Bridge Mode)
  // static const String baseUrl = 'http://127.0.0.1:8000'; // Same device
  // static const String baseUrl = 'https://your-render-url.onrender.com'; // Production
  
  String? _token;
  
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
    _token = null;
  }
  
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
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
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
          'country': country,
          'level': level,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await _saveToken(data['access_token']);
        return data;
      } else {
        throw Exception(json.decode(response.body)['detail']);
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
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToken(data['access_token']);
        return data;
      } else {
        throw Exception(json.decode(response.body)['detail']);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // User Profile
  Future<Map<String, dynamic>> getProfile() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
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
        Uri.parse('$baseUrl/users/me'),
        headers: _getHeaders(),
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
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
        Uri.parse('$baseUrl/users/activity'),
        headers: _getHeaders(),
        body: json.encode({
          'user_id': userId,
          'activity_type': activityType,
          'points': points,
          'metadata': metadata,
        }),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to log activity');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getUserRank() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/rank'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
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
        Uri.parse('$baseUrl/leaderboard/global?limit=$limit'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
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
        Uri.parse('$baseUrl/leaderboard/country/$country?limit=$limit'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
