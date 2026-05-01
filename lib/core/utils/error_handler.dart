import 'package:dio/dio.dart';

class ErrorHandler {
  static String handleDioError(dynamic e) {
    String message = e.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data;
        message = data['message'] ?? data['error'] ?? message;
      } else {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            message = 'Kết nối quá hạn, vui lòng kiểm tra mạng';
            break;
          case DioExceptionType.receiveTimeout:
            message = 'Server phản hồi chậm, vui lòng thử lại';
            break;
          case DioExceptionType.connectionError:
            message = 'Không thể kết nối tới server';
            break;
          default:
            message = 'Đã có lỗi xảy ra, vui lòng thử lại';
        }
      }
    }
    return message;
  }
}
