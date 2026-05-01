import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/datasources/order_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/models/order_model.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/entities/order_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    try {
      final orderModel = await remoteDataSource.createOrder(
        OrderModel.fromEntity(order).toJson(),
      );
      return Right(orderModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    try {
      final orders = await remoteDataSource.getAllOrders();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
