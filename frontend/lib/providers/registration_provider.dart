import 'package:flutter/material.dart';
import '../models/registration.dart';
import '../services/api_service.dart';

class RegistrationProvider with ChangeNotifier {
  List<Registration> _registrations = [];
  List<Registration> _eventParticipants = [];
  List<Registration> _organizerRegistrations = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Registration> get registrations => _registrations;
  List<Registration> get eventParticipants => _eventParticipants;
  List<Registration> get organizerRegistrations => _organizerRegistrations;
  bool get isLoading => _isLoading;

  Future<void> fetchOrganizerRegistrations({String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = '/registrations/organizer';
      if (search != null && search.isNotEmpty) {
        endpoint += '?search=$search';
      }
      final response = await _apiService.get(endpoint);
      final List<dynamic> data = response;
      _organizerRegistrations = data.map((item) => Registration.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching organizer registrations: $e');
      _organizerRegistrations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRegistrations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/registrations/my');
      final List<dynamic> data = response;
      _registrations = data.map((item) => Registration.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching registrations: $e');
      _registrations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEventParticipants(String eventId, {String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = '/registrations/event/$eventId';
      if (search != null && search.isNotEmpty) {
        endpoint += '?search=$search';
      }
      final response = await _apiService.get(endpoint);
      final List<dynamic> data = response;
      _eventParticipants = data.map((item) => Registration.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching event participants: $e');
      _eventParticipants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerForEvent(String eventId, Map<String, dynamic> attendeeData) async {
    try {
      await _apiService.post('/registrations', {
        'event': eventId,
        ...attendeeData,
      });
      await fetchRegistrations();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> payForRegistration(String registrationId) async {
    try {
      await _apiService.put('/registrations/$registrationId/pay', {});
      await fetchRegistrations();
    } catch (e) {
      rethrow;
    }
  }
}
