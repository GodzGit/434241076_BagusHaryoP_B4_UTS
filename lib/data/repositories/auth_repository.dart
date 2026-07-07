import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/supabase_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _supabaseService.signIn(email, password);
      
      if (response.session != null) {
        // Get user profile
        final profile = await _supabaseService.getProfile(response.user!.id);
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, response.session!.accessToken);
        
        final user = UserModel(
          id: response.user!.id,
          name: profile['name'],
          email: response.user!.email ?? email,
          role: profile['role'],
        );
        
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        
        return {
          'success': true,
          'token': response.session!.accessToken,
          'user': user,
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
      final response = await _supabaseService.signUp(email, password, name);
      
      if (response.user != null) {
        return {
          'success': true,
          'message': 'Registrasi berhasil, silakan login',
        };
      }
      throw Exception('Registrasi gagal');
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
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
        // Parse user data
        final Map<String, dynamic> userMap = jsonDecode(userString);
        return UserModel.fromJson(userMap);
      } catch (e) {
        print('Error getCurrentUser: $e');
        return null;
      }
    }
    return null;
  }
}