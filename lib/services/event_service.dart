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
  }) async {
    await ApiService.post('events/create.php', {
      'name': name,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await ApiService.delete('events/delete.php', {'id': eventId});
  }
}
