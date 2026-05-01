import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();

  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  );

  Future<Either<Failure, CategoryEntity>> updateCategory(
    String id,
    CategoryEntity category,
  );

  Future<Either<Failure, void>> deleteCategory(String id);
}
