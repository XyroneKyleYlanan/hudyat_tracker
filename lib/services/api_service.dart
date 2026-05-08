import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Switch this when changing environments:
  // Emulator  → _emulatorUrl
  // Real device (hotspot) → _deviceUrl
  static const _useEmulator = true;

  static const _emulatorUrl = 'http://10.0.2.2/hudyat_api';
  static const _deviceUrl   = 'http://192.168.137.1/hudyat_api'; // your laptop's hotspot IP

  static const String baseUrl = _useEmulator ? _emulatorUrl : _deviceUrl;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body, {bool auth = true}) async {
    final headers = auth
        ? await authHeaders()
        : {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    final headers = await authHeaders();
    Uri uri = Uri.parse('$baseUrl/$endpoint');
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }
    final response = await http.get(uri, headers: headers);
    return jsonDecode(response.body);
  }

  static Future<dynamic> delete(String endpoint, Map<String, dynamic> body) async {
    final headers = await authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }
}
