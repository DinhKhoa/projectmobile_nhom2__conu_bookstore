import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/error_handler.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getAllCustomers();

  Future<CustomerModel> createCustomer(CustomerModel customer);

  Future<CustomerModel> updateCustomer(String id, CustomerModel customer);

  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final Dio dio;

  CustomerRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final response = await dio.get('/customers');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => CustomerModel.fromJson(json)).toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final response = await dio.post('/customers', data: customer.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return CustomerModel.fromJson(response.data['data']);
      } else {
        throw Exception('Create failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<CustomerModel> updateCustomer(
    String id,
    CustomerModel customer,
  ) async {
    try {
      final response = await dio.put('/customers/$id', data: customer.toJson());
      if (response.statusCode == 200) {
        return CustomerModel.fromJson(response.data['data']);
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      final response = await dio.delete('/customers/$id');
      if (response.statusCode != 200) {
        throw Exception('Delete failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
