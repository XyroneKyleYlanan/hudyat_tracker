import 'package:flutter/material.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _service = EventService();

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _service.getEvents();
    } catch (e) {
      _errorMessage = 'Failed to load events.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createEvent({
    required String name,
    required String description,
    required DateTime eventDate,
    String? eventTime,
  }) async {
    try {
      await _service.createEvent(
        name: name,
        description: description,
        eventDate: eventDate,
        eventTime: eventTime,
      );
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create event.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent({
    required String id,
    required String name,
    required String description,
    required DateTime eventDate,
    String? eventTime,
  }) async {
    try {
      await _service.updateEvent(
        id: id,
        name: name,
        description: description,
        eventDate: eventDate,
        eventTime: eventTime,
      );
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update event.';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _service.deleteEvent(eventId);
      await loadEvents();
    } catch (e) {
      _errorMessage = 'Failed to delete event.';
      notifyListeners();
    }
  }
}
