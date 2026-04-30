import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final _api = ApiService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _api.isLoggedIn;
  String? get role => _api.role;
  String? get email => _api.email;
  String? get token => _api.token;

  // ── Restore session on app start ──────────────────────────────────────────

  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role  = prefs.getString('role');
    final email = prefs.getString('email');
    if (token != null && role != null && email != null) {
      _api.setAuth(token, role, email);
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.login(email, password, role);
    _isLoading = false;

    if (res['success'] == true) {
      final token = res['token'] as String? ?? _makeToken(email, role);
      _api.setAuth(token, role, email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      await prefs.setString('email', email);
      notifyListeners();
      return true;
    } else {
      _error = res['message'] as String? ?? 'Login failed';
      notifyListeners();
      return false;
    }
  }

  // ── Signup ────────────────────────────────────────────────────────────────

  Future<bool> signup(String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _api.signup(email, password, role);
    _isLoading = false;

    if (res['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _error = res['message'] as String? ?? 'Signup failed';
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _api.clearAuth();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // ── Helper: create a simple base64 token ─────────────────────────────────

  String _makeToken(String email, String role) {
    final payload = jsonEncode({'email': email, 'role': role});
    return base64Encode(utf8.encode(payload));
  }
}
