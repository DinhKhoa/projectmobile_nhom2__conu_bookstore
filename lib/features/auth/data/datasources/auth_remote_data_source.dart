import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/error_handler.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: jsonEncode({
          'TenDangNhap': username.trim(),
          'MatKhau': password.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return UserModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
