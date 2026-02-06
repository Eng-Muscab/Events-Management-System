import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/users');
      final List<dynamic> data = response;
      _users = data.map((item) => User.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      // For now, using register endpoint as a simple "Create User" proxy
      // ideally backend has a dedicated admin /users POST
      await _apiService.post('/auth/register', userData);
      await fetchUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      await _apiService.put('/users/$id', userData);
      await fetchUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _apiService.delete('/users/$id');
      await fetchUsers();
    } catch (e) {
      rethrow;
    }
  }
}
