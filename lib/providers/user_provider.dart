import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String country,
    required String level,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        username: username,
        country: country,
        level: level,
      );
      
      _currentUser = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      _currentUser = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.getProfile();
      _currentUser = User.fromJson(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateProfile({
    String? username,
    String? country,
    String? level,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.updateProfile(
        username: username,
        country: country,
        level: level,
      );
      
      _currentUser = User.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logActivity({
    required String activityType,
    required int points,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUser == null) return;
    
    try {
      await _apiService.logActivity(
        userId: _currentUser!.id,
        activityType: activityType,
        points: points,
        metadata: metadata,
      );
      
      // Reload profile to get updated points
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
    notifyListeners();
  }
}
