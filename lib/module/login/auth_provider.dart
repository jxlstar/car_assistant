import 'package:flutter/material.dart';
import 'package:car_assistant/core/network/api_service.dart';
import 'package:car_assistant/core/storage/storage_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final token = StorageService.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      ApiService.setAuthToken(token);
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await ApiService.login(email: email, password: password);
    if (response.statusCode == 200 && response.data != null) {
      final token = response.data!['token'];
      StorageService.setString('auth_token', token);
      ApiService.setAuthToken(token);
      _isLoggedIn = true;
      notifyListeners();
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      // Even if API call fails, proceed to clear local token
      print('Logout API call failed: $e');
    } finally {
      StorageService.remove('auth_token');
      ApiService.clearAuthToken();
      _isLoggedIn = false;
      notifyListeners();
    }
  }
}