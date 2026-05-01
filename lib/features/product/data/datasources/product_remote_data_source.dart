import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/error_handler.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();

  Future<ProductModel> createProduct(ProductModel product);

  Future<ProductModel> updateProduct(String id, ProductModel product);

  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await dio.get('/products');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await dio.post('/products', data: product.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProductModel.fromJson(response.data['data']);
      } else {
        throw Exception('Create failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    try {
      final response = await dio.put('/products/$id', data: product.toJson());
      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data['data']);
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final response = await dio.delete('/products/$id');
      if (response.statusCode != 200) {
        throw Exception('Delete failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
