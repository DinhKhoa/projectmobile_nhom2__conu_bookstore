import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/data/datasources/category_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/data/models/category_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/entities/category_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final categories = await remoteDataSource.getAllCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel(
        id: category.id,
        code: category.code,
        name: category.name,
        description: category.description,
      );
      final result = await remoteDataSource.createCategory(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    String id,
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel(
        id: category.id,
        code: category.code,
        name: category.name,
        description: category.description,
      );
      final result = await remoteDataSource.updateCategory(id, model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
