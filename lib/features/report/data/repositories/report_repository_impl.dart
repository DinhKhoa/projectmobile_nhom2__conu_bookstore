import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/data/datasources/report_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/entities/report_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  final DateFormat _uiDateFormat = DateFormat('dd/MM/yyyy');

  @override
  Future<Either<Failure, (RevenueSummaryEntity, List<DailyRevenueEntity>)>>
  getRevenueReport(String start, String end) async {
    try {
      final result = await remoteDataSource.getRevenueReport(start, end);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductReportEntity>>> getProductReport(
    String start,
    String end,
    bool slowSelling,
  ) async {
    try {
      final result = await remoteDataSource.getProductReport(
        start,
        end,
        slowSelling,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
