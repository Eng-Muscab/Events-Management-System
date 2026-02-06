import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Event> _myEvents = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Event> get events => _events;
  List<Event> get myEvents => _myEvents;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/events');
      final List<dynamic> data = response;
      _events = data.map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching events: $e');
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/events/my');
      final List<dynamic> data = response;
      _myEvents = data.map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching my events: $e');
      _myEvents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      await _apiService.post('/events', eventData);
      await fetchEvents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      await _apiService.put('/events/$id', eventData);
      await fetchEvents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _apiService.delete('/events/$id');
      await fetchEvents();
    } catch (e) {
      rethrow;
    }
  }
}
