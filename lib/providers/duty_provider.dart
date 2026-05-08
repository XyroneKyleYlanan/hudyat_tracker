import 'package:flutter/material.dart';
import '../services/duty_service.dart';

class DutyProvider extends ChangeNotifier {
  final DutyService _service = DutyService();

  List<Map<String, dynamic>> _duties = [];
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;

  List<Map<String, dynamic>> get duties => _duties;
  List<Map<String, dynamic>> get members => _members;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllDuties() async {
    _isLoading = true;
    _errorMessage = null;
    _page = 1;
    notifyListeners();

    try {
      final response = await _service.getAllDuties(page: 1, limit: 1000);
      _duties = List<Map<String, dynamic>>.from(response['data'] ?? []);
      _hasMore = false;
    } catch (e) {
      _errorMessage = 'Failed to load duties.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreDuties() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final response = await _service.getAllDuties(page: nextPage);
      final newDuties = List<Map<String, dynamic>>.from(response['data'] ?? []);
      _duties = [..._duties, ...newDuties];
      _hasMore = response['has_more'] == true;
      _page = nextPage;
    } catch (_) {}

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadMemberDuties(String memberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _duties = await _service.getDutiesByMember(memberId);
    } catch (e) {
      _errorMessage = 'Failed to load duties.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMembers() async {
    try {
      _members = await _service.getMembers();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load members.';
      notifyListeners();
    }
  }

  Future<bool> logDuty({
    required String memberId,
    required String eventId,
    required String roleAssigned,
    String? notes,
  }) async {
    try {
      await _service.logDuty(
        memberId: memberId,
        eventId: eventId,
        roleAssigned: roleAssigned,
        notes: notes,
      );
      await loadAllDuties();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to log duty. Member may already have a duty for this event.';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteDuty(String dutyId) async {
    try {
      await _service.deleteDuty(dutyId);
      await loadAllDuties();
    } catch (e) {
      _errorMessage = 'Failed to delete duty.';
      notifyListeners();
    }
  }

  Future<bool> updateDuty({
    required String dutyId,
    required String roleAssigned,
    String? notes,
  }) async {
    try {
      await _service.updateDuty(dutyId: dutyId, roleAssigned: roleAssigned, notes: notes);
      await loadAllDuties();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update duty.';
      notifyListeners();
      return false;
    }
  }
}
