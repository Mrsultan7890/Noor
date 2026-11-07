import 'dart:async';

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

  Future<void> restoreSession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!await _apiService.hasStoredToken()) return;

      final cachedProfile = await _apiService.getCachedProfile();
      if (cachedProfile != null) {
        _currentUser = User.fromJson(cachedProfile);
        _isLoading = false;
        notifyListeners();
        unawaited(_refreshRestoredProfile());
        return;
      }

      _currentUser = User.fromJson(await _apiService.getProfile());
    } on AuthSessionExpiredException {
      await _apiService.clearToken();
      _currentUser = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshRestoredProfile() async {
    try {
      _currentUser = User.fromJson(await _apiService.getProfile());
      _error = null;
      notifyListeners();
    } on AuthSessionExpiredException {
      await _apiService.clearToken();
      _currentUser = null;
      notifyListeners();
    } catch (error) {
      // Keep the cached profile when the API is temporarily unavailable.
      _error = error.toString();
      notifyListeners();
    }
  }
  
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
      _error = null;
      _isLoading = false;
      notifyListeners();
    } on AuthSessionExpiredException {
      await _apiService.clearToken();
      _currentUser = null;
      _error = 'Your session expired. Please sign in again.';
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
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthSessionExpiredException {
      await _apiService.clearToken();
      _currentUser = null;
      _error = 'Your session expired. Please sign in again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<int?> logActivity({
    required String activityType,
    required int points,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUser == null) {
      _error = 'Sign in to sync activity and earn profile points.';
      notifyListeners();
      return null;
    }
    
    try {
      final result = await _apiService.logActivity(
        userId: _currentUser!.id,
        activityType: activityType,
        points: points,
        metadata: metadata,
      );
      final profile = result['user'];
      if (profile is Map<String, dynamic>) {
        _currentUser = User.fromJson(profile);
      }
      _error = null;
      notifyListeners();
      final pointsEarned = result['points_earned'];
      return pointsEarned is int ? pointsEarned : null;
    } on AuthSessionExpiredException {
      await _apiService.clearToken();
      _currentUser = null;
      _error = 'Your session expired. Please sign in again.';
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
