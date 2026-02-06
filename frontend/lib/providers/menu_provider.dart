import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItem> _menus = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<MenuItem> get menus => _menus;
  bool get isLoading => _isLoading;

  Future<void> fetchMenus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/menus');
      final List<dynamic> data = response;
      _menus = data.map((item) => MenuItem.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching menus: $e');
      // Fallback or empty list
      _menus = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
