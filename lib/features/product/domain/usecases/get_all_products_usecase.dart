import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/usecases/usecase.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/entities/product_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/repositories/product_repository.dart';

class GetAllProductsUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetAllProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getAllProducts();
  }
}
