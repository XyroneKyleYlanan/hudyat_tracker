import 'api_service.dart';

class DutyService {
  Future<Map<String, dynamic>> getAllDuties({int page = 1, int limit = 20}) async {
    final response = await ApiService.get(
      'duties/index.php',
      params: {'page': page.toString(), 'limit': limit.toString()},
    );
    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> getDutiesByMember(String memberId) async {
    final response = await ApiService.get(
      'duties/member.php',
      params: {'member_id': memberId},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMembers({bool showAll = false}) async {
    final response = await ApiService.get(
      'members/index.php',
      params: showAll ? {'show_all': '1'} : null,
    );
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> deactivateMember(String id) async {
    final response = await ApiService.post('members/update.php', {'id': id, 'is_active': '0'});
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> reactivateMember(String id) async {
    final response = await ApiService.post('members/update.php', {'id': id, 'is_active': '1'});
    return Map<String, dynamic>.from(response);
  }

  Future<void> logDuty({
    required String memberId,
    required String eventId,
    required String roleAssigned,
    String? notes,
  }) async {
    await ApiService.post('duties/log.php', {
      'member_id': memberId,
      'event_id': eventId,
      'role_assigned': roleAssigned,
      'notes': notes ?? '',
    });
  }

  Future<void> deleteDuty(String dutyId) async {
    await ApiService.delete('duties/delete.php', {'id': dutyId});
  }

  Future<void> updateDuty({
    required String dutyId,
    required String roleAssigned,
    String? notes,
  }) async {
    await ApiService.post('duties/update.php', {
      'id': dutyId,
      'role_assigned': roleAssigned,
      'notes': notes ?? '',
    });
  }

  Future<Map<String, dynamic>?> getMemberPerformance(String memberId) async {
    final response = await ApiService.get(
      'performance/member.php',
      params: {'member_id': memberId},
    );
    if (response['error'] != null) return null;
    return response;
  }

  Future<List<Map<String, dynamic>>> getAllPerformance({String period = 'all'}) async {
    final response = await ApiService.get(
      'performance/index.php',
      params: {'period': period},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await ApiService.get('dashboard/stats.php');
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> deleteMember(String memberId) async {
    final response = await ApiService.delete('members/delete.php', {'id': memberId});
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> updateMember({
    required String id,
    String? fullName,
    String? studentId,
    String? email,
    String? password,
    String? role,
    String? course,
    String? yearLevel,
    String? section,
  }) async {
    final response = await ApiService.post('members/update.php', {
      'id': id,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
      if (studentId != null) 'student_id': studentId,
      if (email != null && email.isNotEmpty) 'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (role != null) 'role': role,
      if (course != null) 'course': course,
      if (yearLevel != null) 'year_level': yearLevel,
      if (section != null) 'section': section,
    });
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> createMember({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
    required String role,
    String? course,
    String? yearLevel,
    String? section,
  }) async {
    final response = await ApiService.post('members/create.php', {
      'full_name': fullName,
      'student_id': studentId,
      'email': email,
      'password': password,
      'role': role,
      if (course != null && course.isNotEmpty) 'course': course,
      if (yearLevel != null) 'year_level': yearLevel,
      if (section != null && section.isNotEmpty) 'section': section,
    });
    return Map<String, dynamic>.from(response);
  }
}
