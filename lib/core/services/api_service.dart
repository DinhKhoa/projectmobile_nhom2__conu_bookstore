import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String _tokenKey = 'auth_token';

  // ── Token Management ──────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Headers ───────────────────────────────────────────────
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── HTTP Methods ──────────────────────────────────────────
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = true,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  // ── Response Parsing ──────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }
      return {
        'success': false,
        'message': decoded['message'] ?? 'Lỗi không xác định',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return _errorResponse('Lỗi kết nối: ${response.statusCode}');
    }
  }

  static Map<String, dynamic> _errorResponse(String message) {
    return {
      'success': false,
      'message': message.contains('SocketException') || message.contains('Connection refused')
          ? 'Không thể kết nối server. Vui lòng kiểm tra server đang chạy.'
          : message,
    };
  }
}
