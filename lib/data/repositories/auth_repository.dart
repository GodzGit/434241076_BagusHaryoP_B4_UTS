import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/mock_api.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await MockApi.login(email, password);
      
      if (response['success'] == true) {
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, response['token']);
        await prefs.setString(_userKey, response['user'].toString());
        
        return {
          'success': true,
          'token': response['token'],
          'user': UserModel.fromJson(response['user']),
        };
      }
      throw Exception('Login gagal');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await MockApi.register(name, email, password);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      try {
        // Parse the stored user string back to Map
        final Map<String, dynamic> userMap = {
          'id': userString.split(',')[0].split(':')[1].trim(),
          // This is simplified, better to store JSON
        };
        // For now, return null and we'll fix later
        return null;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }
    // In real app, send reset email
  }
}