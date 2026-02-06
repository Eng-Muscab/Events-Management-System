import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      _user = User.fromJson(response as Map<String, dynamic>);
      await _saveUserToPrefs();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      _user = User.fromJson(response as Map<String, dynamic>);
      await _saveUserToPrefs();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required String email, String? password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/users/profile', {
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      });

      // Maintain the existing token if the response doesn't provide a new one
      final oldToken = _user?.token;
      _user = User.fromJson(response as Map<String, dynamic>);
      if (_user != null && oldToken != null && _user!.token.isEmpty) {
        _user = User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: _user!.role,
          token: oldToken,
        );
      }
      
      await _saveUserToPrefs();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
    await prefs.setString('token', _user!.token);
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user')) {
      final userData = jsonDecode(prefs.getString('user')!);
      _user = User.fromJson(userData as Map<String, dynamic>);
      notifyListeners();
    }
  }
}
