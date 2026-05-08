import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await ApiService.post(
      'auth/login.php',
      {'email': email, 'password': password},
      auth: false,
    );

    if (response['token'] != null) {
      await ApiService.saveToken(response['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(response['user']));
      return response['user'];
    }
    return null;
  }

  Future<void> logout() async {
    await ApiService.post('auth/logout.php', {});
    await ApiService.clearToken();
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final response = await ApiService.get('auth/profile.php');
    if (response['error'] != null) return null;
    return response;
  }

  Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('auth_user');
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}
