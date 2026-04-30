import 'dart:convert';
import 'package:http/http.dart' as http;

// ── Change this to your PC's local IP ────────────────────────────────────────
const String kBaseUrl = 'http://192.168.56.1:8000';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  String? _token;
  String? _role;
  String? _email;

  // ── State getters ──────────────────────────────────────────────────────────
  bool get isLoggedIn => _token != null;
  String? get role => _role;
  String? get email => _email;
  String? get token => _token;

  void setAuth(String token, String role, String email) {
    _token = token;
    _role = role;
    _email = email;
  }

  void clearAuth() {
    _token = null;
    _role = null;
    _email = null;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> signup(
      String email, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── Patient ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPatient(String patientEmail) async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/patient/${Uri.encodeComponent(patientEmail)}'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> enterPatient(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/patient/enter'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> editPatient(
      String patientEmail, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse('$kBaseUrl/patient/${Uri.encodeComponent(patientEmail)}'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── Drug Interactions ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> drugInteractions(String drug) async {
    try {
      final res = await http.get(
        Uri.parse(
            '$kBaseUrl/drug/interactions?drug=${Uri.encodeComponent(drug)}'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── History ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> accessHistory(
      String email, String role) async {
    try {
      final res = await http.get(
        Uri.parse(
            '$kBaseUrl/history/access?email=${Uri.encodeComponent(email)}&role=$role'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> editHistory(String email, String role) async {
    try {
      final res = await http.get(
        Uri.parse(
            '$kBaseUrl/history/edit?email=${Uri.encodeComponent(email)}&role=$role'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> dataEntryHistory(String email) async {
    try {
      final res = await http.get(
        Uri.parse(
            '$kBaseUrl/history/data_entry?email=${Uri.encodeComponent(email)}'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── Face ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> findByFace() async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/patient/find/face'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> findByFingerprint() async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/patient/find/fingerprint'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> captureFingerprint() async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/biometric/capture-fingerprint'),
        headers: _headers,
      );
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _parse(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return {'success': true, ...body};
        }
        return {
          'success': false,
          'message': body['detail'] ?? body['message'] ?? 'Server error'
        };
      }
      return {'success': false, 'message': 'Unexpected response'};
    } catch (_) {
      return {'success': false, 'message': 'Failed to parse response'};
    }
  }
}
