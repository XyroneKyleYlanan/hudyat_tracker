import 'api_service.dart';

class EventService {
  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await ApiService.get('events/index.php');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createEvent({
    required String name,
    required String description,
    required DateTime eventDate,
    String? eventTime,
  }) async {
    await ApiService.post('events/create.php', {
      'name': name,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      if (eventTime != null) 'event_time': eventTime,
    });
  }

  Future<void> updateEvent({
    required String id,
    required String name,
    required String description,
    required DateTime eventDate,
    String? eventTime,
  }) async {
    await ApiService.post('events/update.php', {
      'id': id,
      'name': name,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      if (eventTime != null) 'event_time': eventTime,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await ApiService.delete('events/delete.php', {'id': eventId});
  }
}
