import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/categories'); // Needs a public or accessible route
      final List<dynamic> data = response;
      _categories = data.map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String description) async {
    try {
      await _apiService.post('/categories', {'name': name, 'description': description});
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(String id, String name, String description) async {
    try {
      await _apiService.put('/categories/$id', {'name': name, 'description': description});
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _apiService.delete('/categories/$id');
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }
}
