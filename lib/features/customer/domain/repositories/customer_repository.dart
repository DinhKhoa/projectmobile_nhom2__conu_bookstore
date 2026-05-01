import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getAllCustomers();

  Future<Either<Failure, CustomerEntity>> createCustomer(
    CustomerEntity customer,
  );

  Future<Either<Failure, CustomerEntity>> updateCustomer(
    String id, {
    required CustomerEntity updatedCustomer,
  });

  Future<Either<Failure, void>> deleteCustomer(String id);
}
