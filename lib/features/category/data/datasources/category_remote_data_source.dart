import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/utils/error_handler.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getAllCategories();

  Future<CategoryModel> createCategory(CategoryModel category);

  Future<CategoryModel> updateCategory(String id, CategoryModel category);

  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await dio.get('/categories');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final response = await dio.post('/categories', data: category.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return CategoryModel.fromJson(response.data['data']);
      } else {
        throw Exception('Create failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<CategoryModel> updateCategory(
    String id,
    CategoryModel category,
  ) async {
    try {
      final response = await dio.put(
        '/categories/$id',
        data: category.toJson(),
      );
      if (response.statusCode == 200) {
        return CategoryModel.fromJson(response.data['data']);
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final response = await dio.delete('/categories/$id');
      if (response.statusCode != 200) {
        throw Exception('Delete failed');
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleDioError(e));
    }
  }
}
