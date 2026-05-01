import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/datasources/customer_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/models/customer_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/entities/customer_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

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
  Future<Either<Failure, List<CustomerEntity>>> getAllCustomers() async {
    try {
      final customers = await remoteDataSource.getAllCustomers();
      return Right(customers);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer(
    CustomerEntity customer,
  ) async {
    try {
      final customerModel = await remoteDataSource.createCustomer(
        CustomerModel.fromEntity(customer),
      );
      return Right(customerModel);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomer(
    String id, {
    required CustomerEntity updatedCustomer,
  }) async {
    try {
      final customerModel = await remoteDataSource.updateCustomer(
        id,
        CustomerModel.fromEntity(updatedCustomer),
      );
      return Right(customerModel);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      await remoteDataSource.deleteCustomer(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_handleError(e)));
    }
  }
}
