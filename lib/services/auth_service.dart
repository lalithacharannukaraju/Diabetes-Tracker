import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final client = const ApiClient();
    final response = await client.post('/api/auth/login', body: {
      'username': username,
      'password': password,
    });
    await _saveAuth(response);
    return response as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> register(String username, String password) async {
    final client = const ApiClient();
    final response = await client.post('/api/auth/register', body: {
      'username': username,
      'password': password,
    });
    await _saveAuth(response);
    return response as Map<String, dynamic>?;
  }

  Future<void> _saveAuth(Map<String, dynamic>? response) async {
    if (response == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = response['token'] as String?;
    final user = response['user'] as Map<String, dynamic>?;
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    }
    if (user != null && user['username'] is String) {
      await prefs.setString(_usernameKey, user['username'] as String);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
  }
}

