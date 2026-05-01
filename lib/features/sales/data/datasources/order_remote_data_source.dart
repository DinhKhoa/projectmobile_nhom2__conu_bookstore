import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/error_handler.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(Map<String, dynamic> orderData);

  Future<List<OrderModel>> getAllOrders();

  Future<String> getNextOrderCode();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await dio.post('/orders', data: orderData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception('Create order failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await dio.get('/orders');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<String> getNextOrderCode() async {
    try {
      final response = await dio.get('/orders/next-code');
      if (response.statusCode == 200) {
        return response.data['data']['code'] ?? '';
      }
      throw Exception('Failed to get next code');
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
