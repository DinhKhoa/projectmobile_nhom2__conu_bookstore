import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, (RevenueSummaryEntity, List<DailyRevenueEntity>)>>
  getRevenueReport(String start, String end);

  Future<Either<Failure, List<ProductReportEntity>>> getProductReport(
    String start,
    String end,
    bool slowSelling,
  );
}
