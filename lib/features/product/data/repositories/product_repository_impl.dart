import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/datasources/product_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/models/product_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
      }
      return e.message ?? 'Đã xảy ra lỗi kết nối';
    }
    return e.toString();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts() async {
    try {
      final products = await remoteDataSource.getAllProducts();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product,
  ) async {
    try {
      final productModel = await remoteDataSource.createProduct(
        ProductModel.fromEntity(product),
      );
      return Right(productModel);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
    String id,
    ProductEntity product,
  ) async {
    try {
      final productModel = await remoteDataSource.updateProduct(
        id,
        ProductModel.fromEntity(product),
      );
      return Right(productModel);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }
}
