import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getAllProducts();

  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product);

  Future<Either<Failure, ProductEntity>> updateProduct(
    String id,
    ProductEntity product,
  );

  Future<Either<Failure, void>> deleteProduct(String id);
}
