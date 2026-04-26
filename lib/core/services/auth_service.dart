import 'api_service.dart';

class AuthService {
  // POST /api/auth/login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await ApiService.post(
      '/auth/login',
      {'TenDangNhap': username, 'MatKhau': password},
      requireAuth: false,
    );

    if (result['success'] == true) {
      final token = result['data']?['token'] as String?;
      if (token != null) {
        await ApiService.saveToken(token);
      }
    }

    return result;
  }

  // Đăng xuất
  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  // Kiểm tra đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }

  // GET /api/auth/me
  static Future<Map<String, dynamic>> getProfile() async {
    return ApiService.get('/auth/me');
  }
}
